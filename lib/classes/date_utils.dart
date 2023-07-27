import 'package:intl/intl.dart';

class DateUtil {
  static String format(DateTime dt) {
    return DateFormat("dd/MM/yyyy").format(dt);
  }
}