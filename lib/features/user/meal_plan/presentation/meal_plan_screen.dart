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

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});
  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  MealPlanStore? store;
  DateTime date = DateTime.now();
  String? error;

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
        title: const Text('Nutrition', style: TextStyle(fontWeight: FontWeight.w600)),
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
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('DAILY MACRO GOAL', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: Colors.white70)),
              const SizedBox(height: 7),
              const Text('Stay on Track', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 6),
              Text('${total.calories.round()} of ${goal.calories.round()} kcal',
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ])),
            SizedBox(width: 68, height: 68, child: Stack(fit: StackFit.expand, children: [
              CircularProgressIndicator(value: progress.clamp(0, 1).toDouble(),
                  strokeWidth: 5, backgroundColor: Colors.white24, color: _orange),
              Center(child: Text('${(progress * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ])),
            IconButton(
              tooltip: 'Edit daily goals',
              onPressed: () async {
                final updated = await _editMacros(context, goal, 'Daily targets');
                if (updated != null && await data.saveDailyTarget(updated) && mounted) setState(() {});
              },
              icon: const Icon(Icons.tune, color: Colors.white70, size: 18),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: _MacroRow(total, goal: goal))),
        const SizedBox(height: 9),
        Text('Remaining: ${(goal.calories - total.calories).clamp(0, double.infinity).round()} kcal · '
            '${(goal.protein - total.protein).clamp(0, double.infinity).round()}g protein · '
            '${(goal.carbs - total.carbs).clamp(0, double.infinity).round()}g carbs · '
            '${(goal.fats - total.fats).clamp(0, double.infinity).round()}g fats',
            style: const TextStyle(color: _muted, fontSize: 11, height: 1.4)),
        const SizedBox(height: 15),
        _Card(child: SwitchListTile.adaptive(
          title: const Text('Macro reminders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: const Text('Keep your reminder preference', style: TextStyle(fontSize: 11)),
          value: data.remindersEnabled,
          activeColor: _orange,
          onChanged: (value) async {
            if (await data.setRemindersEnabled(value) && mounted) setState(() {});
          },
        )),
        const SizedBox(height: 28),
        const Text('Meal prep', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _ink)),
        const SizedBox(height: 3),
        const Text('PLAN · PREP · PERFORM', style: TextStyle(color: _muted, letterSpacing: 1.4, fontSize: 10)),
        const SizedBox(height: 14),
        for (final meal in _meals)
          Padding(padding: const EdgeInsets.only(bottom: 9), child: _Card(child: ListTile(
            onTap: () => _open(meal),
            leading: CircleAvatar(backgroundColor: const Color(0xFFFFF0E7),
              child: Icon(meal == 'Breakfast' ? Icons.free_breakfast_outlined
                  : meal == 'Lunch' ? Icons.lunch_dining_outlined : Icons.dinner_dining_outlined, color: _orange)),
            title: Text(meal, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(data.readMeal(date, meal).isEmpty
                ? 'Add your ${meal.toLowerCase()} prep'
                : '${data.readMeal(date, meal).length} foods · '
                  '${MealMacros.total(data.readMeal(date, meal)).calories.round()} kcal',
                style: const TextStyle(fontSize: 12, color: _muted)),
            trailing: const Icon(Icons.chevron_right, color: _muted),
          ))),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: () => _open('Breakfast'), icon: const Icon(Icons.add),
          label: const Text('Build My Meal Prep'),
          style: FilledButton.styleFrom(backgroundColor: _orange, minimumSize: const Size.fromHeight(48))),
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
  bool saving = false;

  @override
  void initState() {
    super.initState();
    entries = widget.store.readMeal(widget.date, widget.meal);
    goal = widget.store.readTarget(widget.meal);
  }

  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      if (!await widget.store.saveMeal(widget.date, widget.meal, entries)) {
        throw StateError('Could not save this meal');
      }
      if (mounted) Navigator.pop(context, true);
    } catch (cause) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$cause')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _add() async {
    final selected = await Navigator.push<MealEntry>(
      context, MaterialPageRoute(builder: (_) => _AddFood(store: widget.store, meal: widget.meal)),
    );
    if (selected != null && mounted) setState(() => entries.add(selected));
  }

  Future<void> _editGoal() async {
    final updated = await _editMacros(context, goal, '${widget.meal} targets');
    if (updated != null && await widget.store.saveTarget(widget.meal, updated) && mounted) {
      setState(() => goal = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final macros = MealMacros.total(entries);
    final suggestions = exampleFoods.where((food) => widget.meal == 'Breakfast'
      ? ['Oatmeal (cooked)', 'Egg Whites', 'Whole Egg', 'Banana', 'Greek Yogurt (Plain)'].contains(food.name)
      : widget.meal == 'Lunch'
          ? ['Chicken Breast', 'Brown Rice (cooked)', 'Quinoa (cooked)', 'Ground Turkey (93%)', 'Broccoli (steamed)'].contains(food.name)
          : ['Salmon (Atlantic)', 'Sweet Potato (baked)', 'Lean Steak (sirloin)', 'Whole Grain Pasta', 'Asparagus'].contains(food.name)).toList();
    final options = tab == 0 ? suggestions : tab == 1 ? widget.store.customFoods : <MealFood>[];
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(backgroundColor: _ink, foregroundColor: Colors.white,
        title: Text(widget.meal, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [TextButton(onPressed: _save, child: Text(saving ? 'Saving…' : 'Save',
          style: const TextStyle(color: _orange)))],
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), children: [
        Text(DateFormat('EEEE, MMM d').format(widget.date),
          style: const TextStyle(fontSize: 12, color: _muted)),
        const SizedBox(height: 14),
        _Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(children: [Expanded(child: Text('Target Macros (${widget.meal})',
            style: const TextStyle(fontWeight: FontWeight.w600))),
            TextButton(onPressed: _editGoal, child: const Text('Edit', style: TextStyle(color: _orange)))]),
          _MacroRow(goal),
        ]))),
        const SizedBox(height: 12),
        _Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Meal Summary', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12), _MacroRow(macros),
          const SizedBox(height: 9),
          Text('Remaining ${(goal.calories - macros.calories).clamp(0, double.infinity).round()} kcal',
            style: const TextStyle(color: _muted, fontSize: 12)),
        ]))),
        const SizedBox(height: 21),
        const Text('Your Meal', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (entries.isEmpty) const Padding(padding: EdgeInsets.only(bottom: 12),
          child: Text('No foods yet. Add a food to begin.', style: TextStyle(color: _muted))),
        for (var i = 0; i < entries.length; i++)
          Padding(padding: const EdgeInsets.only(bottom: 7), child: _FoodRow(
            food: entries[i].food,
            detail: '${entries[i].quantity.toStringAsFixed(entries[i].quantity % 1 == 0 ? 0 : 1)} × ${entries[i].food.serving}',
            action: IconButton(tooltip: 'Remove food', icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() => entries.removeAt(i))),
          )),
        OutlinedButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add Food')),
        const SizedBox(height: 20),
        const Text('Choose food', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 9),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child:
          SegmentedButton<int>(showSelectedIcon: false,
            segments: const [ButtonSegment(value: 0, label: Text('Suggested')),
              ButtonSegment(value: 1, label: Text('My Foods')),
              ButtonSegment(value: 2, label: Text('Recipes'))],
            selected: {tab}, onSelectionChanged: (value) => setState(() => tab = value.first))),
        const SizedBox(height: 9),
        if (tab == 0) const Text('Examples are estimates. Check your food label.',
          style: TextStyle(color: _muted, fontSize: 11)),
        if (options.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(tab == 2 ? 'No recipes saved yet. Add your own food below.'
              : 'Your foods appear here after you save them.',
            style: const TextStyle(color: _muted, fontSize: 12))),
        for (final food in options)
          Padding(padding: const EdgeInsets.only(top: 7), child: _FoodRow(
            food: food, detail: '${food.serving} · ${food.calories.round()} kcal',
              action: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: 'Toggle favorite',
                  icon: Icon(widget.store.favorites.contains(food.name)
                      ? Icons.favorite : Icons.favorite_border, size: 18, color: _orange),
                  onPressed: () async {
                    await widget.store.toggleFavorite(food.name);
                    if (mounted) setState(() {});
                  }),
                IconButton(tooltip: 'Add ${food.name}',
                  icon: const Icon(Icons.add_circle_outline, color: _orange),
                  onPressed: () async {
                    final quantity = await _quantity(context, food);
                    if (quantity != null && mounted) setState(() => entries.add(MealEntry(food, quantity)));
                  }),
              ]),
          )),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add Custom Food')),
        const SizedBox(height: 12),
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
      appBar: AppBar(title: Text('Add Food · ${widget.meal}'),
        backgroundColor: _ink, foregroundColor: Colors.white),
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
  const _MacroRow(this.value, {this.goal});
  final MealMacros value;
  final MealMacros? goal;
  @override
  Widget build(BuildContext context) => Row(children: [
    for (final item in [
      ('Calories', value.calories, goal?.calories, 'kcal'),
      ('Protein', value.protein, goal?.protein, 'g'),
      ('Carbs', value.carbs, goal?.carbs, 'g'),
      ('Fats', value.fats, goal?.fats, 'g'),
    ]) Expanded(child: Column(children: [
      FittedBox(child: Text(item.$3 == null ? '${item.$2.round()}'
        : '${item.$2.round()}/${item.$3!.round()}',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      Text(item.$4, style: const TextStyle(fontSize: 10, color: _muted)),
      const SizedBox(height: 4),
      Text(item.$1, style: const TextStyle(fontSize: 10, color: _muted)),
    ])),
  ]);
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
