import 'package:intl/intl.dart';


class TimeFormatHelper {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date); //western date format
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('HH:mm ,MMM dd, yyyy').format(date);  // Example: 05 May, 2025 14:30
  }


  static String formatDateWithHifen(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String dateMountFormat(DateTime date) {
    return DateFormat('dd\n MMM ').format(date);
  }

  static String timeFormat(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }


  static String timeWithAMPM( DateTime time){
    // DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);

    String formattedTime = DateFormat('h:mm a').format(time.add(const Duration(hours: 6)));
    return formattedTime;
  }


 static String getDayName(String dateString) {
      DateTime dateTime = DateTime.parse(dateString).toLocal(); // Local timezone
      return DateFormat('EEEE').format(dateTime); // Full day name
  }


   static String getDate(String dateString) {
      DateTime dateTime = DateTime.parse(dateString).toLocal(); // Local timezone
      return DateFormat('dd').format(dateTime); // Only day (date)
  }

  static String getMonth(String dateString) {
    DateTime dateTime = DateTime.parse(dateString).toLocal(); // Local timezone
    return DateFormat('MMMM').format(dateTime); // Only day (date)
  }

  static String formatMonthOrDate(String date) {
    DateTime dateTime = DateTime.parse(date).toLocal();

    return DateFormat('MMM d').format(dateTime);
  }

  static String getTimeAgo(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';

    final date = DateTime.parse(isoDate).toLocal();
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'uploaded just now';
    if (diff.inMinutes < 60) return 'uploaded ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'uploaded ${diff.inHours} hr ago';
    if (diff.inDays < 7) return 'uploaded ${diff.inDays} days ago';
    return 'uploaded on ${formatDate(date)}';
  }



  // static String getTimeAgo(DateTime postTime) {
  //   String time = timeago.format(postTime);
  //   return time
  //       .replaceAll('seconds', 'sec')
  //       .replaceAll('second', 'sec')
  //       .replaceAll('minutes', 'min')
  //       .replaceAll('minute', 'min')
  //       .replaceAll('hours', 'hr')
  //       .replaceAll('hour', 'hr');
  // }



// static Future<void> isFutureDate(String input) async {
  //   try {
  //     DateTime date = DateTime.parse(input);
  //     DateTime now = DateTime.now();
  //     await PrefsHelper.setBool(AppConstants.isFutureDate, date.isAfter(now));
  //   } catch (e) {
  //     PrefsHelper.setBool(AppConstants.isFutureDate, false);
  //   }
  // }
  //


}
