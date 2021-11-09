import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/screens/dashboard/calendar/calendar_page.dart';
import 'package:simple_mood/screens/dashboard/charts/charts_page.dart';
import 'package:simple_mood/screens/dashboard/settings_page.dart';

class DashboardContainer extends StatefulWidget {
  DashboardContainer({Key? key}) : super(key: key);

  @override
  _DashboardContainerState createState() => _DashboardContainerState();
}

class _DashboardContainerState extends State<DashboardContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final weekHeight =
        (Theme.of(context).primaryTextTheme.headline6?.fontSize ?? 12) + 12; // 8 padding top/bottom, plus 4 for Text offset
    return Scaffold(
      appBar: AppBar(
        // TODO: Can this animate height change if it's a sliver app bar?
        title: Text(AppLocalizations().appName),
        bottom: (_currentIndex != 1)
            ? null
            : PreferredSize(child: _WeekHeader(), preferredSize: Size.fromHeight(weekHeight)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context).pageHome),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: AppLocalizations.of(context).pageCalendar),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppLocalizations.of(context).pageSettings),
        ],
      ),
      body: currentBody(),
    );
  }

  Widget currentBody() {
    switch (_currentIndex) {
      case 0:
        return ChartsPage();
      case 1:
        return CalendarPage();
      case 2:
        return SettingsPage();
      default:
        throw RangeError.range(_currentIndex, 0, 2, '${this.runtimeType.toString()}#currentBody');
    }
  }
}

class _WeekHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final symbols = DateFormat().dateSymbols.STANDALONENARROWWEEKDAYS;
    final firstDayOfWeek = DateFormat().dateSymbols.FIRSTDAYOFWEEK;

    return Row(
      children: List.generate(symbols.length, (index) {
        final day = (firstDayOfWeek + index + 1) % symbols.length;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              symbols[day],
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headline6,
            ),
          ),
        );
      }),
    );
  }
}
