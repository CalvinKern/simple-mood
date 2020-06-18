import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';
import 'package:simple_mood/repos/mood_repo.dart';
import 'package:simple_mood/repos/prefs_repo.dart';
import 'package:simple_mood/screens/extensions/ui_extensions.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrefsRepo>(
      builder: (context, prefs, _) {
        if (prefs?.readyToLoad() != true)
          return Center(child: CircularProgressIndicator());
        else
          return _SettingsPage(prefs);
      },
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final PrefsRepo _prefs;

  const _SettingsPage(this._prefs, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dailyReminderSet = _prefs.getDailyReminderSet() ?? false;
    final dailyReminderTime = _prefs.getDailyReminderTime();

    return ListView(
      children: [
        _SettingsTile(
          title: l10n.setDailyReminderTitle,
          switchValue: dailyReminderSet,
          onChanged: (flag) => _onDailyReminderChanged(context, flag),
        ),
        if (dailyReminderSet)
          _SettingsTile(
            title: l10n.setDailyReminderDateTitle,
            subtitle: dailyReminderTime.format(context),
            onTap: () => _onDailyReminderTapped(context, dailyReminderTime),
          ),
      ],
    );
  }

  void _onDailyReminderChanged(BuildContext context, bool on) async => _prefs.setDailyReminder(
        title: AppLocalizations.of(context).dailyReminderNotificationTitle,
        notificationOn: on,
        hasRatedToday: await _hasRatedMoodToday(context),
      );

  void _onDailyReminderTapped(BuildContext context, TimeOfDay dailyReminderTime) async {
    final time = await showTimePicker(context: context, initialTime: dailyReminderTime);
    if (time == null) return; // Do nothing on a cancel

    _prefs.setDailyReminderTime(
      AppLocalizations.of(context).dailyReminderNotificationTitle,
      time,
      await _hasRatedMoodToday(context),
    );
  }

  Future<bool> _hasRatedMoodToday(BuildContext context) async {
    final start = DateTime.now().toMidnight();
    final end = start.add(Duration(days: 1));
    final moods = await Provider.of<MoodRepo>(context, listen: false).getMoods(start, end);
    return moods.isNotEmpty;
  }
}

/// A simple wrapper around [SwitchListTile] and [ListTile]. If [switchValue] is non-null, then a [SwitchListTile] will
/// be used with the provided [switchValue] and [onChanged].
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool switchValue;
  final ValueChanged<bool> onChanged;
  final GestureTapCallback onTap;

  const _SettingsTile({Key key, this.title, this.subtitle, this.switchValue, this.onChanged, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (switchValue != null)
      return SwitchListTile.adaptive(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        value: switchValue,
        onChanged: onChanged,
      );
    else
      return ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        onTap: onTap,
      );
  }
}
