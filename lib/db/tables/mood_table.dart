import 'package:provider/provider.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'db_table.dart';

const _TABLE_NAME = 'Mood';
const _COLUMN_ID = 'id';
const _COLUMN_DATE = 'date';
const _COLUMN_RATING = 'rating';

class MoodTable extends DbTable {
  const MoodTable({Database db}) : super(db: db);

  static Map<String, dynamic> serialize(Mood mood) {
    return <String, dynamic>{
      _COLUMN_ID: mood.id,
      _COLUMN_DATE: mood.date.toIso8601String(),
      _COLUMN_RATING: mood.rating.name,
    };
  }

  static Mood deserialize(Map<String, dynamic> mood) {
    return Mood((b) => b
      ..id = mood[_COLUMN_ID]
      ..date = DateTime.parse(mood[_COLUMN_DATE])
      ..rating = MoodRating.valueOf(mood[_COLUMN_RATING]));
  }

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

  Future<Mood> insert(Mood mood) async {
    final id = await db.insert(_TABLE_NAME, serialize(mood));
    return mood.rebuild((mood) => mood..id = id);
  }

  Future<int> update(Mood mood) async {
    return await db.update(_TABLE_NAME, serialize(mood), where: '$_COLUMN_ID = ?', whereArgs: [mood.id]);
  }

  Future<int> delete(int id) async {
    return await db.delete(_TABLE_NAME, where: '$_COLUMN_ID = ?', whereArgs: [id]);
  }

  Future<Mood> getMood(int id) async {
    final moods = await db.query(
      _TABLE_NAME,
      columns: [_COLUMN_ID, _COLUMN_DATE, _COLUMN_RATING],
      where: '$_COLUMN_ID = ?',
      whereArgs: [id],
    );
    return moods.length == 0 ? null : deserialize(moods.first);
  }

  Future<List<Mood>> getMoods(DateTime rangeStart, DateTime rangeEnd) async {
    final moods = await db.query(
      _TABLE_NAME,
      columns: [_COLUMN_ID, _COLUMN_DATE, _COLUMN_RATING],
      where: '$_COLUMN_DATE BETWEEN ? AND ?',
      whereArgs: [rangeStart.toIso8601String(), rangeEnd.toIso8601String()],
    );
    return moods.length == 0 ? null : moods.map((mood) => deserialize(mood));
  }
}
