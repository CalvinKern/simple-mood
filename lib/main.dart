import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'screens/app/mood_application.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() {
    runApp(_FirebaseApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

// TODO: Put in it's own file, or combine with [MoodApp]
class _FirebaseApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = _initializeFirebase();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {

          return Center(child: Text("Sorry, something went wrong\n\n${snapshot.error}", textDirection: TextDirection.ltr));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MoodApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  static Future<FirebaseApp> _initializeFirebase() async {
    final app = await Firebase.initializeApp();

    // Pass all uncaught errors from the framework to Crashlytics.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
      originalOnError(details);
    };

    return app;
  }
}
