import 'package:provider/provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../db_helper.dart';

const _TABLE_NAME = 'Mood';
const _COLUMN_ID = 'id';
const _COLUMN_DATE = 'date';
const _COLUMN_RATING = 'rating';

class MoodTable extends DbTable {
  const MoodTable({Database db}) : super(db: db);

  @override
  ProxyProvider<Database, MoodTable> getProvider() =>
      ProxyProvider(lazy: false, update: (_, db, __) => MoodTable(db: db));

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      create table $_TABLE_NAME ( 
        $_COLUMN_ID integer primary key autoincrement, 
        $_COLUMN_DATE text not null,
        $_COLUMN_RATING text not null )
      ''');
  }
}
