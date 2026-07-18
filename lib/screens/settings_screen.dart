import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../providers.dart';

/// Settings: streak start date, savings inputs, compassionate reset,
/// attempt history, sign out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(activeAttemptProvider).valueOrNull;
    final profile = ref.watch(profileProvider).valueOrNull;
    final attempts = ref.watch(allAttemptsProvider).valueOrNull ?? const [];
    final user = ref.watch(authStateProvider).valueOrNull;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (attempt != null)
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Streak start date'),
              subtitle: Text(DateFormat.yMMMMd().format(attempt.startDate)),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: attempt.startDate,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                );
                if (picked != null) {
                  await ref.read(firestoreServiceProvider)?.updateStartDate(
                      attempt.id,
                      DateTime(picked.year, picked.month, picked.day));
                }
              },
            ),
          if (profile != null)
            ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: const Text('Savings estimates'),
              subtitle: Text(
                  '\$${profile.weeklySpendUsd}/week · ${profile.drinksPerWeek} drinks/week'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editSavings(context, ref, profile),
            ),
          const Divider(height: 32),
          if (profile != null) ...[
            Text('Notifications',
                style: Theme.of(context).textTheme.titleMedium),
            SwitchListTile(
              secondary: const Icon(Icons.emoji_events_outlined),
              title: const Text('Milestone unlocked alerts'),
              value: profile.milestoneAlerts,
              onChanged: (v) => _saveProfile(
                  ref, profile.copyWith(milestoneAlerts: v)),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Daily check-in reminder'),
              value: profile.dailyReminder,
              onChanged: (v) =>
                  _saveProfile(ref, profile.copyWith(dailyReminder: v)),
            ),
            if (profile.dailyReminder)
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Reminder time'),
                subtitle: Text(_hourLabel(profile.reminderHour)),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime:
                        TimeOfDay(hour: profile.reminderHour, minute: 0),
                  );
                  if (picked != null) {
                    await _saveProfile(
                        ref, profile.copyWith(reminderHour: picked.hour));
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Support contact'),
              subtitle: Text(profile.supportContactPhone?.isNotEmpty == true
                  ? '${profile.supportContactName ?? ''} · ${profile.supportContactPhone}'
                  : 'Someone to call from the SOS screen'),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editSupportContact(context, ref, profile),
            ),
            const Divider(height: 32),
          ],
          if (attempt != null)
            ListTile(
              leading: Icon(Icons.refresh,
                  color: Theme.of(context).colorScheme.error),
              title: const Text('I had a drink — reset my streak'),
              subtitle: const Text(
                  'No shame. Your history is kept and lifetime days never '
                  'reset. A new 30 days starts today.'),
              onTap: () => _confirmReset(context, ref, attempt.id),
            ),
          const Divider(height: 32),
          if (attempts.length > 1) ...[
            Text('Past attempts',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final a in attempts.where((a) => !a.isActive))
              ListTile(
                dense: true,
                leading: Icon(a.endReason == 'completed'
                    ? Icons.emoji_events_outlined
                    : Icons.history),
                title: Text(
                    '${DateFormat.yMMMd().format(a.startDate)} — ${a.daysIn(DateTime.now())} day${a.daysIn(DateTime.now()) == 1 ? '' : 's'}'),
              ),
            const Divider(height: 32),
          ],
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            subtitle: Text(user?.email ?? user?.phoneNumber ?? ''),
            onTap: () => ref.read(authServiceProvider).signOut(),
          ),
          const SizedBox(height: 24),
          Text(
            'Dry30 shares general wellness information, not medical advice. '
            'If you experience shaking, sweating, or hallucinations when you '
            'stop drinking, seek medical help right away — withdrawal can be '
            'dangerous. In the US, the SAMHSA helpline is 1-800-662-4357.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  static String _hourLabel(int hour) {
    final dt = DateTime(2000, 1, 1, hour);
    return DateFormat.jm().format(dt);
  }

  Future<void> _saveProfile(WidgetRef ref, UserProfile profile) async {
    await ref.read(firestoreServiceProvider)?.saveProfile(profile);
  }

  Future<void> _editSupportContact(
      BuildContext context, WidgetRef ref, UserProfile profile) async {
    final name = TextEditingController(text: profile.supportContactName);
    final phone = TextEditingController(text: profile.supportContactPhone);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone number'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved == true) {
      await _saveProfile(
          ref,
          profile.copyWith(
            supportContactName: name.text.trim(),
            supportContactPhone: phone.text.trim(),
          ));
    }
    name.dispose();
    phone.dispose();
  }

  Future<void> _editSavings(
      BuildContext context, WidgetRef ref, UserProfile profile) async {
    final spend =
        TextEditingController(text: profile.weeklySpendUsd.toString());
    final drinks =
        TextEditingController(text: profile.drinksPerWeek.toString());
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Savings estimates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: spend,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Weekly spend (\$)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: drinks,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Drinks per week'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved == true) {
      await _saveProfile(
          ref,
          profile.copyWith(
            weeklySpendUsd: int.tryParse(spend.text.trim()) ?? 0,
            drinksPerWeek: int.tryParse(drinks.text.trim()) ?? 0,
          ));
    }
    spend.dispose();
    drinks.dispose();
  }

  Future<void> _confirmReset(
      BuildContext context, WidgetRef ref, String attemptId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start fresh?'),
        content: const Text(
            'A slip is a data point, not a failure. Your current attempt '
            'will be saved to history and a new 30-day challenge starts '
            'today.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not yet')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset & restart')),
        ],
      ),
    );
    if (confirmed == true) {
      final now = DateTime.now();
      await ref
          .read(firestoreServiceProvider)
          ?.resetAttempt(attemptId, DateTime(now.year, now.month, now.day));
    }
  }
}
