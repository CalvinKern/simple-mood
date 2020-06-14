import 'package:provider/provider.dart';
import 'package:simple_mood/db/tables/mood_table.dart';
import 'package:simple_mood/models/mood.dart';

import 'repo_helper.dart';

class MoodRepo extends Repo {
  final MoodTable _db;

  MoodRepo([this._db]);

  @override
  ChangeNotifierProxyProvider<MoodTable, MoodRepo> getDbProvider() => ChangeNotifierProxyProvider<MoodTable, MoodRepo>(
        create: (_) => null,
        update: (_, db, __) => db == null ? null : MoodRepo(db),
      );

  @override
  bool readyToLoad() => _db != null;

  Future<Mood> create(Mood mood) async {
    final newMood = _db.insert(mood);
    this.notifyListeners();
    return newMood;
  }

  Future<int> delete(int id) async {
    final oldId = _db.delete(id);
    this.notifyListeners();
    return oldId;
  }

  Future<int> updateMood(Mood mood) async {
    final id = _db.update(mood);
    this.notifyListeners();
    return id;
  }

  Future<Mood> getMood(int id) => _db.getMood(id);

  Future<List<Mood>> getMoods(DateTime rangeStart, DateTime rangeEnd) => _db.getMoods(rangeStart, rangeEnd);
}
