import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';

// TODO: Massive overhaul, convert all DateTime usage() to DateTime.utc() to handle historic events better.
extension DateFormatting on DateTime {
  String simpleFormat() => this == null ? null : DateFormat.yMd().format(this);

  String readableFormat() => this == null ? null : DateFormat.yMMMMd().format(this);

  String fullFormat() => this == null ? null : (DateFormat.yMd()..add_jm()).format(this);

  // Pass in a 'now' to get the year added to the month format
  String monthFormat({DateTime now}) {
    if (this == null) return null;
    if (now == null || now.year == this.year) return DateFormat.MMMM().format(this);
    return DateFormat.yMMM().format(this);
  }

  DateTime toMidnight() => this == null ? null : DateTime(this.year, this.month, this.day);

  DateTime toStartOfMonth() => this == null ? null : DateTime(year, month, 1);

  DateTime toStartOfWeek() {
    if (this == null) return null;

    final firstDay = DateFormat().dateSymbols.FIRSTDAYOFWEEK + 1; // DateTime weekday has monday start at 1
    DateTime start = this;
    while (start.weekday != firstDay) {
      start = start.subtract(Duration(days: 1));
    }
    return start.toMidnight();
  }

  DateTime toEndOfMonth() {
    return DateTime(year, month + 1).subtract(Duration(days: 1));
  }

  /// This is useful to add days directly to a date, rather than a duration. A duration of a week could vary depending
  /// on daylight savings, etc..., this applies a straight 7 days (and it's okay if it goes over)
  DateTime addWeeks(int weeksToAdd) {
    return DateTime(year, month, day + (7 * weeksToAdd));
  }
}

extension MoodResource on MoodRating {
  int index() => MoodRating.values.toList().indexOf(this);

  Icon asIcon(BuildContext context, {double size = 48}) => Icon(
        iconData(),
        size: size,
        semanticLabel: readableString(context),
        color: materialColor(),
      );

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
        return Colors.grey;
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
        return Icons.face;
    }
  }

  String readableString(BuildContext context) {
    switch (this) {
      case MoodRating.miserable:
        return AppLocalizations.of(context).ratingMiserable;
      case MoodRating.unhappy:
        return AppLocalizations.of(context).ratingUnhappy;
      case MoodRating.plain:
        return AppLocalizations.of(context).ratingPlain;
      case MoodRating.happy:
        return AppLocalizations.of(context).ratingHappy;
      case MoodRating.ecstatic:
        return AppLocalizations.of(context).ratingEcstatic;
      default:
        return AppLocalizations.of(context).ratingMissing;
    }
  }
}
