import 'package:provider/provider.dart';
import 'package:simple_mood/db/tables/db_table.dart';
import 'package:simple_mood/db/tables/mood_table.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/repo_helper.dart';

class MoodRepo extends Repo {
  final MoodTable db;

  const MoodRepo({this.db}) : super();

  @override
  ProxyProvider<DbTable, Repo> getDbProvider() =>
      ProxyProvider<MoodTable, MoodRepo>(lazy: false, update: (_, db, __) => MoodRepo(db: db));

  Future<Mood> create(Mood mood) async => db.insert(mood);

  Future<int> delete(int id) async => db.delete(id);

  Future<int> updateMood(Mood mood) async => db.update(mood);

  Future<Mood> getMood(int id) async => db.getMood(id);

  Future<List<Mood>> getMoods(DateTime rangeStart, DateTime rangeEnd) async => db.getMoods(rangeStart, rangeEnd);
}
