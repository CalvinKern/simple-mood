import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class MoodList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodRepo>(
      builder: (context, repo, child) {
        if (repo?.readyToLoad() != true) {
          return Center(child: CircularProgressIndicator());
        }
        return FutureBuilder(
          // Set the future every time the consumer builder is called so we refresh data
          future: repo.getMoods(DateTime.now().add(Duration(days: -7)).toMidnight(), DateTime.now()),
          builder: (context, AsyncSnapshot<List<Mood>> snapshot) {
            if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return _MoodList(moods: snapshot.data);
            }
          },
        );
      },
    );
  }
}

class _MoodList extends StatelessWidget {
  final List<Mood> moods;

  const _MoodList({Key key, this.moods}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check for empty first
    if (moods == null || moods.length == 0) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noMoods,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline4,
        ),
      );
    }
    return ListView.builder(itemCount: moods.length, itemBuilder: (context, index) => _MoodTile(moods[index]));
  }
}

class _MoodTile extends StatelessWidget {
  final Mood mood;

  _MoodTile(this.mood);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(mood.rating.name),
      subtitle: Text(mood.date.fullFormat()),
      onLongPress: () => _deleteMood(context),
    );
  }

  _deleteMood(BuildContext context) async {
    await Provider.of<MoodRepo>(context, listen: false).delete(mood.id);
  }
}
