import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../services/notification_service.dart';
import 'checkin_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';
import 'timeline_screen.dart';

/// Bottom-nav scaffold: Today / Timeline / Check-in / Settings.
/// Also owns notification lifecycle: asks permission once, and reschedules
/// whenever the active attempt or notification prefs change.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    TimelineScreen(),
    CheckInScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermission();
  }

  void _syncNotifications() {
    final attempt = ref.read(activeAttemptProvider).valueOrNull;
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      NotificationService.instance.sync(attempt, profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activeAttemptProvider, (_, __) => _syncNotifications());
    ref.listen(profileProvider, (_, __) => _syncNotifications());

    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Today'),
          NavigationDestination(
              icon: Icon(Icons.timeline_outlined),
              selectedIcon: Icon(Icons.timeline),
              label: 'Benefits'),
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: 'Check-in'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}
