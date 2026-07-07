import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';
import '../providers.dart';

/// First-run setup: start date (today or a recent past date), and optional
/// spend/drinks numbers that power the savings stats.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  DateTime _startDate = DateTime.now();
  final _spend = TextEditingController();
  final _drinks = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _spend.dispose();
    _drinks.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      // Allow back-dating up to 30 days for people who already started.
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
      helpText: 'When did your alcohol-free streak start?',
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _begin() async {
    final service = ref.read(firestoreServiceProvider);
    final user = ref.read(authStateProvider).valueOrNull;
    if (service == null || user == null) return;

    setState(() => _busy = true);
    try {
      await service.saveProfile(UserProfile(
        uid: user.uid,
        displayName: user.displayName,
        weeklySpendUsd: int.tryParse(_spend.text.trim()) ?? 0,
        drinksPerWeek: int.tryParse(_drinks.text.trim()) ?? 0,
        onboarded: true,
      ));
      // Start the attempt at local midnight of the chosen day so day math is
      // stable regardless of the time of day they signed up.
      await service.startAttempt(
          DateTime(_startDate.year, _startDate.month, _startDate.day));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMMd().format(_startDate);
    final isToday = todayKey() == todayKey(_startDate);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Let\'s set up your 30 days',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Streak started'),
                      subtitle: Text(isToday ? 'Today' : dateLabel),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Optional — powers your "saved so far" stats:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _spend,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Typical weekly spend on alcohol (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _drinks,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Typical drinks per week',
                      prefixIcon: Icon(Icons.local_bar_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _busy ? null : _begin,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Start my 30 days'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
