import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:flutter/material.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/screens/dashboard/charts/dashboard_card.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

/// Mood Count Pie Chart
///
/// Generates series data from list of moods using the factory constructor.
class SimplePieChart extends StatelessWidget {
  final List<Series<_PieCountData, int>> data;

  SimplePieChart._internal({required this.data, Key? key}) : super(key: key);

  factory SimplePieChart({required List<Mood> moods, Key? key}) {
    return SimplePieChart._internal(data: _convertMoodData(moods), key: key);
  }

  static List<Series<_PieCountData, int>> _convertMoodData(List<Mood> moods) {
    // Generate chart data, count each rating usage in the given moods list
    final counts = Map<MoodRating, int>();
    moods.forEach((mood) => counts[mood.rating] = (counts[mood.rating] ?? 0) + 1);

    // Sort keys for better looking pie chart and don't include unused ratings (makes 100% pie look better)
    final data = (counts.keys.toList(growable: false)..sort((a, b) => a.index().compareTo(b.index())))
        .map((rating) => _PieCountData(rating, counts[rating] ?? 0))
        .toList(growable: false);

    // TODO: Should use some kind of label for a11y, not just rating color
    return [
      Series<_PieCountData, int>(
        id: _PieCountData.ID,
        data: data,
        colorFn: (mood, _) => ColorUtil.fromDartColor(mood.rating.materialColor()),
        domainFn: (mood, _) => mood.rating.index(),
        measureFn: (mood, _) => mood.count,
        labelAccessorFn: (mood, _) => mood.count.toString(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorOnBackground = Theme.of(context).textTheme.headlineMedium?.color ?? Colors.grey;
    final insideLabelStyle = TextStyleSpec(fontSize: 12, color: Color.black);
    final outsideLabelStyle = TextStyleSpec(fontSize: 12, color: ColorUtil.fromDartColor(colorOnBackground));
    return DashboardCard(
      title: AppLocalizations.of(context).moodCount,
      child: PieChart<int>(
        data,
        defaultRenderer: ArcRendererConfig(
          arcRendererDecorators: [
            ArcLabelDecorator(
              insideLabelStyleSpec: insideLabelStyle,
              outsideLabelStyleSpec: outsideLabelStyle,
            )
          ],
        ),
      ),
    );
  }
}

class _PieCountData {
  static const ID = 'PieCount';

  final int count;
  final MoodRating rating;

  _PieCountData(this.rating, this.count);
}
