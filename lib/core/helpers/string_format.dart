
class StringFormat {
  StringFormat._();

  static String formatSpecialty(String s) {
    final withSpace = s.replaceAll('_', ' ');
    return withSpace.isEmpty ? withSpace : withSpace[0].toUpperCase() + withSpace.substring(1);
  }
}