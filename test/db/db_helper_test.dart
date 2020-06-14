import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/db/db_helper.dart';
import 'package:simple_mood/db/tables/db_table.dart';
import 'package:sqflite_common/sqlite_api.dart';

void main() {
  testWidgets('can provide in a MultiProvider', (tester) async {
    final database = MockDatabase();
    final tableA = TableA();
    final tableB = TableB();
    final key = GlobalKey();

    await tester.pumpWidget(
      MultiProvider(
        child: Container(key: key),
        providers: [
          ...DbHelper([tableA, tableB], Future<Database>.value(database)).dbProviders(),
        ],
      ),
    );

    expect(
      Provider.of<TableA>(key.currentContext, listen: false),
      tableA,
    );
    expect(
      Provider.of<TableB>(key.currentContext, listen: false),
      tableB,
    );
  });

  testWidgets('can provide to a consumer', (tester) async {
    final database = MockDatabase();
    final tableA = TableA();
    final key = GlobalKey();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ...DbHelper([tableA], Future<Database>.value(database)).dbProviders(),
        ],
        child: Consumer<TableA>(builder: (_, __, ___) => Container(key: key)),
      ),
    );

    expect(
      Provider.of<TableA>(key.currentContext, listen: false),
      tableA,
    );
  });

  testWidgets('toString provide test - mainly for debugging', (tester) async {
    final database = MockDatabase();
    final tableA = TableA();
    final tables = [tableA];

    final normalProvider = [
      FutureProvider<Database>(create: (_) async => database),
      ProxyProvider<Database, TableA>(update: (c, db, p) => tableA),
    ];

    final arrayProvider = [
      FutureProvider<Database>(create: (_) => Future<Database>.value(database)),
      ...tables.map((table) => table.getProvider()),
    ];

    final helperProvider = [
      ...DbHelper([tableA], Future<Database>.value(database)).dbProviders(),
    ];

    expect(
      normalProvider.toString(),
      helperProvider.toString(),
    );
    expect(
      normalProvider.toString(),
      arrayProvider.toString(),
    );
  });
}

class MockDatabase extends Mock implements Database {}

class TableA extends DbTable {
  @override
  ProxyProvider<Database, TableA> getProvider() =>
      ProxyProvider<Database, TableA>(lazy: false, update: (_, __, ___) => this);

  // Don't care about creating the table, so don't implement
  @override
  Future<void> onCreate(Database db, int version) => throw UnimplementedError();
}

class TableB extends DbTable {
  @override
  ProxyProvider<Database, TableB> getProvider() =>
      ProxyProvider<Database, TableB>(lazy: false, update: (_, __, ___) => this);

  // Don't care about creating the table, so don't implement
  @override
  Future<void> onCreate(Database db, int version) => throw UnimplementedError();
}
