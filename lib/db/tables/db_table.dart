import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

/// The super class for database tables.
abstract class DbTable {
  const DbTable({this.db});

  final Database db;

  /// Return a proxy provider for your subclass that is dependent on the database provider.
  /// Can't have a generic provider function since each table needs its own typed provider.
  ///
  /// e.g. => ProxyProvider<Database, T>(lazy: false, update: (_, db, __) => createNewTable(db))
  ProxyProvider<Database, DbTable> getProvider();

  /// Function called to create the table
  Future<void> onCreate(Database db, int version);

  /// Not every table needs an upgrade, so make it optional
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async => null;
}