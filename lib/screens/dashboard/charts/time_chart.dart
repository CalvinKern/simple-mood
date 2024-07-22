import 'package:community_charts_flutter/community_charts_flutter.dart';
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
  final List<Series<_TimeChartData, DateTime>> data;

  TimeChart._internal({required this.data, Key? key}) : super(key: key);

  factory TimeChart({required List<Mood> moods, Key? key}) {
    return TimeChart._internal(data: _convertMoodData(moods), key: key);
  }

  static List<Series<_TimeChartData, DateTime>> _convertMoodData(List<Mood> moods) {
    final moodData = moods.map((mood) => _TimeChartData(mood)).toList();
    // TODO: Can use two series here, one for doing colors (offset by .5 so that the color changing is _better_) and one
    // that is just the data points (custom decorator that only draws points for that series)
    // This may still look slightly off though, since a 1 - 5 jump might look weird.
    return [
      Series<_TimeChartData, DateTime>(
        id: _TimeChartData.ID,
        data: moodData,
        colorFn: (mood, _) => ColorUtil.fromDartColor(MoodTheme.primarySwatch()),
        domainFn: (mood, _) => mood.date.toMidnight(),
        measureFn: (mood, _) => mood.rating,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chartTimeFormatter = TimeFormatterSpec(format: 'd', transitionFormat: 'MMMd', noonFormat: '');
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
            // TODO: Add support for showing date when clicking a data point: https://github.com/google/charts/issues/58
            child: TimeSeriesChart(
              data,
              defaultRenderer: LineRendererConfig(includePoints: true),
              domainAxis: DateTimeAxisSpec(
                renderSpec: SmallTickRendererSpec<DateTime>(
                  labelStyle: TextStyleSpec(
                    color: ColorUtil.fromDartColor(Theme.of(context).textTheme.headlineMedium?.color ?? Colors.grey),
                  ),
                ),
                tickFormatterSpec: AutoDateTimeTickFormatterSpec(
                  hour: chartTimeFormatter,
                  minute: chartTimeFormatter,
                ),
              ),
              primaryMeasureAxis: NumericAxisSpec(
                viewport: NumericExtents.fromValues([1.0, 5.0]),
                tickFormatterSpec: BasicNumericTickFormatterSpec((_) => ''), // No axis label, use faces instead
                tickProviderSpec: BasicNumericTickProviderSpec(
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
