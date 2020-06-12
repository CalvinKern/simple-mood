import 'package:flutter/material.dart';
import 'package:simple_mood/dashboard/dashboard_page.dart';
import 'package:simple_mood/material/mood_theme.dart';

class MoodApp extends StatelessWidget {
  final MoodTheme theme;

  const MoodApp({Key key, this.theme = const MoodTheme()}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Mood',
      theme: theme.lightTheme(),
      darkTheme: theme.darkTheme(),
      home: DashboardPage(title: 'Simple Mood'),
    );
  }
}
