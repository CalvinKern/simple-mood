import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sqflite/sqflite.dart';

import 'tables/db_table.dart';
import 'tables/mood_table.dart';

/// A private list of tables used in production. This is provided as the default when using this class, to allow testing
const _PRODUCTION_TABLES = [
  MoodTable(),
];

/// A helper class to manage setting up and using the SQFlite database
class DbHelper {
  static const DB_VERSION = 1;
  static const DB_NAME = 'simple_moods.db';

  final List<DbTable> _tables; // List of tables that use the database
  final Future<Database> _database; // The database to use instead of SQFlite

  const DbHelper([
    this._tables = _PRODUCTION_TABLES,
    this._database,
  ]);

  /// Get all of the providers for database access
  List<SingleChildWidget> dbProviders() => [
        FutureProvider<Database>(lazy: false, create: (_) => _openDatabase()),
        ..._tables.map((table) => table.getProvider()),
      ];

  /// Open the database, or use the provided one (testing)
  Future<Database> _openDatabase() =>
      _database ?? openDatabase(DB_NAME, version: DB_VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);

  /// Run create on each table
  Future<void> _onCreate(Database db, int version) async {
    _tables.forEach((table) async => await table.onCreate(db, version));
  }

  /// Run upgrade on each table
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _tables.forEach((table) async => await table.onUpgrade(db, oldVersion, newVersion));
  }
}
