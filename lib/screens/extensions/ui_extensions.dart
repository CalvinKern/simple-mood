import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_mood/models/mood.dart';

extension DateFormatting on DateTime {
  String fullFormat() => (DateFormat.yMd()..add_jm()).format(this);

  DateTime toMidnight() => DateTime(this.year, this.month, this.day);
}

extension MoodResource on MoodRating {
  int index() => MoodRating.values.toList().indexOf(this);

  // TODO: Could have rating name be localized
  Icon asIcon({double size = 48}) => Icon(iconData(), size: size, semanticLabel: name, color: materialColor());

  Color materialColor() {
    switch (this) {
      case MoodRating.miserable:
        return Colors.red;
      case MoodRating.unhappy:
        return Colors.orange;
      case MoodRating.plain:
        return Colors.yellow;
      case MoodRating.happy:
        return Colors.lightGreen;
      case MoodRating.ecstatic:
        return Colors.green;
      default:
        throw ArgumentError.value(this);
    }
  }

  IconData iconData() {
    switch (this) {
      case MoodRating.miserable:
        return Icons.sentiment_very_dissatisfied;
      case MoodRating.unhappy:
        return Icons.sentiment_dissatisfied;
      case MoodRating.plain:
        return Icons.sentiment_neutral;
      case MoodRating.happy:
        return Icons.sentiment_satisfied;
      case MoodRating.ecstatic:
        return Icons.sentiment_very_satisfied;
      default:
        throw ArgumentError.value(this);
    }
  }
}
