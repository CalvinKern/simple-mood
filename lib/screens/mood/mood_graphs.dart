import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/material/mood_theme.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MoodGraphs extends StatelessWidget {
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
              return _MoodCharts(moods: snapshot.data);
            }
          },
        );
      },
    );
  }
}

class _MoodCharts extends StatelessWidget {
  final List<Mood> moods;

  const _MoodCharts({Key key, this.moods}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (moods?.isNotEmpty != true) {
      return Center(
          child: Text(
        AppLocalizations.of(context).noMoods,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline4,
      ));
    } else {
      return ListView(
        children: [
          _MoodTimeChart(moods: moods),
          _MoodPieChart(moods: moods),
        ],
      );
    }
  }
}

class _MoodTimeChart extends StatelessWidget {
  final List<charts.Series> data;

  _MoodTimeChart._internal({this.data, Key key}) : super(key: key);

  factory _MoodTimeChart({List<Mood> moods, Key key}) {
    return _MoodTimeChart._internal(data: _convertMoodData(moods), key: key);
  }

  static List<charts.Series<_ChartData, DateTime>> _convertMoodData(List<Mood> moods) {
    final moodData = moods.map((mood) => _ChartData(mood)).toList();
    return [
      charts.Series<_ChartData, DateTime>(
        id: 'MoodChart',
        data: moodData,
        colorFn: (mood, _) => _ratingColor(mood.y),
        domainFn: (mood, _) => mood.x,
        measureFn: (mood, _) => mood.y,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: AppLocalizations.of(context).moodChart,
      chart: charts.TimeSeriesChart(
        data,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            zeroBound: false,
            dataIsInWholeNumbers: true,
            desiredTickCount: 5,
          ),
        ),
      ),
    );
  }

  static charts.Color _ratingColor(int rating) {
    return charts.ColorUtil.fromDartColor(MoodTheme().primarySwatch());
  }
}

class _MoodPieChart extends StatelessWidget {
  final List<charts.Series> data;

  _MoodPieChart._internal({this.data, Key key}) : super(key: key);

  factory _MoodPieChart({List<Mood> moods, Key key}) {
    return _MoodPieChart._internal(data: _convertMoodData(moods), key: key);
  }

  static List<charts.Series<_CountData, int>> _convertMoodData(List<Mood> moods) {
    // Generate chart data, count each time a key is used in the given moods list
    final counts = Map<MoodRating, int>();
    moods.forEach((mood) => counts[mood.rating] = (counts[mood.rating] ?? 0) + 1);

    return [
      charts.Series<_CountData, int>(
        id: 'MoodCount',
        data: MoodRating.values.toList().map((rating) => _CountData(rating, counts[rating] ?? 0)).toList(),
        colorFn: (mood, _) => _ratingColor(mood.rating),
        domainFn: (mood, _) => MoodRating.values.toList().indexOf(mood.rating),
        measureFn: (mood, _) => mood.count,
        labelAccessorFn: (mood, _) => mood.count.toString(),
      ),
    ];
  }

  static charts.Color _ratingColor(MoodRating rating) {
    switch (rating) {
      case MoodRating.miserable:
        return charts.ColorUtil.fromDartColor(Colors.red);
      case MoodRating.unhappy:
        return charts.ColorUtil.fromDartColor(Colors.orange);
      case MoodRating.plain:
        return charts.ColorUtil.fromDartColor(Colors.yellow);
      case MoodRating.happy:
        return charts.ColorUtil.fromDartColor(Colors.lightGreen);
      case MoodRating.ecstatic:
        return charts.ColorUtil.fromDartColor(Colors.green);
      default:
        throw ArgumentError.value(rating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: AppLocalizations.of(context).moodCount,
      chart: charts.PieChart(
        data,
        defaultRenderer:
            charts.ArcRendererConfig(arcRendererDecorators: [charts.ArcLabelDecorator()]),
      ),
    );
  }
}

class _ChartData {
  final DateTime x; // Day
  final int y; // Rating

  _ChartData(Mood mood)
      : this.x = mood.date,
        this.y = MoodRating.values.toList().indexOf(mood.rating) + 1;
}

class _CountData {
  final MoodRating rating;
  final int count;

  _CountData(this.rating, this.count);
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;

  const _ChartCard({Key key, this.title, this.chart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
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
              height: 250.0,
              child: chart,
            ),
          ),
        ],
      ),
    );
  }
}
