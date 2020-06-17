import 'package:flutter/material.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/screens/dashboard/charts_page.dart';
import 'package:simple_mood/screens/dashboard/list_page.dart';
import 'package:simple_mood/screens/dashboard/settings_page.dart';

class DashboardContainer extends StatefulWidget {
  DashboardContainer({Key key}) : super(key: key);

  @override
  _DashboardContainerState createState() => _DashboardContainerState();
}

class _DashboardContainerState extends State<DashboardContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations().appName),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(AppLocalizations.of(context).pageHome)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text(AppLocalizations.of(context).pageCalendar)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).pageSettings)
          ),
        ],
      ),
      body: currentBody(),
    );
  }

  Widget currentBody() {
    switch (_currentIndex) {
      case 0: return ChartsPage();
      case 1: return ListPage();
      case 2: return SettingsPage();
      default: throw RangeError.range(_currentIndex, 0, 2, '${this.runtimeType.toString()}#currentBody');
    }
  }
}
