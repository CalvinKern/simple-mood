import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/models/mood.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class DeleteDialog extends StatelessWidget {
  final Mood _mood;

  const DeleteDialog._internal(this._mood, {Key key}) : super(key: key);

  /// Shows a dialog asking for confirmation before deleting the mood.
  ///
  /// Depends on MoodRepo through Provider
  static Future<void> asDialog(BuildContext context, Mood mood) {
    return showDialog(
      context: context,
      builder: (context) => DeleteDialog._internal(mood),
    );
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Text(AppLocalizations.of(context).deleteMoodTitle),
      actions: <Widget>[
        FlatButton(
          child: Text(material.cancelButtonLabel.toUpperCase()),
          onPressed: () => _pop(context),
        ),
        FlatButton(
          child: Text(material.deleteButtonTooltip.toUpperCase()),
          onPressed: () => _pop(context, deleteMood: true),
        ),
      ],
      content: Text(
        AppLocalizations.of(context).deleteMoodBody(
          _mood.date.fullFormat(),
          _mood.rating.readableString(context),
        ),
      ),
    );
  }

  void _pop(BuildContext context, {bool deleteMood = false}) async {
    if (deleteMood) {
      await Provider.of<MoodRepo>(context, listen: false).delete(_mood.id);
    }
    Navigator.of(context).pop();
  }
}
