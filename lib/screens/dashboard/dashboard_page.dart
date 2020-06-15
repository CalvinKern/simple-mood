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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations().appName),
      ),
      body: MoodGraphs(),
//      body: MoodList(),
    );
  }
}
