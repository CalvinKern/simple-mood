import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/dashboard/delete_dialog.dart';
import 'package:simple_mood/screens/dashboard/rating_picker.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _monthsToLoad = 5;

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo>(
      builder: (context, repo, child) {
        if (repo?.readyToLoad() != true) {
          return Center(child: CircularProgressIndicator());
        }
        return FutureBuilder(
          // Set the future every time the consumer builder is called so we refresh data
          // TODO: Load more data (paging, and stop at the oldest entry (find the min date through a sql query))
          future: _getHistoricalMoods(repo),
          builder: (context, AsyncSnapshot<List<_MonthData>> snapshot) {
            if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.data.isEmpty || snapshot.data.every((element) => element.moodsByWeek.isEmpty)) {
              return Center(child: Text(AppLocalizations.of(context).noMoods));
            } else {
              return _CalendarBody(moodsByMonth: snapshot.data);
            }
          },
        );
      },
    );
  }

  Future<List<_MonthData>> _getHistoricalMoods(MoodRepo repo) async {
    final months = List<_MonthData>();
    DateTime startDate = DateTime.now().toStartOfMonth();
    DateTime endDate = DateTime.now();
    for (int i = 0; i < _monthsToLoad; i++) {
      final future = await repo.getMoods(startDate, endDate);
      months.add(_MonthData.fromMonthData(startDate, future));
      endDate = startDate.subtract(Duration(days: 1)).toMidnight();
      startDate = endDate.toStartOfMonth();
    }
    return months;
  }
}

class _CalendarBody extends StatelessWidget {
  final List<_MonthData> moodsByMonth;

  const _CalendarBody({Key key, this.moodsByMonth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Will this be more performant with SliverList?
    return ListView(
      shrinkWrap: true,
      reverse: true,
      children: moodsByMonth.map((moods) => _MoodMonth(data: moods)).toList(),
    );
  }
}

class _MoodMonth extends StatelessWidget {
  final _MonthData data;

  const _MoodMonth({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(data.start.monthFormat(), style: Theme.of(context).textTheme.headline4),
        ...data.moodsByWeek.map((e) => _MoodWeek(moods: e)).toList(),
      ],
    );
  }
}

class _MoodWeek extends StatelessWidget {
  final List<Mood> moods;

  const _MoodWeek({Key key, this.moods}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((e) => e == null ? Expanded(child: Container()) : _MoodDay(mood: e)).toList(),
    );
  }
}

class _MoodDay extends StatelessWidget {
  final Mood mood;

  const _MoodDay({Key key, @required this.mood}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MaterialButton(
//        child: Text(mood.date.day.toString()), // Useful for debugging
        child: mood.rating.asIcon(context),
        padding: EdgeInsets.symmetric(horizontal: 4),
        onLongPress: () => mood.rating == MoodRating.missing ? null : _askDeleteMood(context),
        onPressed: () => _askRateMood(context),
      ),
    );
  }

  _askDeleteMood(BuildContext context) async {
    await DeleteDialog.asDialog(context, mood);
  }

  _askRateMood(BuildContext context) async {
    await RatingPicker.asDialog(context, mood);
  }
}

/// A temp class to hold basic calendar logic for getting data ready for the view. Is not pretty/efficient, will improve later
class _MonthData {
  final DateTime start;
  final List<List<Mood>> moodsByWeek;

  _MonthData._(this.start, this.moodsByWeek);

  /// Split a month worth of mood data into a list of moods by week (each list in the list represents 7 days of moods).
  /// Any missing days will be generated as "missing".
  factory _MonthData.fromMonthData(DateTime start, List<Mood> moods) {
    final today = DateTime.now().toMidnight();
    final firstDay = start.toStartOfWeek();
    final nextMonth = start.toEndOfMonth();
    final lastDay = today.isAfter(nextMonth) ? nextMonth : today;
    final daysBetween = lastDay.toStartOfWeek().difference(firstDay).inDays;
    final weeksToShow = (daysBetween / 7).ceil() + 1;

    final List<List<Mood>> monthMoods = List.generate(weeksToShow, (index) => List<Mood>().toList());
    moods.forEach((element) {
      final days = element.date.toStartOfWeek().difference(firstDay).inDays;
      final weekIndex = days ~/ 7;
      monthMoods[weekIndex].add(element);
    });
    final realMonths = List<List<Mood>>(monthMoods.length).toList();
    for (int i = 0; i < monthMoods.length; i++) {
      final weekStart = i == 0 ? start : start.add(Duration(days: 7 * i)).toStartOfWeek();
      realMonths[i] = _generateMissingData(weekStart, monthMoods[i]);
    }

    return _MonthData._(start, realMonths);
  }

  /// From a weeks worth of mood data, return a full week of moods generating any "missing" entries
  static List<Mood> _generateMissingData(DateTime weekStart, List<Mood> moods) {
    final firstDayOfWeek = weekStart.toStartOfWeek();
    final weekMoods = List<Mood>(7);

    // Add any existing moods
    moods.forEach((element) {
      final day = element.date.toMidnight().difference(firstDayOfWeek).inDays;
      weekMoods[day] = element;
    });

    // Find each missing day in the week and add a missing mood
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = firstDayOfWeek.add(Duration(days: i)).toMidnight();

      if (date.isBefore(weekStart)) continue; // Check if we're before this month
      if (date.isAfter(now) || date.month != weekStart.month) break; // Check if we're done with this month

      weekMoods[i] = weekMoods[i] ??
          Mood((b) => b
            ..id = 0
            ..date = date
            ..rating = MoodRating.missing);
    }
    return weekMoods;
  }
}
