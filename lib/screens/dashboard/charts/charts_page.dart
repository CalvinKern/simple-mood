import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/dashboard/charts/dashboard_card.dart';
import 'package:simple_mood/screens/dashboard/charts/simple_pie_chart.dart';
import 'package:simple_mood/screens/dashboard/charts/time_chart.dart';
import 'package:simple_mood/screens/dashboard/rating_picker.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class ChartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo?>(
      builder: (context, repo, child) {
        if (repo?.readyToLoad() != true) {
          return Center(child: CircularProgressIndicator());
        }
        return _Body(repo: repo!);
      },
    );
  }
}

/// Body to keep track of the selected time period and corresponding repo loads
class _Body extends StatefulWidget {
  final MoodRepo repo;

  const _Body({Key? key, required this.repo}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  // Static so that we lazy persist selected period while app stays alive
  static _TimePeriod _selectedTimePeriod = _TimePeriod.week;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Set the future every time the consumer builder is called so we refresh data
      future: _getMoods(),
      builder: (context, AsyncSnapshot<MoodSnapshot> snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          // TODO: Could have a loading indicator in this body if loading a new time period
          return _Charts(
            moods: snapshot.data?.moods ?? List.empty(),
            neverMood: snapshot.data?.neverMood ?? true,
            period: _selectedTimePeriod,
            onTimePeriodChanged: (period) => setState(() => _selectedTimePeriod = period),
          );
        }
      },
    );
  }

  Future<MoodSnapshot> _getMoods() async {
    DateTime startTime;
    switch (_selectedTimePeriod) {
      case _TimePeriod.week:
        startTime = DateTime.now().add(Duration(days: -7));
        break;
      case _TimePeriod.month:
        startTime = DateTime.now().add(Duration(days: -31));
        break;
      case _TimePeriod.threeMonth:
        startTime = DateTime.now().add(Duration(days: -90));
        break;
      case _TimePeriod.halfYear:
        startTime = DateTime.now().add(Duration(days: -183));
        break;
      case _TimePeriod.year:
        startTime = DateTime.now().add(Duration(days: -365));
        break;
      case _TimePeriod.all:
        startTime = DateTime.fromMillisecondsSinceEpoch(0);
        break;
    }
    final moods = await widget.repo.getMoods(startTime.toMidnight(), DateTime.now());
    final neverMood = await widget.repo.getOldestMood().catchError((_) => null) == null;
    return MoodSnapshot(neverMood, moods);
  }
}

class _Charts extends StatelessWidget {
  final bool neverMood;
  final List<Mood> moods;
  final _TimePeriod period;
  final Function(_TimePeriod) onTimePeriodChanged;

  const _Charts(
      {Key? key,
      required this.moods,
      this.neverMood = true,
      this.period = _TimePeriod.week,
      required this.onTimePeriodChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final noSelectedMoods = moods.isEmpty;
    // Reuse noSelectedMoods here as a safety check before calling .last
    final notRatedToday = noSelectedMoods || moods.last.date.isBefore(DateTime.now().toMidnight()) == true;
    final periodPicker =
        _PeriodPicker(selectedPeriod: period, onPeriodSelected: (period) => onTimePeriodChanged(period));

    return ListView(
      children: [
        if (noSelectedMoods || notRatedToday) RatingPicker.asTodayCard(context),
        if (!neverMood) periodPicker,
        if (noSelectedMoods)
          _EmptyMood(neverMood: neverMood)
        else ...[TimeChart(moods: moods), SimplePieChart(moods: moods)]
      ],
    );
  }
}

class _EmptyMood extends StatelessWidget {
  final bool neverMood;

  const _EmptyMood({Key? key, this.neverMood = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        neverMood ? AppLocalizations.of(context).neverMoods : AppLocalizations.of(context).noMoods,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  final _TimePeriod selectedPeriod;
  final Function(_TimePeriod) onPeriodSelected;

  const _PeriodPicker({Key? key, required this.selectedPeriod, required this.onPeriodSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttonTexts = [l10n.oneWeek, l10n.oneMonth, l10n.threeMonths, l10n.sixMonths, l10n.oneYear, l10n.periodAll];
    return DashboardCard(
      title: l10n.timePeriod,
      chartHeight: null, // Be as big as it wants
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceEvenly,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(buttonTexts.length, (index) {
          final onPressed = () => onPeriodSelected(_TimePeriod.values[index]);
          final period = buttonTexts[index];
          return index == selectedPeriod.index
              ? _getSelectedButton(context, period, onPressed)
              : _getUnselectedButton(context, period, onPressed);
        }),
      ),
    );
  }

  Widget _getSelectedButton(BuildContext context, String period, Function() onPressed) => FilledButton(
        child: Text(period),
        onPressed: onPressed,
      );

  Widget _getUnselectedButton(BuildContext context, String period, Function() onPressed) => TextButton(
        child: Text(period),
        onPressed: onPressed,
      );
}

enum _TimePeriod { week, month, threeMonth, halfYear, year, all }

class MoodSnapshot {
  final bool neverMood;
  final List<Mood> moods;

  MoodSnapshot(this.neverMood, this.moods);
}
