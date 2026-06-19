import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';

class StringFormat {
  StringFormat._();

  static String formatSpecialty(String s) {
    final withSpace = s.replaceAll('_', ' ');
    return withSpace.isEmpty
        ? withSpace
        : withSpace[0].toUpperCase() + withSpace.substring(1);
  }

  static String valueOrNa(String? value) {
    if (value == null || value.trim().isEmpty) return 'N/A';
    return value;
  }

  static String specialtyOrNa(String? specialty) {
    if (specialty == null || specialty.trim().isEmpty) return 'N/A';
    return formatSpecialty(specialty);
  }

  static String listOrNa(List<String>? values) {
    if (values == null || values.isEmpty) return 'N/A';
    return values.join(', ');
  }

  static String formatPrice(SubscriptionPrice? price) {
    if (price?.free == true) return 'Free';
    final premium = price?.premium;
    if (premium == null) return 'N/A';
    return '\$ $premium';
  }
}