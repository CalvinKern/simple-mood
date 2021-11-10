import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/dashboard/delete_dialog.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

// TODO: Needs repo setup to get moods
class _MoodList extends StatelessWidget {
  final List<Mood>? moods;

  const _MoodList({Key? key, this.moods}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check for empty first
    if (moods == null || moods!.length == 0) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noMoods,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4,
        ),
      );
    }
    return ListView.builder(itemCount: moods!.length, itemBuilder: (context, index) => _MoodTile(moods![index]));
  }
}

class _MoodTile extends StatelessWidget {
  final Mood _mood;

  _MoodTile(this._mood);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_mood.rating.readableString(context) ?? ""),
      subtitle: Text(_mood.date.fullFormat()),
      onLongPress: () => _askDeleteMood(context),
    );
  }

  _askDeleteMood(BuildContext context) async {
    await DeleteDialog.asDialog(context, _mood);
  }
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo>(builder: (context, repo, child) {
      if (repo.readyToLoad() != true) {
        return Center(child: CircularProgressIndicator());
      }
      return _ListPageBody(moodRepo: repo);
    });
  }
}

class _ListPageBody extends StatelessWidget {
  final MoodRepo moodRepo;

  const _ListPageBody({Key? key, required this.moodRepo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Future<List<Mood>> moodFuture = moodRepo.getOldestMood().then((value) async {
      return value != null ? await moodRepo.getMoods(value.date, DateTime.now()) : List<Mood>.empty();
    });
    return FutureBuilder(future: moodFuture, builder: (context, AsyncSnapshot<List<Mood>> snapshot) {
      if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Failed to load")));
      } else {
        return _MoodList(moods: snapshot.data);
      }
    },);
  }
}

