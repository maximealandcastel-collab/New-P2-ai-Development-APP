import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/features/user/meal_plan/data/meal_plan_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('saved meal is scoped by account, date, and meal', () async {
    final alice = await MealPlanStore.open('alice');
    final bob = await MealPlanStore.open('bob');
    final day = DateTime(2026, 9, 24);
    final food = const MealFood(
      name: 'Labelled snack', serving: '1 pack',
      calories: 100, protein: 8, carbs: 12, fats: 2,
    );

    expect(await alice.saveMeal(day, 'Breakfast', [MealEntry(food, 1.5)]), isTrue);
    expect(alice.readMeal(day, 'Breakfast').single.quantity, 1.5);
    expect(alice.readMeal(day, 'Lunch'), isEmpty);
    expect(alice.readMeal(day.add(const Duration(days: 1)), 'Breakfast'), isEmpty);
    expect(bob.readMeal(day, 'Breakfast'), isEmpty);

    final total = MealMacros.total(alice.readMeal(day, 'Breakfast'));
    expect(total.calories, 150);
    expect(total.protein, 12);
    expect(total.carbs, 18);
    expect(total.fats, 3);
  });

  test('daily and meal targets remain independent', () async {
    final store = await MealPlanStore.open('member');
    expect(store.dailyTarget.calories, 2000);
    expect(store.readTarget('Breakfast').calories, 500);
    expect(await store.saveTarget('Breakfast', const MealMacros(450, 35, 50, 12)), isTrue);
    expect(store.readTarget('Breakfast').calories, 450);
    expect(store.dailyTarget.calories, 2000);
  });
}
