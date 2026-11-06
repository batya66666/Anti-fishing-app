import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../effects/mascot.dart';
import '../features/cases/cases_screen.dart';
import '../features/check/check_screen.dart';
import '../features/duel/duel_lobby.dart';
import '../features/duel/duel_match.dart';
import '../features/flags/flags_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/premium_screen.dart';
import '../features/practice/practice_screens.dart';
import '../features/redteam/redteam_screen.dart';
import '../features/shift/shift_report.dart';
import '../features/shift/shift_screen.dart';
import '../features/swipe/swipe_screen.dart';
import 'app_state.dart';
import 'theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(appProvider.select((s) => (s.ready, s.onboarded)), (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final app = ref.read(appProvider);
      final path = state.uri.path;
      if (!app.ready) {
        return path == '/splash' ? null : '/splash?next=${Uri.encodeComponent(state.uri.toString())}';
      }
      final target = path == '/splash' ? (state.uri.queryParameters['next'] ?? '/') : path;
      // A jury member arriving through a QR code goes straight into the match.
      if (!app.onboarded && target != '/onboarding' && !target.startsWith('/duel/')) return '/onboarding';
      return path == '/splash' ? target : null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _Splash()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/shift', builder: (_, _) => const ShiftScreen()),
      GoRoute(path: '/shift/report', builder: (_, s) => ShiftReportScreen(summary: s.extra as ShiftSummary?)),
      GoRoute(path: '/swipe', builder: (_, _) => const SwipeScreen()),
      GoRoute(path: '/flags', builder: (_, _) => const FlagsScreen()),
      GoRoute(path: '/review', builder: (_, _) => const ReviewScreen()),
      GoRoute(path: '/module/:n', builder: (_, s) => ModuleScreen(module: int.parse(s.pathParameters['n']!))),
      GoRoute(path: '/cases', builder: (_, _) => const CasesScreen()),
      GoRoute(path: '/cases/:id', builder: (_, s) => CasePlayerScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/redteam', builder: (_, _) => const RedTeamScreen()),
      GoRoute(path: '/check', builder: (_, _) => const CheckScreen()),
      GoRoute(path: '/premium', builder: (_, _) => const PremiumScreen()),
      GoRoute(path: '/duel/arena', builder: (_, _) => const DuelEntryScreen(arena: true)),
      GoRoute(path: '/duel/join/:code', builder: (_, s) => DuelEntryScreen(code: s.pathParameters['code'])),
      GoRoute(path: '/duel/match/:id', builder: (_, s) => DuelMatchScreen(duelId: s.pathParameters['id']!)),
    ],
  );
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Mascot(mood: MascotMood.happy, size: 130),
          SizedBox(height: 10),
          Text('KÖDER', style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 34, letterSpacing: 2)),
        ]),
      ),
    );
  }
}
