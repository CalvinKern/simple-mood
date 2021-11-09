import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        if (prefs.readyToLoad() != true)
          return Center(child: CircularProgressIndicator());
        else
          return _SettingsPage(prefs);
      },
    );
  }
}

class _SettingsPage extends StatelessWidget {
  final PrefsRepo _prefs;

  const _SettingsPage(this._prefs, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dailyReminderTime = _prefs.getDailyReminderTime();
    final weeklyReminderTime = _prefs.getWeeklyReminderTime();

    return ListView(
      children: [
        _SettingsTile(
          title: l10n.setDailyReminderTitle,
          switchValue: dailyReminderTime != null,
          onChanged: (flag) => _onDailyReminderChanged(context, flag),
        ),
        if (dailyReminderTime != null)
          _SettingsTile(
            title: l10n.setDailyReminderDateTitle,
            subtitle: dailyReminderTime.format(context),
            onTap: () => _onDailyReminderTapped(context, dailyReminderTime),
          ),
        _SettingsTile(
          title: l10n.setWeeklyReminderTitle,
          switchValue: weeklyReminderTime != null,
          onChanged: (flag) => _onWeeklyReminderChanged(context, flag),
        ),
        if (weeklyReminderTime != null)
          _SettingsTile(
            title: l10n.setWeeklyReminderDateTitle(DateFormat.EEEE().format(DateTime.now().toStartOfWeek())),
            subtitle: weeklyReminderTime.format(context),
            onTap: () => _onWeeklyReminderTapped(context, weeklyReminderTime),
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

  void _onWeeklyReminderChanged(BuildContext context, bool on) async => _prefs.setWeeklyReminder(
        title: AppLocalizations.of(context).weeklyReminderNotificationTitle,
        notificationOn: on,
      );

  void _onWeeklyReminderTapped(BuildContext context, TimeOfDay reminderTime) async {
    final time = await showTimePicker(context: context, initialTime: reminderTime);
    if (time == null) return; // Do nothing on a cancel

    _prefs.setWeeklyReminderTime(
      AppLocalizations.of(context).weeklyReminderNotificationTitle,
      time,
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
  final String? subtitle;
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;
  final GestureTapCallback? onTap;

  const _SettingsTile({Key? key, required this.title, this.subtitle, this.switchValue, this.onChanged, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (switchValue != null)
      return SwitchListTile.adaptive(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        value: switchValue!,
        onChanged: onChanged,
      );
    else
      return ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        onTap: onTap,
      );
  }
}
