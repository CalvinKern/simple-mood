import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_mood/db/db_helper.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/repos/prefs_repo.dart';

/// A private list of tables used in production. This is provided as the default when using this class, to allow testing
// ignore: non_constant_identifier_names
final _PRODUCTION_REPOS = [
  MoodRepo(),
  PrefsRepo(),
];

class RepoHelper {
  final List<Repo>? _repos;
  final DbHelper _dbHelper;

  const RepoHelper([
    this._repos,
    this._dbHelper = const DbHelper(),
  ]);

  List<SingleChildWidget> repoProviders() => [
        // Repo dependencies
        FutureProvider<SharedPreferences?>(lazy: false, initialData: null, create: (_) => SharedPreferences.getInstance()),
        ..._dbHelper.dbProviders(),
        // Repos
        ...(_repos ?? _PRODUCTION_REPOS).map((table) => table.getProvider()),
      ];
}

abstract class Repo extends ChangeNotifier {
  /// Return a proxy provider for your subclass that is dependent on the database provider.
  /// Can't have a generic provider function since each repo needs its own typed provider.
  ///
  /// e.g. => ChangeNotifierProxyProvider<YourTable, YourRepo>(create: (_) => null, update: (_, db, __) => createNewRepo(db))
  ChangeNotifierProxyProvider getProvider();

  bool readyToLoad();
}
