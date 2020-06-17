import 'package:flutter/material.dart';
import 'package:simple_mood/l10n/AppLocalizations.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Placeholder variables until SharedPreferences is up and running
  bool _dailyReminderSet = false;
  TimeOfDay _dailyReminderTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      children: [
        _SettingsTile(
          title: l10n.setDailyReminderTitle,
          switchValue: _dailyReminderSet,
          onChanged: _onDailyReminderChanged,
        ),
        if (_dailyReminderSet)
          _SettingsTile(
            title: l10n.setDailyReminderDateTitle,
            subtitle: _dailyReminderTime?.format(context),
            onTap: _onDailyReminderTapped,
          ),
      ],
    );
  }

  void _onDailyReminderChanged(bool set) {
    setState(() {
      _dailyReminderSet = set;
      if (set && _dailyReminderTime == null) {
        _dailyReminderTime = TimeOfDay.now();
      }
    });
  }

  void _onDailyReminderTapped() async {
    final time = await showTimePicker(context: context, initialTime: _dailyReminderTime);
    if (time == null) return; // Do nothing on a cancel

    setState(() {
      _dailyReminderTime = time;
    });
  }
}

/// A simple wrapper around [SwitchListTile] and [ListTile]. If [switchValue] is non-null, then a [SwitchListTile] will be used
/// with the provided [switchValue] and [onChanged].
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
