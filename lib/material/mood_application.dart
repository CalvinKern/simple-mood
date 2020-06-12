import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:simple_mood/dashboard/dashboard_page.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/material/mood_theme.dart';

class MoodApp extends StatelessWidget {
  final MoodTheme theme;

  const MoodApp({Key key, this.theme = const MoodTheme()}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations().appName,
      theme: theme.lightTheme(),
      darkTheme: theme.darkTheme(),
      home: DashboardPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
    );
  }
}
