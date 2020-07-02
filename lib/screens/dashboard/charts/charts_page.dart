import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/repos/prefs_repo.dart';
import 'package:simple_mood/screens/dashboard/charts/dashboard_card.dart';
import 'package:simple_mood/screens/dashboard/charts/pie_chart.dart';
import 'package:simple_mood/screens/dashboard/charts/time_chart.dart';
import 'package:simple_mood/screens/dashboard/rating_picker.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class ChartsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo>(
      builder: (context, repo, child) {
        if (repo?.readyToLoad() != true) {
          return Center(child: CircularProgressIndicator());
        }
        return _Body(repo: repo);
      },
    );
  }
}

/// Body to keep track of the selected time period and corresponding repo loads
class _Body extends StatefulWidget {
  final MoodRepo repo;

  const _Body({Key key, @required this.repo}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  _TimePeriod _selectedTimePeriod = _TimePeriod.week;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Set the future every time the consumer builder is called so we refresh data
      future: _getMoods(),
      builder: (context, AsyncSnapshot<List<Mood>> snapshot) {
        if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          // TODO: Could have a loading indicator in this body if loading a new time period
          return _Charts(
            moods: snapshot.data,
            period: _selectedTimePeriod,
            onTimePeriodChanged: (period) => setState(() => _selectedTimePeriod = period),
          );
        }
      },
    );
  }

  Future<List<Mood>> _getMoods() {
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
    return widget.repo.getMoods(startTime.toMidnight(), DateTime.now());
  }
}

class _Charts extends StatelessWidget {
  final List<Mood> moods;
  final _TimePeriod period;
  final Function(_TimePeriod) onTimePeriodChanged;

  const _Charts({Key key, this.moods, this.period = _TimePeriod.week, @required this.onTimePeriodChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (moods == null || moods.isEmpty == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RatingPicker.asTodayCard(context),
          _EmptyMood(),
        ],
      );
    } else {
      return ListView(
        children: [
          if (moods.last?.date?.isBefore(DateTime.now().toMidnight()) == true) RatingPicker.asTodayCard(context),
          _TimePicker(selectedPeriod: period, onPeriodSelected: (period) => onTimePeriodChanged(period)),
          TimeChart(moods: moods),
          PieChart(moods: moods),
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

class _TimePicker extends StatelessWidget {
  final _TimePeriod selectedPeriod;
  final Function(_TimePeriod) onPeriodSelected;

  const _TimePicker({Key key, @required this.selectedPeriod, @required this.onPeriodSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttonTexts = [l10n.oneWeek, l10n.oneMonth, l10n.threeMonths, l10n.sixMonths, l10n.oneYear, l10n.periodAll];
    return DashboardCard(
      title: l10n.timePeriod,
      chartHeight: null, // Be as big as it wants
      child: ButtonTheme(
        minWidth: 48,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(buttonTexts.length, (index) {
            final onPressed = () => onPeriodSelected(_TimePeriod.values[index]);
            final period = buttonTexts[index];
            return index == selectedPeriod.index
                ? _getSelectedButton(period, onPressed)
                : _getUnselectedButton(context, period, onPressed);
          }),
        ),
      ),
    );
  }

  Widget _getSelectedButton(String period, Function() onPressed) => RaisedButton(
        child: Text(period),
        onPressed: onPressed,
      );

  Widget _getUnselectedButton(BuildContext context, String period, Function() onPressed) => FlatButton(
        child: Text(period),
        onPressed: onPressed,
        textColor: Theme.of(context).textTheme.headline4.color,
      );
}

enum _TimePeriod { week, month, threeMonth, halfYear, year, all }
