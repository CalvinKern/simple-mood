import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/dashboard/delete_dialog.dart';
import 'package:simple_mood/screens/dashboard/rating_picker.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo>(builder: (context, repo, child) {
      if (repo?.readyToLoad() != true) {
        return Center(child: CircularProgressIndicator());
      }
      return _CalendarBody(moodRepo: repo);
    });
  }
}

class _CalendarBody extends StatefulWidget {
  final MoodRepo moodRepo;

  const _CalendarBody({Key key, @required this.moodRepo}) : super(key: key);

  @override
  _CalendarBodyState createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  static const _DEFAULT_MONTH_COUNT = 3;

  Future<List<_MonthData>> _future;
  Future<DateTime> _oldestDate;
  int _monthsToLoad = _DEFAULT_MONTH_COUNT;
  bool _doneLoading = false;

  @override
  void initState() {
    super.initState();
    _future = _getHistoricalMoods();
    _oldestDate = widget.moodRepo
        .getOldestMood()
        .catchError((_) => null)
        .then((value) => value?.date ?? DateTime.now().toStartOfMonth());
  }

  @override
  void didUpdateWidget(_CalendarBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Set the future every time dependencies change is called so we refresh data when repo gets a change
    _future = _getHistoricalMoods();

    // TODO: Could also check if _doneLoading by seeing if we're at _oldestDate as well
    _doneLoading = _monthsToLoad < _DEFAULT_MONTH_COUNT; // We're done loading if our months to load is less than 3 (otherwise, we always check)
  }

  Widget _errorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message, textAlign: TextAlign.center),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, AsyncSnapshot<List<_MonthData>> snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _errorWidget(AppLocalizations.of(context).oopsWeHadAnIssue);
        } else if (snapshot.data.isEmpty || snapshot.data.every((element) => element.moodsByWeek.isEmpty)) {
          return _errorWidget(AppLocalizations.of(context).noMoods);
        } else {
          return _CalendarList(moods: snapshot.data, onLoadNextMonth: _loadNextMonth, doneLoading: _doneLoading);
        }
      },
    );
  }

  Future<List<_MonthData>> _getHistoricalMoods() async {
    DateTime startDate = DateTime.now().toStartOfMonth();
    DateTime endDate = DateTime.now();
    final months = <_MonthData>[];

    for (int i = 0; i < _monthsToLoad; i++) {
      final future = widget.moodRepo.getMoods(startDate, endDate);
      List<Mood> moods = await future;
      months.add(_MonthData.fromMonthData(startDate, moods));

      if (await _isDoneLoading(startDate)) {
        _doneLoading = true;
        if (_monthsToLoad > months.length) {
          _monthsToLoad = months.length;
        }
        break;
      }

      endDate = startDate.subtract(Duration(days: 1)).toMidnight();
      startDate = endDate.toStartOfMonth();
    }
    return months;
  }

  void _loadNextMonth(DateTime startDate) async {
    if (_doneLoading) return;
    _monthsToLoad++; // Increment the month count so when repo has a change we build the same number of months
    final start = startDate.toStartOfMonth();
    final data = await widget.moodRepo.getMoods(start, startDate.toEndOfMonth());
    _future = Future.value((await _future)..add(_MonthData.fromMonthData(start, data)));
    _doneLoading = await _isDoneLoading(start);
    setState(() {});
  }

  Future<bool> _isDoneLoading(DateTime monthLoaded) async {
    final oldestDate = await _oldestDate;
    return oldestDate != null && !monthLoaded.isAfter(oldestDate);
  }
}

class _CalendarList extends StatefulWidget {
  final List<_MonthData> moodsByMonth;
  final void Function(DateTime startDate) onLoadNextMonth;

  // Add a null for the paged loading spot
  _CalendarList({Key key, List<_MonthData> moods, this.onLoadNextMonth, bool doneLoading = false})
      : this.moodsByMonth = doneLoading ? moods : moods + const [null],
        super(key: key);

  @override
  __CalendarListState createState() => __CalendarListState();
}

class __CalendarListState extends State<_CalendarList> {
  final ScrollController _controller = ScrollController();

  bool isLoading;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_onScroll);
  }

  void _onScroll() {
    if (isLoading ||
        _controller.position.extentAfter > _LoadingWidget.LOADING_HEIGHT ||
        widget.onLoadNextMonth == null) {
      return;
    }
    isLoading = true;

    // Get the second to last item, since the last one is the null paged loading
    final nextMonth = widget.moodsByMonth[widget.moodsByMonth.length - 2].start.subtract(Duration(days: 1));
    widget.onLoadNextMonth(nextMonth);
  }

  @override
  Widget build(BuildContext context) {
    isLoading = false;

    // TODO: Will this be more performant with SliverList?
    return ListView(
      controller: _controller,
      shrinkWrap: true,
      reverse: true,
      children: widget.moodsByMonth.map((data) => _MoodMonth(month: data)).toList(),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  static const LOADING_HEIGHT = 96.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: LOADING_HEIGHT, child: Center(child: CircularProgressIndicator()));
  }
}

class _MoodMonth extends StatelessWidget {
  final _MonthData month;

  const _MoodMonth({Key key, this.month}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (month == null) {
      return _LoadingWidget();
    }
    return Column(
      children: [
        Text(month.start.monthFormat(now: DateTime.now()), style: Theme.of(context).textTheme.headline4),
        ...month.moodsByWeek.map((moods) => _MoodWeek(moods: moods)).toList(),
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

  const _MonthData._(this.start, this.moodsByWeek);

  /// Split a month worth of mood data into a list of moods by week (each list in the list represents 7 days of moods).
  /// Any missing days will be generated as "missing".
  factory _MonthData.fromMonthData(DateTime start, List<Mood> moods) {
    final today = DateTime.now().toMidnight();
    final firstDay = start.toStartOfWeek();
    final lastDayOfMonth = start.toEndOfMonth();
    final lastDay = today.isAfter(lastDayOfMonth) ? lastDayOfMonth : today;
    final daysBetween = lastDay.toStartOfWeek().difference(firstDay).inDays;
    final weeksToShow = (daysBetween / 7).ceil() + 1;

    final List<List<Mood>> monthMoods = List.generate(weeksToShow, (index) => <Mood>[]);
    moods.forEach((element) {
      final days = element.date.toStartOfWeek().difference(firstDay).inDays;
      final weekIndex = days ~/ 7;
      monthMoods[weekIndex].add(element);
    });
    // final realMonths = List<List<Mood>>(monthMoods.length).toList();
    final realMonths = List<List<Mood>>.empty(growable: true);
    for (int i = 0; i < monthMoods.length; i++) {
      // Only do `toStartOfWeek` after the first week (don't generate missing data for last month overlaps)
      final weekStart = i == 0 ? start : start.addWeeks(i).toStartOfWeek();
      realMonths.add(_generateMissingData(weekStart, monthMoods[i]));
    }

    return _MonthData._(start, realMonths);
  }

  /// From a weeks worth of mood data, return a full week of moods generating any "missing" entries
  static List<Mood> _generateMissingData(DateTime weekStart, List<Mood> moods) {
    final firstDayOfWeek = weekStart.toStartOfWeek();
    final weekMoods = List<Mood>.filled(7, null);

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
