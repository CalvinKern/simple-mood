import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';
import 'package:simple_mood/screens/app/mood_theme.dart';

class ChartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo>(
      builder: (context, repo, child) {
        if (repo?.readyToLoad() != true) {
          return Center(child: CircularProgressIndicator());
        }
        return FutureBuilder(
          // Set the future every time the consumer builder is called so we refresh data
          future: repo.getMoods(DateTime.now().add(Duration(days: -7)).toMidnight(), DateTime.now()),
          builder: (context, AsyncSnapshot<List<Mood>> snapshot) {
            if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _Charts(moods: snapshot.data);
            }
          },
        );
      },
    );
  }
}

class _Charts extends StatelessWidget {
  final List<Mood> moods;

  const _Charts({Key key, this.moods}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (moods == null || moods.isEmpty == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TodayMood(),
          _EmptyMood(),
        ],
      );
    } else {
      return ListView(
        children: [
          if (moods.last?.date?.isAfter(DateTime.now().toMidnight()) != true) _TodayMood(),
          _MoodTimeChart(moods: moods),
          _MoodPieChart(moods: moods),
        ],
      );
    }
  }
}

class _EmptyMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).noMoods,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}

/// Today Mood tile
class _TodayMood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: AppLocalizations.of(context).addTodaysMood,
      chartHeight: 96,
      chart: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: MoodRating.values
            .map((rating) => MaterialButton(
                  child: rating.asIcon(),
                  shape: CircleBorder(),
                  minWidth: 48,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () => Provider.of<MoodRepo>(context, listen: false).create(rating),
                ))
            .toList(),
      ),
    );
  }
}

/// Mood Time Chart
///
/// Generates series data from list of moods using the factory constructor.
class _MoodTimeChart extends StatelessWidget {
  final List<charts.Series> data;

  _MoodTimeChart._internal({this.data, Key key}) : super(key: key);

  factory _MoodTimeChart({List<Mood> moods, Key key}) {
    return _MoodTimeChart._internal(data: _convertMoodData(moods), key: key);
  }

  static List<charts.Series<_TimeChartData, DateTime>> _convertMoodData(List<Mood> moods) {
    final moodData = moods.map((mood) => _TimeChartData(mood)).toList();
    // TODO: Can use two series here, one for doing colors (offset by .5 so that the color changing is _better_) and one
    // that is just the data points (custom decorator that only draws points for that series)
    // This may still look slightly off though, since a 1 - 5 jump might look weird.
    return [
      charts.Series<_TimeChartData, DateTime>(
        id: _TimeChartData.ID,
        data: moodData,
        colorFn: (mood, _) => charts.ColorUtil.fromDartColor(MoodTheme().primarySwatch()),
        domainFn: (mood, _) => mood.date.toMidnight(),
        measureFn: (mood, _) => mood.rating,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chartTimeFormatter = charts.TimeFormatterSpec(format: 'd', transitionFormat: 'MMMd', noonFormat: '');
    return _ChartCard(
      title: AppLocalizations.of(context).moodChart,
      chart: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodRating.values.map((rating) => rating.asIcon(size: 24)).toList().reversed.toList(),
            ),
          ),
          Flexible(
            // TODO: Make scrollable horizontally? Would also need to get more data from the repo, maybe just previous month?
            // TODO: Add support for showing date when clicking a data point: https://github.com/google/charts/issues/58
            // TODO: Time labels aren't legible in dark mode
            child: charts.TimeSeriesChart(
              data,
              defaultRenderer: charts.LineRendererConfig(includePoints: true),
              domainAxis: charts.DateTimeAxisSpec(
                tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                  hour: chartTimeFormatter,
                  minute: chartTimeFormatter,
                ),
              ),
              primaryMeasureAxis: charts.NumericAxisSpec(
                viewport: charts.NumericExtents.fromValues([1.0, 5.0]),
                tickFormatterSpec: charts.BasicNumericTickFormatterSpec((_) => ''), // No axis label, use faces instead
                tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false,
                  dataIsInWholeNumbers: true,
                  desiredTickCount: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mood Count Pie Chart
///
/// Generates series data from list of moods using the factory constructor.
class _MoodPieChart extends StatelessWidget {
  final List<charts.Series> data;

  _MoodPieChart._internal({this.data, Key key}) : super(key: key);

  factory _MoodPieChart({List<Mood> moods, Key key}) {
    return _MoodPieChart._internal(data: _convertMoodData(moods), key: key);
  }

  static List<charts.Series<_PieCountData, int>> _convertMoodData(List<Mood> moods) {
    // Generate chart data, count each rating usage in the given moods list
    final counts = Map<MoodRating, int>();
    moods.forEach((mood) => counts[mood.rating] = (counts[mood.rating] ?? 0) + 1);

    // Sort keys for better looking pie chart and don't include unused ratings (makes 100% pie look better)
    final data = (counts.keys.toList(growable: false)..sort((a, b) => a.index().compareTo(b.index())))
        .map((rating) => _PieCountData(rating, counts[rating]))
        .toList(growable: false);

    // TODO: Should use some kind of label for a11y, not just rating color
    return [
      charts.Series<_PieCountData, int>(
        id: _PieCountData.ID,
        data: data,
        colorFn: (mood, _) => charts.ColorUtil.fromDartColor(mood.rating.materialColor()),
        domainFn: (mood, _) => mood.rating.index(),
        measureFn: (mood, _) => mood.count,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: AppLocalizations.of(context).moodCount,
      chart: charts.PieChart(data),
    );
  }
}

/// Generic card structure with variable height
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final double chartHeight;

  const _ChartCard({Key key, this.title, this.chart, this.chartHeight = 250}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              height: chartHeight,
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}

///
/// Chart data classes
///

class _TimeChartData {
  static const ID = 'TimeChart';

  final DateTime date;
  final int rating; // 1 index based to be more human friendly

  _TimeChartData(Mood mood)
      : this.date = mood.date,
        this.rating = mood.rating.index() + 1;
}

class _PieCountData {
  static const ID = 'PieCount';

  final int count;
  final MoodRating rating;

  _PieCountData(this.rating, this.count);
}
