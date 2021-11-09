import 'package:flutter/material.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
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
