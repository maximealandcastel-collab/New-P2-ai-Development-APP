import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/user/meal_plan/data/meal_plan_store.dart';

const _orange = Color(0xFFFF7617);
const _ink = Color(0xFF20242B);
const _muted = Color(0xFF717985);
const _surface = Color(0xFFF8F9FA);
const _meals = ['Breakfast', 'Lunch', 'Dinner'];

class _MealSuggestion {
  const _MealSuggestion(this.name, this.entries);
  final String name;
  final List<MealEntry> entries;
}

List<_MealSuggestion> _suggestionsFor(String meal) {
  const recipes = <String, Map<String, Map<String, double>>>{
    'Breakfast': {
      'Protein Oats': {'Oatmeal (cooked)': 1, 'Protein Powder (Whey)': 1, 'Banana': .5},
      'Egg White Omelet': {'Egg Whites': 1, 'Whole Egg': 1, 'Broccoli (steamed)': .5},
      'Greek Yogurt Bowl': {'Greek Yogurt (Plain)': 1, 'Blueberries': 1, 'Banana': .5},
      'Protein Smoothie': {'Protein Powder (Whey)': 1, 'Banana': 1, 'Almond Milk (Unsweetened)': 1},
    },
    'Lunch': {
      'Grilled Chicken Bowl': {'Chicken Breast': 1, 'Brown Rice (cooked)': 1, 'Broccoli (steamed)': 1},
      'Turkey Wrap': {'Ground Turkey (93%)': 1, 'Whole Wheat Tortilla': 1, 'Avocado': .5},
      'Salmon Quinoa Bowl': {'Salmon (Atlantic)': 1, 'Quinoa (cooked)': 1, 'Broccoli (steamed)': 1},
    },
    'Dinner': {
      'Salmon & Sweet Potato': {'Salmon (Atlantic)': 1, 'Sweet Potato (baked)': 1, 'Asparagus': 1},
      'Steak & Rice': {'Lean Steak (sirloin)': 1, 'Brown Rice (cooked)': 1, 'Asparagus': 1},
      'Chicken Pasta': {'Chicken Breast': 1, 'Whole Grain Pasta': 1, 'Broccoli (steamed)': 1},
    },
  };
  final catalog = {for (final food in exampleFoods) food.name: food};
  return (recipes[meal] ?? const <String, Map<String, double>>{}).entries.map((recipe) {
    final ingredients = <MealEntry>[
      for (final part in recipe.value.entries)
        if (catalog[part.key] != null) MealEntry(catalog[part.key]!, part.value),
    ];
    return _MealSuggestion(recipe.key, ingredients);
  }).toList();
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});
  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  MealPlanStore? store;
  DateTime date = DateTime.now();
  String? error;
  int dashboardTab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => error = null);
    try {
      if (!Get.isRegistered<ProfileController>()) {
        throw StateError('Your account is loading. Please retry.');
      }
      final profile = ProfileController.to;
      if (profile.userData?.sId == null) await profile.loadData();
      final id = profile.userData?.sId;
      if (id == null || id.isEmpty) throw StateError('Your account is loading. Please retry.');
      final loaded = await MealPlanStore.open(id);
      if (mounted) setState(() => store = loaded);
    } catch (cause) {
      if (mounted) setState(() => error = cause.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _open(String meal) async {
    final data = store;
    if (data == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _MealBuilder(store: data, meal: meal, date: date)),
    );
    if (changed == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final data = store;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nutrition')),
        body: Center(child: error == null
            ? const CircularProgressIndicator(color: _orange)
            : Column(mainAxisSize: MainAxisSize.min, children: [
                Text(error!, textAlign: TextAlign.center),
                TextButton(onPressed: _load, child: const Text('Retry')),
              ])),
      );
    }
    var total = MealMacros.zero;
    final goal = data.dailyTarget;
    for (final meal in _meals) {
      total += MealMacros.total(data.readMeal(date, meal));
    }
    final progress = goal.calories <= 0 ? 0.0 : total.calories / goal.calories;
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Nutrition', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        actions: [TextButton.icon(
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: Text(DateFormat('MMM d').format(date)),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context, initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null && mounted) setState(() => date = picked);
          },
        )],
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 30), children: [
        const Text('FUEL A BETTER YOU', style: TextStyle(fontSize: 10, letterSpacing: 1.8, color: _muted)),
        const SizedBox(height: 12),
        _SectionTabs(labels: const ['Macros', 'Meals', 'Insights'], selected: dashboardTab,
          onChanged: (value) => setState(() => dashboardTab = value)),
        if (dashboardTab != 1) ...[
        const SizedBox(height: 20),
        Center(child: SizedBox(width: 154, height: 154, child: Stack(fit: StackFit.expand, children: [
          CircularProgressIndicator(value: progress.clamp(0, 1).toDouble(),
            strokeWidth: 10, backgroundColor: const Color(0xFFECEEF1), color: _orange),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 26,
              color: _ink, fontWeight: FontWeight.w600)),
            const Text('Daily Goal', style: TextStyle(fontSize: 11, color: _muted)),
            const SizedBox(height: 3),
            Text('${total.calories.round()} / ${goal.calories.round()} kcal',
              style: const TextStyle(fontSize: 11, color: _ink, fontWeight: FontWeight.w500)),
          ]),
        ]))),
        const SizedBox(height: 17),
        _Card(child: Padding(padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
          child: _MacroRow(total, goal: goal, showIcons: true))),
        const SizedBox(height: 9),
        Text('Remaining: ${(goal.calories - total.calories).clamp(0, double.infinity).round()} kcal · '
            '${(goal.protein - total.protein).clamp(0, double.infinity).round()}g protein · '
            '${(goal.carbs - total.carbs).clamp(0, double.infinity).round()}g carbs · '
            '${(goal.fats - total.fats).clamp(0, double.infinity).round()}g fats',
            style: const TextStyle(color: _muted, fontSize: 11, height: 1.4)),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(
          icon: const Icon(Icons.tune_outlined, size: 16),
          label: const Text('Edit daily targets'),
          onPressed: () async {
            final updated = await _editMacros(context, goal, 'Daily targets');
            if (updated != null && await data.saveDailyTarget(updated) && mounted) setState(() {});
          },
        )),
        const SizedBox(height: 9),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(16)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CONSISTENCY BUILDS RESULTS', style: TextStyle(fontSize: 14,
              color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: .4)),
            SizedBox(height: 3),
            Text('Track. Fuel. Perform.', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ])),
        ],
        const SizedBox(height: 18),
        if (dashboardTab == 2) const Text('Your totals update as you save meals for this day.',
          style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 8),
        const Text('Meal prep', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600, color: _ink)),
        const SizedBox(height: 3),
        const Text('Plan your meals, hit your macros.', style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 12),
        for (final meal in _meals)
          Padding(padding: const EdgeInsets.only(bottom: 7), child: _Card(child: ListTile(
            onTap: () => _open(meal),
            leading: CircleAvatar(radius: 19, backgroundColor: const Color(0xFFFFF0E7),
              child: Icon(meal == 'Breakfast' ? Icons.free_breakfast_outlined
                  : meal == 'Lunch' ? Icons.lunch_dining_outlined : Icons.dinner_dining_outlined, color: _orange, size: 19)),
            title: Text(meal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(data.readMeal(date, meal).isEmpty
                ? 'Add your ${meal.toLowerCase()} prep'
                : '${data.readMeal(date, meal).length} foods · '
                  '${MealMacros.total(data.readMeal(date, meal)).calories.round()} kcal',
                style: const TextStyle(fontSize: 11, color: _muted)),
            trailing: const Icon(Icons.chevron_right, color: _muted, size: 20),
          ))),
        _Card(child: SwitchListTile.adaptive(
          title: const Text('Macro reminders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: const Text('Keep your reminder preference', style: TextStyle(fontSize: 11)),
          value: data.remindersEnabled,
          activeColor: _orange,
          onChanged: (value) async {
            if (await data.setRemindersEnabled(value) && mounted) setState(() {});
          },
        )),
      ])),
    );
  }
}

class _MealBuilder extends StatefulWidget {
  const _MealBuilder({required this.store, required this.meal, required this.date});
  final MealPlanStore store;
  final String meal;
  final DateTime date;
  @override
  State<_MealBuilder> createState() => _MealBuilderState();
}

class _MealBuilderState extends State<_MealBuilder> {
  late List<MealEntry> entries;
  late MealMacros goal;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    entries = widget.store.readMeal(widget.date, widget.meal);
    goal = widget.store.readTarget(widget.meal);
  }

  Future<void> _review() async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(
      builder: (_) => _MealReview(store: widget.store, meal: widget.meal,
        date: widget.date, entries: entries)));
    if (!mounted) return;
    if (saved == true) {
      Navigator.pop(context, true);
    } else {
      setState(() {});
    }
  }

  Future<void> _add() async {
    final selected = await Navigator.push<MealEntry>(
      context, MaterialPageRoute(builder: (_) => _AddFood(store: widget.store, meal: widget.meal)),
    );
    if (selected != null && mounted) {
      setState(() => entries.add(selected));
      await _review();
    }
  }

  Future<void> _editGoal() async {
    final updated = await _editMacros(context, goal, '${widget.meal} targets');
    if (updated != null && await widget.store.saveTarget(widget.meal, updated) && mounted) {
      setState(() => goal = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestionsFor(widget.meal);
    final savedMeal = widget.store.readSavedMeal(widget.meal);
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: _ink,
        surfaceTintColor: Colors.white,
        title: Text(widget.meal, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 30), children: [
        _MealHero(meal: widget.meal),
        const SizedBox(height: 14),
        Text(DateFormat('EEEE, MMM d').format(widget.date),
          style: const TextStyle(fontSize: 11, color: _muted)),
        const SizedBox(height: 12),
        _Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(children: [Expanded(child: Text('Target Macros (${widget.meal})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            TextButton(onPressed: _editGoal, child: const Text('Edit', style: TextStyle(color: _orange)))]),
          _MacroRow(goal, showIcons: true),
        ]))),
        const SizedBox(height: 16),
        _SectionTabs(labels: const ['Suggested', 'My Meals', 'Recipes'], selected: tab,
          onChanged: (value) => setState(() => tab = value)),
        const SizedBox(height: 10),
        if (tab == 0) const Text('Examples are estimates. Check your food label.',
          style: TextStyle(color: _muted, fontSize: 11)),
        if (tab == 0) for (final suggestion in suggestions)
          Padding(padding: const EdgeInsets.only(top: 7), child: _SuggestedMealRow(
            suggestion: suggestion,
            onAdd: () async {
              setState(() => entries.addAll(suggestion.entries));
              await _review();
            },
          )),
        if (tab == 1 && savedMeal.isNotEmpty) Padding(
          padding: const EdgeInsets.only(top: 7), child: _Card(child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFF0E7),
              child: Icon(Icons.bookmark_outline, color: _orange)),
            title: Text('Saved ${widget.meal}', style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600)),
            subtitle: Text('${savedMeal.length} foods · ${MealMacros.total(savedMeal).calories.round()} kcal',
              style: const TextStyle(fontSize: 11, color: _muted)),
            trailing: IconButton(tooltip: 'Add saved ${widget.meal}',
              icon: const Icon(Icons.add_circle_outline, color: _orange),
              onPressed: () async {
                setState(() => entries.addAll(savedMeal));
                await _review();
              }),
          ))),
        if (tab != 0 && (tab != 1 || savedMeal.isEmpty)) Padding(padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(tab == 2 ? 'No recipes saved yet. Add your own food below.'
              : 'A saved meal appears here after you build and save it.',
            style: const TextStyle(color: _muted, fontSize: 12))),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add Food or Create Custom Food')),
        if (entries.isNotEmpty) ...[
        const SizedBox(height: 12),
        FilledButton(onPressed: _review,
          style: FilledButton.styleFrom(backgroundColor: _orange, minimumSize: const Size.fromHeight(48)),
          child: Text('Review ${widget.meal} · ${entries.length} foods')),
        ],
      ])),
    );
  }
}

class _MealReview extends StatefulWidget {
  const _MealReview({required this.store, required this.meal,
    required this.date, required this.entries});

  final MealPlanStore store;
  final String meal;
  final DateTime date;
  final List<MealEntry> entries;

  @override
  State<_MealReview> createState() => _MealReviewState();
}

class _MealReviewState extends State<_MealReview> {
  bool saving = false;

  Future<void> _add() async {
    final selected = await Navigator.push<MealEntry>(context, MaterialPageRoute(
      builder: (_) => _AddFood(store: widget.store, meal: widget.meal)));
    if (selected != null && mounted) setState(() => widget.entries.add(selected));
  }

  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      if (!await widget.store.saveMeal(widget.date, widget.meal, widget.entries)) {
        throw StateError('Could not save this meal');
      }
      if (mounted) Navigator.pop(context, true);
    } catch (cause) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$cause')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = MealMacros.total(widget.entries);
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: _ink,
        surfaceTintColor: Colors.white,
        title: Text(widget.meal, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
        actions: [TextButton(onPressed: saving ? null : _save, child: const Text('Save'))]),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 30), children: [
        _Card(child: Padding(padding: const EdgeInsets.fromLTRB(15, 12, 15, 7),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your ${widget.meal}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 9),
            if (widget.entries.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 18),
              child: Text('No foods yet. Add a food below.', style: TextStyle(color: _muted, fontSize: 12))),
            for (var i = 0; i < widget.entries.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [
                const CircleAvatar(radius: 18, backgroundColor: Color(0xFFFFF0E7),
                  child: Icon(Icons.restaurant_outlined, color: _orange, size: 17)),
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.entries[i].food.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('${widget.entries[i].quantity.toStringAsFixed(widget.entries[i].quantity % 1 == 0 ? 0 : 1)} × '
                    '${widget.entries[i].food.serving} · '
                    '${(widget.entries[i].food.calories * widget.entries[i].quantity).round()} kcal',
                    style: const TextStyle(fontSize: 10, color: _muted)),
                ])),
                IconButton(tooltip: 'Remove ${widget.entries[i].food.name}',
                  onPressed: () => setState(() => widget.entries.removeAt(i)),
                  icon: const Icon(Icons.remove_circle_outline, color: _muted, size: 21)),
              ])),
            ],
          ]))),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: _add, icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Food'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46))),
        const SizedBox(height: 14),
        _Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Meal Totals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _MacroRow(totals, showIcons: true),
          ]))),
        const SizedBox(height: 15),
        FilledButton(onPressed: saving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: _orange, minimumSize: const Size.fromHeight(48)),
          child: Text(saving ? 'Saving…' : 'Save ${widget.meal}')),
      ])),
    );
  }
}

class _AddFood extends StatefulWidget {
  const _AddFood({required this.store, required this.meal});
  final MealPlanStore store;
  final String meal;
  @override
  State<_AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<_AddFood> {
  final search = TextEditingController();
  String filter = 'All';
  @override
  void dispose() { search.dispose(); super.dispose(); }

  Future<void> _custom() async {
    final fields = List.generate(6, (_) => TextEditingController());
    final form = GlobalKey<FormState>();
    final food = await showDialog<MealFood>(context: context, builder: (dialog) => AlertDialog(
      title: const Text('Add your food'),
      content: Form(key: form, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < fields.length; i++) Padding(padding: const EdgeInsets.only(bottom: 7),
          child: TextFormField(controller: fields[i],
            keyboardType: i < 2 ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: ['Food name', 'Serving size', 'Calories',
                'Protein (g)', 'Carbs (g)', 'Fats (g)'][i]),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Required';
              if (i > 1 && (double.tryParse(value) == null || double.parse(value) < 0)) return 'Enter 0 or more';
              return null;
            })),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')),
        TextButton(onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(dialog, MealFood(name: fields[0].text.trim(), serving: fields[1].text.trim(),
            calories: double.parse(fields[2].text), protein: double.parse(fields[3].text),
            carbs: double.parse(fields[4].text), fats: double.parse(fields[5].text)));
        }, child: const Text('Add')),
      ],
    ));
    for (final field in fields) { field.dispose(); }
    if (food == null) return;
    final saved = await widget.store.saveCustomFood(food);
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save food.')));
      return;
    }
    final quantity = await _quantity(context, food);
    if (quantity != null && mounted) Navigator.pop(context, MealEntry(food, quantity));
  }

  @override
  Widget build(BuildContext context) {
    final favorites = widget.store.favorites;
    final foods = [...widget.store.customFoods, ...exampleFoods].where((food) =>
      food.name.toLowerCase().contains(search.text.trim().toLowerCase()) &&
      (filter == 'All' || filter == 'Favorites' && favorites.contains(food.name) ||
        food.category == filter)).toList();
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: _ink,
        surfaceTintColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Food', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
          Text(widget.meal.toUpperCase(), style: const TextStyle(
            fontSize: 10, letterSpacing: 1.3, color: _muted)),
        ]),
        actions: [IconButton(tooltip: 'Close food search',
          onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 19))]),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 8), child: TextField(
          controller: search, onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: 'Search foods or saved foods',
            prefixIcon: const Icon(Icons.search),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))))),
        SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18), children: [
          for (final category in ['All', 'Favorites', 'Protein', 'Carbs', 'Fats', 'Vegetables'])
            Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
              label: Text(category, style: const TextStyle(fontSize: 11)),
              selected: filter == category, selectedColor: _orange,
              labelStyle: TextStyle(color: filter == category ? Colors.white : _ink),
              onSelected: (_) => setState(() => filter = category))),
        ])),
        const Padding(padding: EdgeInsets.fromLTRB(18, 9, 18, 10),
          child: Text('Examples are estimates. Enter your food label values for accuracy.',
            style: TextStyle(fontSize: 11, color: _muted))),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 18), children: [
          for (final food in foods) Padding(padding: const EdgeInsets.only(bottom: 7),
            child: _FoodRow(food: food,
              detail: '${food.serving} · ${food.calories.round()} kcal · '
                '${food.protein.round()}g P · ${food.carbs.round()}g C · ${food.fats.round()}g F',
              action: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: 'Toggle favorite',
                  icon: Icon(favorites.contains(food.name) ? Icons.favorite : Icons.favorite_border,
                    size: 18, color: _orange),
                  onPressed: () async {
                    await widget.store.toggleFavorite(food.name);
                    if (mounted) setState(() {});
                  }),
                IconButton(tooltip: 'Add ${food.name}',
                  icon: const Icon(Icons.add_circle_outline, color: _orange),
                  onPressed: () async {
                    final quantity = await _quantity(context, food);
                    if (quantity != null && mounted) Navigator.pop(context, MealEntry(food, quantity));
                  }),
              ]))),
          if (foods.isEmpty) const Padding(padding: EdgeInsets.all(18),
            child: Text('No foods found. Add your own food below.', style: TextStyle(color: _muted))),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
          child: OutlinedButton.icon(onPressed: _custom,
            icon: const Icon(Icons.add), label: const Text('Add your own food'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)))),
      ])),
    );
  }
}

Future<MealMacros?> _editMacros(BuildContext context, MealMacros current, String title) async {
  final fields = [current.calories, current.protein, current.carbs, current.fats]
      .map((value) => TextEditingController(text: value.round().toString())).toList();
  final result = await showDialog<MealMacros>(context: context, builder: (dialog) => AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < 4; i++) TextField(controller: fields[i],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: ['Calories', 'Protein (g)', 'Carbs (g)', 'Fats (g)'][i])),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')),
      TextButton(onPressed: () {
        final values = fields.map((field) => double.tryParse(field.text.trim())).toList();
        if (values.any((value) => value == null || value < 0)) return;
        Navigator.pop(dialog, MealMacros(values[0]!, values[1]!, values[2]!, values[3]!));
      }, child: const Text('Save')),
    ],
  ));
  for (final field in fields) { field.dispose(); }
  return result;
}

Future<double?> _quantity(BuildContext context, MealFood food) async {
  final controller = TextEditingController(text: '1');
  final value = await showDialog<double>(context: context, builder: (dialog) => AlertDialog(
    title: Text(food.name),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Per ${food.serving}: ${food.calories.round()} kcal · '
        '${food.protein.round()}g protein · ${food.carbs.round()}g carbs · ${food.fats.round()}g fats',
        style: const TextStyle(color: _muted, fontSize: 12)),
      const SizedBox(height: 10),
      TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Number of servings')),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')),
      TextButton(onPressed: () {
        final quantity = double.tryParse(controller.text.trim());
        if (quantity != null && quantity > 0 && quantity <= 100) Navigator.pop(dialog, quantity);
      }, child: const Text('Add')),
    ],
  ));
  controller.dispose();
  return value;
}

class _MacroRow extends StatelessWidget {
  const _MacroRow(this.value, {this.goal, this.showIcons = false});
  final MealMacros value;
  final MealMacros? goal;
  final bool showIcons;
  @override
  Widget build(BuildContext context) => Row(children: [
    for (final item in [
      ('Calories', value.calories, goal?.calories, 'kcal', Icons.local_fire_department_outlined, _orange),
      ('Protein', value.protein, goal?.protein, 'g', Icons.fitness_center_outlined, const Color(0xFFE55642)),
      ('Carbs', value.carbs, goal?.carbs, 'g', Icons.grain_outlined, const Color(0xFFE9A31B)),
      ('Fats', value.fats, goal?.fats, 'g', Icons.water_drop_outlined, const Color(0xFF489FCD)),
    ]) Expanded(child: Column(children: [
      if (showIcons) ...[
        Icon(item.$5, color: item.$6, size: 19),
        const SizedBox(height: 6),
      ],
      FittedBox(child: Text(item.$3 == null ? '${item.$2.round()}'
        : '${item.$2.round()}/${item.$3!.round()}',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      Text(item.$4, style: const TextStyle(fontSize: 10, color: _muted)),
      const SizedBox(height: 4),
      Text(item.$1, style: const TextStyle(fontSize: 10, color: _muted)),
    ])),
  ]);
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.labels, required this.selected, required this.onChanged});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: const Color(0xFFF0F2F5),
      borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      for (var i = 0; i < labels.length; i++) Expanded(child: Semantics(
        button: true, selected: selected == i,
        child: InkWell(onTap: () => onChanged(i), borderRadius: BorderRadius.circular(11),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut, height: 44, alignment: Alignment.center,
            decoration: BoxDecoration(color: selected == i ? _orange : Colors.transparent,
              borderRadius: BorderRadius.circular(11)),
            child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: selected == i
                ? FontWeight.w600 : FontWeight.w500,
                color: selected == i ? Colors.white : _ink)))))),
    ]),
  );
}

class _MealHero extends StatelessWidget {
  const _MealHero({required this.meal});
  final String meal;

  @override
  Widget build(BuildContext context) {
    final isBreakfast = meal == 'Breakfast';
    final isLunch = meal == 'Lunch';
    return Container(
      constraints: const BoxConstraints(minHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, Color(0xFFFFF0E8)]),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF2E8E3))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isBreakfast ? 'FUEL YOUR MORNING' : isLunch ? 'POWER THROUGH' : 'RECOVER & REBUILD',
            style: const TextStyle(color: _orange, fontSize: 10, letterSpacing: 1.5,
              fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(isBreakfast ? 'A better morning builds a stronger you.'
              : isLunch ? 'Good fuel. Better performance.' : 'End the day stronger.',
            style: const TextStyle(color: _ink, fontSize: 15,
              height: 1.27, fontWeight: FontWeight.w500)),
        ])),
        const SizedBox(width: 10),
        CircleAvatar(radius: 30, backgroundColor: Colors.white,
          child: Icon(isBreakfast ? Icons.free_breakfast_outlined
            : isLunch ? Icons.lunch_dining_outlined : Icons.dinner_dining_outlined,
            color: _orange, size: 27)),
      ]),
    );
  }
}

class _SuggestedMealRow extends StatelessWidget {
  const _SuggestedMealRow({required this.suggestion, required this.onAdd});
  final _MealSuggestion suggestion;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final total = MealMacros.total(suggestion.entries);
    return _Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(children: [
        const CircleAvatar(radius: 19, backgroundColor: Color(0xFFFFF0E7),
          child: Icon(Icons.restaurant_menu_outlined, size: 18, color: _orange)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(suggestion.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(suggestion.entries.map((entry) => entry.food.name).join(', '),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: _muted)),
          Text('${total.calories.round()} kcal · ${total.protein.round()}g P · '
            '${total.carbs.round()}g C · ${total.fats.round()}g F',
            style: const TextStyle(fontSize: 10, color: _muted)),
        ])),
        IconButton(tooltip: 'Add ${suggestion.name}', onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, size: 21, color: _orange)),
      ])));
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.food, required this.detail, required this.action});
  final MealFood food;
  final String detail;
  final Widget action;
  @override
  Widget build(BuildContext context) => _Card(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    child: Row(children: [
      const CircleAvatar(radius: 17, backgroundColor: Color(0xFFFFF0E7),
        child: Icon(Icons.restaurant_outlined, color: _orange, size: 18)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(food.name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, color: _muted)),
      ])),
      action,
    ]),
  ));
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE9EBEE))),
    child: child,
  );
}
