import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/services/api_service.dart';
import 'package:pler_to_pler_app/features/home/presentation/controllers/trainer_home_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';

class CreateMealPlanScreen extends StatefulWidget {
  final ClientInvoiceModel client;
  const CreateMealPlanScreen({super.key, required this.client});
  @override State<CreateMealPlanScreen> createState() => _CreateMealPlanScreenState();
}

class _CreateMealPlanScreenState extends State<CreateMealPlanScreen> {
  final title = TextEditingController();
  final goal = TextEditingController();
  final notes = TextEditingController();
  final meals = <_MealDraft>[_MealDraft('Breakfast'), _MealDraft('Lunch'), _MealDraft('Dinner')];
  int weeks = 1;
  bool saving = false;

  @override void dispose() { title.dispose(); goal.dispose(); notes.dispose(); for (final meal in meals) { meal.dispose(); } super.dispose(); }

  Future<void> save() async {
    final clientId = widget.client.userId?.id;
    if (clientId == null || clientId.isEmpty) { Get.snackbar('Client unavailable', 'This client is missing an account ID.'); return; }
    if (title.text.trim().isEmpty) { Get.snackbar('Plan name required', 'Name the meal plan before assigning it.'); return; }
    final plan = meals.where((m) => m.foods.text.trim().isNotEmpty).map((m) => '${m.name.text.trim()} (${m.time.text.trim()}): ${m.foods.text.trim()}').join('\n');
    if (plan.isEmpty) { Get.snackbar('Add meal details', 'Enter foods or instructions for at least one meal.'); return; }
    setState(() => saving = true);
    try {
      await Get.find<ApiService>().post(ApiConstants.trainerWorkoutPlanCreate, data: {
        'clientId': clientId, 'title': title.text.trim(), 'description': goal.text.trim(),
        'durationWeeks': weeks, 'daysPerWeek': 7, 'goal': 'nutrition', 'difficulty': 'beginner',
        'weeks': const [], 'nutritionNotes': [plan, notes.text.trim()].where((p) => p.isNotEmpty).join('\n\n'),
      });
      if (Get.isRegistered<TrainerHomeController>()) await TrainerHomeController.to.refresh();
      if (!mounted) return; Get.back(); Get.snackbar('Meal plan assigned', 'Assigned to ${widget.client.clientName}.');
    } catch (error) { Get.snackbar('Could not assign meal plan', error.toString(), snackPosition: SnackPosition.BOTTOM); }
    finally { if (mounted) setState(() => saving = false); }
  }

  InputDecoration decoration(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)));

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create meal plan')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
          CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.12), child: Text(widget.client.clientName.isNotEmpty ? widget.client.clientName[0].toUpperCase() : '?', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('ASSIGNED CLIENT', style: TextStyle(fontSize: 11, color: Colors.grey)), Text(widget.client.clientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]))
        ])),
        const SizedBox(height: 20), const Text('Meal plan name', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7), TextField(controller: title, decoration: decoration('Example: Strength and recovery')),
        const SizedBox(height: 14), const Text('Nutrition goal', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7), TextField(controller: goal, decoration: decoration('Describe the client goal')),
        const SizedBox(height: 14), const Text('Plan duration', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7),
        DropdownButtonFormField<int>(value: weeks, decoration: decoration('Duration'), items: const [1,2,4,8].map((value) => DropdownMenuItem(value: value, child: Text('$value ${value == 1 ? 'week' : 'weeks'}'))).toList(), onChanged: (value) => setState(() => weeks = value ?? 1)),
        const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Daily meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), TextButton.icon(onPressed: () => setState(() => meals.add(_MealDraft('Meal ${meals.length + 1}'))), icon: const Icon(Icons.add), label: const Text('Add meal'))]),
        ...meals.asMap().entries.map((entry) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(children: [
          Row(children: [Expanded(child: TextField(controller: entry.value.name, decoration: decoration('Meal name'))), const SizedBox(width: 8), SizedBox(width: 105, child: TextField(controller: entry.value.time, decoration: decoration('Time'))), if (meals.length > 1) IconButton(onPressed: () => setState(() { final removed=meals.removeAt(entry.key); removed.dispose(); }), icon: const Icon(Icons.close))]),
          const SizedBox(height: 10), TextField(controller: entry.value.foods, maxLines: 3, decoration: decoration('Foods, portions, and preparation instructions'))
        ]))),
        const SizedBox(height: 4), const Text('Trainer notes', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7), TextField(controller: notes, maxLines: 4, decoration: decoration('Hydration, substitutions, allergies, or preparation notes')),
        const SizedBox(height: 24), SizedBox(height: 54, child: FilledButton(onPressed: saving ? null : save, style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary), child: Text(saving ? 'Assigning...' : 'Assign meal plan'))),
      ]),
    );
  }
}

class _MealDraft { _MealDraft(String label) : name=TextEditingController(text: label); final TextEditingController name; final time=TextEditingController(); final foods=TextEditingController(); void dispose(){name.dispose();time.dispose();foods.dispose();} }
