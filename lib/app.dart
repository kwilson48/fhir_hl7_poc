import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_in_screen.dart';

class Dry30App extends StatelessWidget {
  const Dry30App({super.key});

  static const seedColor = Color(0xFF2E7D6B); // calm teal-green

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dry30',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

/// Routes to sign-in → onboarding → home based on auth + profile state.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () => const _Splash(),
      error: (e, _) => _ErrorScreen(message: '$e'),
      data: (user) {
        if (user == null) return const SignInScreen();

        final profile = ref.watch(profileProvider);
        return profile.when(
          loading: () => const _Splash(),
          error: (e, _) => _ErrorScreen(message: '$e'),
          data: (p) {
            if (p == null || !p.onboarded) return const OnboardingScreen();
            return const HomeShell();
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 56)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Something went wrong:\n$message',
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
