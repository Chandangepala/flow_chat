import 'package:intl/intl.dart';

class FormatDataTime{
  static String getFormattedDateTime(String timestamp) {
    DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(
      int.parse(timestamp),
    );
    String formattedDate = DateFormat('HH:mm').format(dateTime);
    return formattedDate;
  }
}