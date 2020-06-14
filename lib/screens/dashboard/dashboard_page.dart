import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/mood/mood_graphs.dart';
import 'package:simple_mood/screens/mood/mood_list.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _addMood() async {
    // Create a random rating
    final rating = MoodRating.values.toList()[Random().nextInt(MoodRating.values.length)];
    await Provider.of<MoodRepo>(context, listen: false).create(Mood((b) => b
      ..id = 0
      ..date = DateTime.now().add(Duration(days: 0))
      ..rating = rating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations().appName),
      ),
      body: MoodGraphs(),
//      body: MoodList(),
      // Temp floating action button to create a dummy mood
      floatingActionButton: FloatingActionButton(
        onPressed: _addMood,
        tooltip: 'Create',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
