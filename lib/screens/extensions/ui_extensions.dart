import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String fullFormat() => (DateFormat.yMd()..add_jm()).format(this);
}