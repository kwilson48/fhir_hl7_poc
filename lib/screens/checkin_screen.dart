import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/check_in.dart';
import '../providers.dart';

const _moodEmoji = ['😣', '😕', '😐', '🙂', '😄'];
const _moodLabel = ['Rough', 'Meh', 'Okay', 'Good', 'Great'];
const _cravingLabel = ['None', 'Mild', 'Moderate', 'Strong', 'Intense'];

/// The "Check-in" tab: one quick reflection per day + recent history.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  int? _mood;
  double _craving = 0;
  final _note = TextEditingController();
  bool _busy = false;
  bool _seeded = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _seedFromExisting(CheckIn checkIn) {
    // Pre-fill once so editing today's check-in starts from what was saved.
    if (_seeded) return;
    _seeded = true;
    _mood = checkIn.mood.index;
    _craving = checkIn.craving.toDouble();
    _note.text = checkIn.note ?? '';
  }

  Future<void> _save() async {
    final service = ref.read(firestoreServiceProvider);
    final mood = _mood;
    if (service == null || mood == null) return;
    setState(() => _busy = true);
    try {
      await service.saveCheckIn(CheckIn(
        date: todayKey(),
        mood: Mood.values[mood],
        craving: _craving.round(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checked in. See you tomorrow 👋')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todaysCheckInProvider).valueOrNull;
    if (today != null) _seedFromExisting(today);
    final recent = ref.watch(recentCheckInsProvider).valueOrNull ?? const [];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            today == null ? 'How was today?' : 'Today\'s check-in ✓',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < _moodEmoji.length; i++)
                _MoodButton(
                  emoji: _moodEmoji[i],
                  label: _moodLabel[i],
                  selected: _mood == i,
                  onTap: () => setState(() => _mood = i),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Cravings today: ${_cravingLabel[_craving.round()]}',
              style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _craving,
            max: 4,
            divisions: 4,
            label: _cravingLabel[_craving.round()],
            onChanged: (v) => setState(() => _craving = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Anything worth remembering? (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (_mood == null || _busy) ? null : _save,
            child: Text(today == null ? 'Check in' : 'Update check-in'),
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text('History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final c in recent)
              ListTile(
                leading: Text(_moodEmoji[c.mood.index],
                    style: const TextStyle(fontSize: 24)),
                title: Text(_formatDate(c.date)),
                subtitle: Text([
                  'Cravings: ${_cravingLabel[c.craving.clamp(0, 4)]}',
                  if (c.note != null) c.note!,
                ].join(' · ')),
              ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return key;
    if (key == todayKey()) return 'Today';
    return DateFormat.MMMEd().format(parsed);
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? scheme.secondaryContainer : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: selected ? 32 : 26)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
