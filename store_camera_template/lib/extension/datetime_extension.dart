import 'package:intl/intl.dart';

extension DateTimeExtention on DateTime {
  // ignore: non_constant_identifier_names
  String format_yyyyMMddHHdd([String divider = '.']) =>
      DateFormat('yyyy${divider}MM${divider}dd HH:mm').format(this);

  DateTime subtractMonths(int value) {
    var y = value ~/ 12;
    var m = value - y * 12;

    if (m > month) {
      y += 1;
      m = month - m;
    }

    final subtractDateTime = DateTime(year - y, month - m, day);
    return subtract(Duration(days: difference(subtractDateTime).inDays));
  }

  bool equalDay(DateTime other) {
    return difference(other).inDays == 0;
  }
}
