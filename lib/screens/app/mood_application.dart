import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/repos/repo_helper.dart';

import '../dashboard/dashboard_container.dart';
import 'mood_theme.dart';

class MoodApp extends StatelessWidget {
  static const _LOCALIZATION_DELEGATES = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ];

  final MoodTheme theme;

  const MoodApp({Key? key, this.theme = const MoodTheme()}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analytics = FirebaseAnalytics.instance;
    return MultiProvider(
      providers: [
        Provider.value(value: analytics),
        ...RepoHelper().repoProviders(),
      ],
      child: MaterialApp(
        title: AppLocalizations().appName,
        theme: theme.lightTheme(),
        darkTheme: theme.darkTheme(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        home: DashboardContainer(),
        localizationsDelegates: _LOCALIZATION_DELEGATES,
        supportedLocales: AppLocalizations.delegate.supportedLocales,
      ),
    );
  }
}
