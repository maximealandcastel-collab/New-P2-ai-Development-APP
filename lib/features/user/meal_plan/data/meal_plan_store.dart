import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Nutrition values are per serving. Catalog entries are examples, not live
/// food-database results; users can enter the values from their food label.
class MealFood {
  const MealFood({
    required this.name,
    required this.serving,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.category = 'Common',
    this.favorite = false,
  });

  final String name;
  final String serving;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String category;
  final bool favorite;

  MealFood copyWith({bool? favorite}) => MealFood(
        name: name,
        serving: serving,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        category: category,
        favorite: favorite ?? this.favorite,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'serving': serving,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'category': category,
        'favorite': favorite,
      };

  factory MealFood.fromJson(Map<String, dynamic> json) => MealFood(
        name: json['name']?.toString() ?? '',
        serving: json['serving']?.toString() ?? '1 serving',
        calories: (json['calories'] as num?)?.toDouble() ?? 0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
        fats: (json['fats'] as num?)?.toDouble() ?? 0,
        category: json['category']?.toString() ?? 'Common',
        favorite: json['favorite'] == true,
      );
}

class MealEntry {
  const MealEntry(this.food, this.quantity);

  final MealFood food;
  final double quantity;

  Map<String, dynamic> toJson() => {
        'food': food.toJson(),
        'quantity': quantity,
      };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        MealFood.fromJson(Map<String, dynamic>.from(json['food'] as Map)),
        (json['quantity'] as num?)?.toDouble() ?? 1,
      );
}

class MealMacros {
  const MealMacros(this.calories, this.protein, this.carbs, this.fats);

  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  static const zero = MealMacros(0, 0, 0, 0);

  MealMacros operator +(MealMacros other) => MealMacros(
        calories + other.calories,
        protein + other.protein,
        carbs + other.carbs,
        fats + other.fats,
      );

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      };

  factory MealMacros.fromJson(Map<String, dynamic> json) => MealMacros(
        (json['calories'] as num?)?.toDouble() ?? 0,
        (json['protein'] as num?)?.toDouble() ?? 0,
        (json['carbs'] as num?)?.toDouble() ?? 0,
        (json['fats'] as num?)?.toDouble() ?? 0,
      );

  static MealMacros total(Iterable<MealEntry> entries) {
    var result = zero;
    for (final entry in entries) {
      result += MealMacros(
        entry.food.calories * entry.quantity,
        entry.food.protein * entry.quantity,
        entry.food.carbs * entry.quantity,
        entry.food.fats * entry.quantity,
      );
    }
    return result;
  }
}

class MealPlanStore {
  MealPlanStore._(this._prefs, this.accountId);

  final SharedPreferences _prefs;
  final String accountId;

  static Future<MealPlanStore> open(String accountId) async =>
      MealPlanStore._(await SharedPreferences.getInstance(), accountId);

  String get _prefix => 'meal_plan_v1:$accountId:';

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _mealKey(DateTime date, String meal) =>
      '$_prefix${dateKey(date)}:$meal';

  List<MealEntry> readMeal(DateTime date, String meal) {
    try {
      final raw = _prefs.getString(_mealKey(date, meal));
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((item) => MealEntry.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((entry) => entry.food.name.isNotEmpty && entry.quantity > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveMeal(DateTime date, String meal, List<MealEntry> entries) =>
      _prefs.setString(
        _mealKey(date, meal),
        jsonEncode(entries.map((entry) => entry.toJson()).toList()),
      );

  MealMacros readTarget(String meal) {
    const defaults = {
      'Breakfast': MealMacros(500, 40, 60, 15),
      'Lunch': MealMacros(600, 50, 70, 20),
      'Dinner': MealMacros(700, 60, 90, 25),
    };
    try {
      final raw = _prefs.getString('$_prefix$meal:target');
      return raw == null
          ? defaults[meal] ?? MealMacros.zero
          : MealMacros.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return defaults[meal] ?? MealMacros.zero;
    }
  }

  Future<bool> saveTarget(String meal, MealMacros target) => _prefs.setString(
        '$_prefix$meal:target',
        jsonEncode(target.toJson()),
      );

  MealMacros get dailyTarget {
    try {
      final raw = _prefs.getString('${_prefix}daily_target');
      return raw == null
          ? const MealMacros(2000, 150, 220, 70)
          : MealMacros.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return const MealMacros(2000, 150, 220, 70);
    }
  }

  Future<bool> saveDailyTarget(MealMacros target) => _prefs.setString(
        '${_prefix}daily_target',
        jsonEncode(target.toJson()),
      );

  bool get remindersEnabled => _prefs.getBool('${_prefix}reminders') ?? true;

  Future<bool> setRemindersEnabled(bool enabled) =>
      _prefs.setBool('${_prefix}reminders', enabled);

  List<MealFood> get customFoods {
    try {
      final raw = _prefs.getString('${_prefix}custom_foods');
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((item) => MealFood.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((food) => food.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCustomFood(MealFood food) async {
    final foods = customFoods.where((item) => item.name != food.name).toList()
      ..add(food);
    return _prefs.setString(
      '${_prefix}custom_foods',
      jsonEncode(foods.map((item) => item.toJson()).toList()),
    );
  }

  Set<String> get favorites =>
      _prefs.getStringList('${_prefix}favorites')?.toSet() ?? <String>{};

  Future<bool> toggleFavorite(String name) {
    final current = favorites;
    if (!current.add(name)) current.remove(name);
    return _prefs.setStringList('${_prefix}favorites', current.toList());
  }
}

/// Approximate examples from the approved workflow. Nothing is silently added
/// to a meal, and the member can enter exact package/recipe values instead.
const exampleFoods = <MealFood>[
  MealFood(name: 'Oatmeal (cooked)', serving: '1 cup', calories: 154, protein: 6, carbs: 27, fats: 3, category: 'Carbs'),
  MealFood(name: 'Egg Whites', serving: '3 large', calories: 51, protein: 11, carbs: 1, fats: 0, category: 'Protein'),
  MealFood(name: 'Whole Egg', serving: '1 large', calories: 72, protein: 6, carbs: 0, fats: 5, category: 'Protein'),
  MealFood(name: 'Chicken Breast', serving: '4 oz', calories: 187, protein: 35, carbs: 0, fats: 4, category: 'Protein'),
  MealFood(name: 'Banana', serving: '1 medium', calories: 105, protein: 1, carbs: 27, fats: 0, category: 'Carbs'),
  MealFood(name: 'Greek Yogurt (Plain)', serving: '1 cup', calories: 130, protein: 23, carbs: 9, fats: 0, category: 'Protein'),
  MealFood(name: 'Brown Rice (cooked)', serving: '1 cup', calories: 216, protein: 5, carbs: 45, fats: 2, category: 'Carbs'),
  MealFood(name: 'Quinoa (cooked)', serving: '1 cup', calories: 222, protein: 8, carbs: 39, fats: 4, category: 'Carbs'),
  MealFood(name: 'Ground Turkey (93%)', serving: '4 oz', calories: 170, protein: 22, carbs: 0, fats: 9, category: 'Protein'),
  MealFood(name: 'Broccoli (steamed)', serving: '1 cup', calories: 55, protein: 4, carbs: 11, fats: 0, category: 'Vegetables'),
  MealFood(name: 'Avocado', serving: '1/2 medium', calories: 114, protein: 1, carbs: 6, fats: 10, category: 'Fats'),
  MealFood(name: 'Sweet Potato (baked)', serving: '1 medium', calories: 135, protein: 2, carbs: 31, fats: 0, category: 'Carbs'),
  MealFood(name: 'Salmon (Atlantic)', serving: '4 oz', calories: 233, protein: 25, carbs: 0, fats: 14, category: 'Protein'),
  MealFood(name: 'Lean Steak (sirloin)', serving: '4 oz', calories: 240, protein: 34, carbs: 0, fats: 10, category: 'Protein'),
  MealFood(name: 'Whole Grain Pasta', serving: '1 cup', calories: 174, protein: 7, carbs: 37, fats: 1, category: 'Carbs'),
  MealFood(name: 'Asparagus', serving: '1 cup', calories: 27, protein: 3, carbs: 5, fats: 0, category: 'Vegetables'),
  MealFood(name: 'Olive Oil', serving: '1 tbsp', calories: 119, protein: 0, carbs: 0, fats: 14, category: 'Fats'),
];
