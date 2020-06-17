import 'package:flutter/material.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/screens/mood/mood_graphs.dart';
import 'package:simple_mood/screens/mood/mood_list.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
//      body: MoodGraphs(),
//      body: MoodList(),
    );
  }

  Widget currentBody() {
    switch (_currentIndex) {
      case 0: return MoodGraphs();
      case 1: return MoodList();
      case 2: return Center(child: Text('Nothing here yet'));
      default: throw RangeError.range(_currentIndex, 0, 2, '${this.runtimeType.toString()}#currentBody');
    }
  }
}
