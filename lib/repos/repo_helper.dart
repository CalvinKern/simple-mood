import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:simple_mood/db/db_helper.dart';
import 'package:simple_mood/db/tables/db_table.dart';
import 'package:simple_mood/repos/mood_repo.dart';

/// A private list of tables used in production. This is provided as the default when using this class, to allow testing
const _PRODUCTION_REPOS = [
  MoodRepo(),
];

class RepoHelper {
  final List<Repo> _repos;
  final DbHelper _dbHelper;

  const RepoHelper([
    this._repos = _PRODUCTION_REPOS,
    this._dbHelper = const DbHelper(),
  ]);

  List<SingleChildWidget> repoProviders() => [
        ..._dbHelper.dbProviders(),
        ..._repos.map((table) => table.getDbProvider()),
      ];
}

abstract class Repo {
  const Repo();

  /// Return a proxy provider for your subclass that is dependent on the database provider.
  /// Can't have a generic provider function since each repo needs its own typed provider.
  ///
  /// e.g. => ProxyProvider<YourTable, YourRepo>(lazy: false, update: (_, db, __) => createNewRepo(db))
  ProxyProvider<DbTable, Repo> getDbProvider();
}
