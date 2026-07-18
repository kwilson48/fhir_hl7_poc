import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers.dart';

/// Craving SOS: a guided box-breathing exercise (urges typically pass in
/// 3-5 minutes — the goal is to get to the other side of the wave), plus
/// one-tap ways to reach a support person.
class SosScreen extends ConsumerWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final hasContact = profile?.supportContactPhone?.isNotEmpty == true;
    final contactName = profile?.supportContactName?.isNotEmpty == true
        ? profile!.supportContactName!
        : 'your person';

    return Scaffold(
      appBar: AppBar(title: const Text('Ride the wave')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Cravings crest and pass, usually within minutes. '
              'Breathe through this one.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Center(child: _BreathingCircle()),
            const SizedBox(height: 32),
            if (hasContact) ...[
              FilledButton.icon(
                icon: const Icon(Icons.call),
                label: Text('Call $contactName'),
                onPressed: () =>
                    _launch('tel:${profile!.supportContactPhone}', context),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.sms_outlined),
                label: Text('Text $contactName'),
                onPressed: () =>
                    _launch('sms:${profile!.supportContactPhone}', context),
              ),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Tip: add a support contact in Settings and their '
                    'call/text buttons will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text('While you breathe', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _TipTile('🥤', 'Pour something else — sparkling water, tea. '
                'The ritual matters more than the drink.'),
            const _TipTile('🚶', 'Change the scene. A 5-minute walk outlasts '
                'most cravings.'),
            const _TipTile('⏲️', 'Delay, don\'t decide. Tell yourself '
                '"maybe in 20 minutes" — the urge rarely survives the wait.'),
            const _TipTile('📓', 'Remember why you started. Open the Benefits '
                'tab and look at what you\'ve already unlocked.'),
            const SizedBox(height: 24),
            Text(
              'If you\'re in crisis or feel unsafe, call or text 988 (US) '
              'or your local emergency number.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launch(String uri, BuildContext context) async {
    final ok = await launchUrl(Uri.parse(uri));
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn\'t open the dialer here.')));
    }
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile(this.emoji, this.text);

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Box breathing: inhale 4s → hold 4s → exhale 4s → hold 4s, on a loop.
/// The circle grows on inhale, holds, and shrinks on exhale.
class _BreathingCircle extends StatefulWidget {
  const _BreathingCircle();

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  static const _phaseSeconds = 4;
  static const _phases = ['Breathe in', 'Hold', 'Breathe out', 'Hold'];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _phaseSeconds * 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 4; // 0..4 across the four phases
        final phase = t.floor().clamp(0, 3);
        final inPhase = t - phase; // 0..1 within the phase
        // Scale: grows during inhale (0), full during hold (1),
        // shrinks during exhale (2), small during hold (3).
        final scale = switch (phase) {
          0 => 0.6 + 0.4 * Curves.easeInOut.transform(inPhase),
          1 => 1.0,
          2 => 1.0 - 0.4 * Curves.easeInOut.transform(inPhase),
          _ => 0.6,
        };
        final secondsLeft =
            _phaseSeconds - (inPhase * _phaseSeconds).floor();
        return SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220 * scale,
                height: 220 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer,
                  border: Border.all(color: scheme.primary, width: 3),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_phases[phase],
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('$secondsLeft',
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
