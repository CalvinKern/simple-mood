import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/dashboard/dashboard_page.dart';
import 'package:simple_mood/db/db_helper.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';

import 'mood_theme.dart';

class MoodApp extends StatelessWidget {
  static const _LOCALIZATION_DELEGATES = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ];

  final MoodTheme theme;

  const MoodApp({Key key, this.theme = const MoodTheme()}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...DbHelper().dbProviders()
      ],
      child: MaterialApp(
        title: AppLocalizations().appName,
        theme: theme.lightTheme(),
        darkTheme: theme.darkTheme(),
        home: DashboardPage(),
        localizationsDelegates: _LOCALIZATION_DELEGATES,
        supportedLocales: AppLocalizations.delegate.supportedLocales,
      ),
    );
  }
}
