import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/screens/app/mood_theme.dart';
import 'package:simple_mood/screens/dashboard/charts/dashboard_card.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

/// Mood Time Chart
///
/// Generates series data from list of moods using the factory constructor.
class TimeChart extends StatelessWidget {
  final List<charts.Series> data;

  TimeChart._internal({this.data, Key key}) : super(key: key);

  factory TimeChart({List<Mood> moods, Key key}) {
    return TimeChart._internal(data: _convertMoodData(moods), key: key);
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
        colorFn: (mood, _) => charts.ColorUtil.fromDartColor(MoodTheme.primarySwatch()),
        domainFn: (mood, _) => mood.date.toMidnight(),
        measureFn: (mood, _) => mood.rating,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chartTimeFormatter = charts.TimeFormatterSpec(format: 'd', transitionFormat: 'MMMd', noonFormat: '');
    return DashboardCard(
      title: AppLocalizations.of(context).moodChart,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MoodRating.ratings.map((rating) => rating.asIcon(context, size: 24)).toList().reversed.toList(),
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

class _TimeChartData {
  static const ID = 'TimeChart';

  final DateTime date;
  final int rating; // 1 index based to be more human friendly

  _TimeChartData(Mood mood)
      : this.date = mood.date,
        this.rating = mood.rating.index() + 1;
}

