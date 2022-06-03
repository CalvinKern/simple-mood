import 'package:provider/provider.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'db_table.dart';

const _TABLE_NAME = 'Mood';
const _TABLE_COLUMNS = [_COLUMN_ID, _COLUMN_DATE, _COLUMN_RATING];
const _COLUMN_ID = 'id';
const _COLUMN_DATE = 'date';
const _COLUMN_RATING = 'rating';

class MoodTable extends DbTable {
  const MoodTable({Database? db}) : super(db: db);

  /// Option to include ID (not used when inserting a new mood since ID is auto generated)
  static Map<String, dynamic> serialize(Mood mood, {bool includeId = true}) {
    return <String, dynamic>{
      if (includeId) _COLUMN_ID: mood.id,
      _COLUMN_DATE: mood.date.millisecondsSinceEpoch,
      _COLUMN_RATING: mood.rating.name,
    };
  }

  static Mood deserialize(Map<String, dynamic> mood) {
    return Mood((b) => b
      ..id = mood[_COLUMN_ID]
      ..date = DateTime.fromMillisecondsSinceEpoch(mood[_COLUMN_DATE], isUtc: true)
      ..rating = MoodRating.valueOf(mood[_COLUMN_RATING]));
  }

  @override
  ProxyProvider<Database?, MoodTable?> getProvider() =>
      ProxyProvider(update: (_, db, __) => db == null ? null : MoodTable(db: db));

  @override
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      create table $_TABLE_NAME ( 
        $_COLUMN_ID integer primary key autoincrement, 
        $_COLUMN_DATE integer not null,
        $_COLUMN_RATING text not null )
      ''');
  }

  Future<Mood> insert(Mood mood) async {
    final id = await db!.insert(_TABLE_NAME, serialize(mood, includeId: false));
    return mood.rebuild((mood) => mood..id = id);
  }

  Future<int> update(Mood mood) async {
    return await db!.update(_TABLE_NAME, serialize(mood), where: '$_COLUMN_ID = ?', whereArgs: [mood.id]);
  }

  Future<int> delete(int id) async {
    return await db!.delete(_TABLE_NAME, where: '$_COLUMN_ID = ?', whereArgs: [id]);
  }

  Future<Mood?> getOldestMood() async {
    final moods = await db!.query(
      _TABLE_NAME,
      columns: _TABLE_COLUMNS,
      orderBy: _COLUMN_DATE,
      limit: 1,
    );
    return moods.length == 0 ? null : deserialize(moods.first);
  }

  Future<Mood?> getMood(int id) async {
    final moods = await db!.query(
      _TABLE_NAME,
      columns: _TABLE_COLUMNS,
      where: '$_COLUMN_ID = ?',
      whereArgs: [id],
    );
    return moods.length == 0 ? null : deserialize(moods.first);
  }

  Future<List<Mood>> getMoods(DateTime rangeStart, DateTime rangeEnd) async {
    final moods = await db!.query(
      _TABLE_NAME,
      columns: _TABLE_COLUMNS,
      orderBy: _COLUMN_DATE,
      where: '$_COLUMN_DATE BETWEEN ? AND ?',
      whereArgs: [rangeStart.millisecondsSinceEpoch, rangeEnd.millisecondsSinceEpoch],
    );
    return moods.map((mood) => deserialize(mood)).toList();
  }
}
