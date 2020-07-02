import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/repos/prefs_repo.dart';
import 'package:simple_mood/screens/dashboard/charts/dashboard_card.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class RatingPicker {
  static Future asDialog(BuildContext context, Mood mood) async {
    await showDialog(context: context, child: _RatingDialog(mood: mood));
  }

  static Widget asTodayCard(BuildContext context) {
    return DashboardCard(
      title: AppLocalizations.of(context).addTodaysMood,
      chartHeight: 96,
      child: _ratingButtons(
        context,
        Mood((b) => b..id = 0..date = DateTime.now()..rating = MoodRating.missing),
        horizontalPadding: 4,
      ),
    );
  }

  static Widget _ratingButtons(BuildContext context, Mood mood, {double horizontalPadding, bool popOnRate = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: MoodRating.ratings
          .map((rating) => MaterialButton(
                child: rating.asIcon(context),
                shape: CircleBorder(),
                minWidth: 20,
                padding:
                    horizontalPadding == null ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: horizontalPadding),
                onPressed: () => _addMood(context, mood, rating, popOnRate),
              ))
          .toList(),
    );
  }

  static void _addMood(BuildContext context, Mood oldMood, MoodRating rating, bool popOnRate) async {
    // If it's not missing, we need to update. Otherwise we create and delay notifications (if rated today)
    if (oldMood.rating != MoodRating.missing) {
      await Provider.of<MoodRepo>(context, listen: false).updateMood(oldMood.rebuild((b) => b..rating = rating));
    } else {
      await Provider.of<MoodRepo>(context, listen: false).create(rating, date: oldMood.date);
      if (oldMood.date.toMidnight().isAtSameMomentAs(DateTime.now().toMidnight())) {
        await Provider.of<PrefsRepo>(context, listen: false)
            .delayTodayReminder(AppLocalizations.of(context).dailyReminderNotificationTitle);
      }
    }

    if (popOnRate) {
      Navigator.of(context).pop();
    }
  }
}

class _RatingDialog extends StatelessWidget {
  final Mood mood;

  _RatingDialog({this.mood});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).editMood(mood.date.simpleFormat())),
      content: Flex(direction: Axis.horizontal, children: [RatingPicker._ratingButtons(context, mood, popOnRate: true)]),
      actions: [
        FlatButton(
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase()),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
