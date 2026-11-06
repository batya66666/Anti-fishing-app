import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/difficulty.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/mascot.dart';
import '../../effects/tour.dart';
import '../duel/duel_lobby.dart';
import '../leagues/leagues_tab.dart';
import '../profile/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  bool _tourStarted = false;
  final _tour = _HomeTourKeys();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _tour.scroll.dispose();
    super.dispose();
  }

  /// The first visit gets the guided tour, once the screen has settled.
  void _maybeStartTour() {
    if (_tourStarted || ref.read(appProvider.notifier).tourSeen('home')) return;
    _tourStarted = true;
    Future<void>.delayed(const Duration(milliseconds: 700), _runTour);
  }

  Future<void> _runTour() async {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      _tourStarted = false;
      return;
    }
    setState(() => _tab = 0);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final l = context.l;
    final simple = ref.read(appProvider).simple;
    await runTour(context, [
      TourStep(title: l.tourWelcomeTitle, body: l.tourWelcomeBody, mood: MascotMood.cheering),
      if (simple) ...[
        TourStep(target: _tour.shift, title: l.tourShiftTitle, body: l.tourShiftBody),
        TourStep(target: _tour.check, title: l.tourCheckTitle, body: l.tourCheckBody),
      ] else ...[
        TourStep(target: _tour.level, title: l.tourLevelTitle, body: l.tourLevelBody, mood: MascotMood.cheering),
        TourStep(target: _tour.shift, title: l.tourShiftTitle, body: l.tourShiftBody),
        TourStep(target: _tour.endless, title: l.tourEndlessTitle, body: l.tourEndlessBody),
        TourStep(target: _tour.modes, title: l.tourModesTitle, body: l.tourModesBody, mood: MascotMood.neutral),
        TourStep(target: _tour.check, title: l.tourCheckTitle, body: l.tourCheckBody, mood: MascotMood.worried),
        TourStep(target: _tour.path, title: l.tourPathTitle, body: l.tourPathBody),
        TourStep(target: _tour.nav, slice: (1, 4), padding: 2, title: l.tourDuelTitle, body: l.tourDuelBody, mood: MascotMood.cheering),
        TourStep(target: _tour.nav, slice: (2, 4), padding: 2, title: l.tourLeagueTitle, body: l.tourLeagueBody),
        TourStep(target: _tour.nav, slice: (3, 4), padding: 2, title: l.tourProfileTitle, body: l.tourProfileBody),
      ],
    ]);
    await ref.read(appProvider.notifier).markTour('home');
    // The tour ended far down the page: bring back the shift button it was all about.
    if (_tour.scroll.hasClients) unawaited(_tour.scroll.animateTo(0, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic));
  }

  Future<void> _repeatTour() async {
    await ref.read(appProvider.notifier).resetTours();
    _tourStarted = true;
    await _runTour();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final app = ref.watch(appProvider);
    final me = app.me;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    _maybeStartTour();

    // Simple mode: no ranks, no duels, no pressure.
    if (me.simple) {
      return Scaffold(body: SafeArea(child: _SimpleHome(me: me, offline: app.offline, tour: _tour)));
    }
    final tabs = [
      _StartTab(me: me, offline: app.offline, tour: _tour),
      // A new identity needs a duel connection of its own.
      DuelLobbyTab(key: ValueKey(app.session)),
      const LeaguesTab(),
      ProfileTab(onTour: _repeatTour),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _tab, children: tabs)),
      bottomNavigationBar: NavigationBar(
        key: _tour.nav,
        selectedIndex: _tab,
        height: 66,
        backgroundColor: K.surface,
        indicatorColor: K.tealDim,
        onDestinationSelected: (i) {
          Sfx.click();
          setState(() => _tab = i);
          ref.read(appProvider.notifier).refresh();
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.business_center_outlined), selectedIcon: const Icon(Icons.business_center, color: K.teal), label: l.tabWork),
          NavigationDestination(icon: const Icon(Icons.sports_mma_outlined), selectedIcon: const Icon(Icons.sports_mma, color: K.teal), label: l.tabDuel),
          NavigationDestination(icon: const Icon(Icons.emoji_events_outlined), selectedIcon: const Icon(Icons.emoji_events, color: K.teal), label: l.tabLeague),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person, color: K.teal), label: l.tabProfile),
        ],
      ),
    );
  }
}

class _HomeTourKeys {
  final scroll = ScrollController();
  final level = GlobalKey();
  final shift = GlobalKey();
  final endless = GlobalKey();
  final modes = GlobalKey();
  final check = GlobalKey();
  final path = GlobalKey();
  final nav = GlobalKey();
}

/// Starts today's shift, or another one if that is done. There is no daily limit.
Future<void> _startShift(BuildContext context, WidgetRef ref, Me me) async {
  Sfx.click();
  if (me.energy.shiftCompleted) await ref.read(repoProvider).nextShift();
  if (context.mounted) await context.push('/shift');
  await ref.read(appProvider.notifier).refresh();
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: K.warn.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: K.warn.withValues(alpha: 0.4))),
      child: Row(children: [
        const Icon(Icons.cloud_off, size: 16, color: K.warn),
        const SizedBox(width: 8),
        Expanded(child: Text(context.l.offlineBanner, style: const TextStyle(color: K.warn, fontSize: 13))),
      ]),
    );
  }
}

class _StartTab extends StatelessWidget {
  const _StartTab({required this.me, required this.offline, required this.tour});
  final Me me;
  final bool offline;
  final _HomeTourKeys tour;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    // Not lazy: the guided tour has to be able to point at anything further down.
    return SingleChildScrollView(
      controller: tour.scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (offline) const OfflineBanner(),
          if (me.forcedDifficulty != null) ...[
            _ForcedLevel(level: me.forcedDifficulty!),
            const SizedBox(height: 10),
          ],
          Row(key: tour.level, children: [
            const Mascot(mood: MascotMood.happy, size: 62),
            const SizedBox(width: 6),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(me.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                Text(l.levelLine(me.level, me.title), style: const TextStyle(color: K.teal, fontWeight: FontWeight.w600, fontSize: 13.5)),
              ]),
            ),
            Pill(icon: Icons.local_fire_department, label: '${me.streak}', color: K.warn),
            const SizedBox(width: 6),
            Pill(icon: Icons.toll, label: '${me.coins}', color: K.blue),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(value: me.levelProgress, minHeight: 7, backgroundColor: K.surface2, color: K.teal),
          ),
          const SizedBox(height: 4),
          Text(l.xpLine(me.xp, me.levelCeil), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          KeyedSubtree(key: tour.shift, child: _ShiftCard(me: me)),
          const SizedBox(height: 10),
          KeyedSubtree(key: tour.endless, child: const _EndlessTile()),
          const SizedBox(height: 12),
          if (me.reviewsDue > 0) ...[
            _ReviewBanner(count: me.reviewsDue),
            const SizedBox(height: 12),
          ],
          GridView.count(
            key: tour.modes,
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.42,
            children: [
              _ModeTile(icon: Icons.swipe, color: K.violet, title: l.modeSwipe, subtitle: l.swipeSub, onTap: () => context.push('/swipe')),
              _ModeTile(icon: Icons.flag_outlined, color: K.danger, title: l.modeFlags, subtitle: l.modeFlagsSub, onTap: () => context.push('/flags')),
              _ModeTile(icon: Icons.folder_special_outlined, color: K.warn, title: l.modeCases, subtitle: l.modeCasesSub, onTap: () => context.push('/cases')),
              KeyedSubtree(key: tour.check, child: _ModeTile(icon: Icons.policy_outlined, color: K.teal, title: l.checkTitle, subtitle: l.checkTileSub, onTap: () => context.push('/check'))),
            ],
          ),
          const SizedBox(height: 18),
          Column(key: tour.path, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(l.skillTree, style: Theme.of(context).textTheme.titleLarge)),
              TextButton.icon(onPressed: () => context.push('/theory'), icon: const Icon(Icons.menu_book_outlined, size: 18), label: Text(l.theoryTitle)),
            ]),
            Text(l.skillTreeSub, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            _ContinueCard(me: me),
          ]),
          const SizedBox(height: 12),
          _SkillTree(me: me),
          const SizedBox(height: 24),
      ]),
    );
  }
}

/// A level pinned by the admin is visible: nobody should wonder why everything suddenly got hard.
class _ForcedLevel extends StatelessWidget {
  const _ForcedLevel({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: difficultyColor(level).withValues(alpha: 0.6))),
      child: Row(children: [
        Icon(difficultyIcon(level), size: 17, color: difficultyColor(level)),
        const SizedBox(width: 8),
        Expanded(child: Text(l.difficultyForced(difficultyName(l, level)), style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}

class _EndlessTile extends StatelessWidget {
  const _EndlessTile();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Material(
      color: K.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Sfx.click();
          context.push('/endless');
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: K.teal.withValues(alpha: 0.45))),
          child: Row(children: [
            const Icon(Icons.all_inclusive, color: K.teal, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.endlessTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                Text(l.endlessSub, style: const TextStyle(color: K.muted, fontSize: 12.5)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: K.muted),
          ]),
        ),
      ),
    );
  }
}

/// One tap back to exactly where you stopped.
class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.me});
  final Me me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final next = me.nextModule;
    if (next == null) {
      return Row(children: [
        const Icon(Icons.verified, color: K.teal),
        const SizedBox(width: 8),
        Expanded(child: Text(l.pathDone, style: const TextStyle(fontWeight: FontWeight.w700, color: K.teal))),
      ]);
    }
    final done = me.moduleProgress[next] ?? 0;
    final total = me.moduleTotals[next] ?? 0;
    return Material(
      color: K.tealDim,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          Sfx.click();
          await context.push('/module/$next');
          await ref.read(appProvider.notifier).refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(moduleIcon(next), color: K.teal),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${l.moduleContinue}: ${moduleName(l, next)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(value: total == 0 ? 0 : done / total, minHeight: 5, backgroundColor: K.surface2, color: K.teal),
                ),
                const SizedBox(height: 3),
                Text(l.moduleProgress(done, total), style: const TextStyle(color: K.muted, fontSize: 12)),
              ]),
            ),
            const Icon(Icons.play_arrow_rounded, color: K.teal),
          ]),
        ),
      ),
    );
  }
}

class _ShiftCard extends ConsumerWidget {
  const _ShiftCard({required this.me});
  final Me me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final done = me.energy.shiftCompleted;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0F4D47), Color(0xFF12334A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: K.teal.withValues(alpha: 0.6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(done ? Icons.task_alt : Icons.mark_email_unread_outlined, color: K.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(done ? l.shiftAgainTitle : l.shiftCardTitle, style: Theme.of(context).textTheme.titleLarge)),
        ]),
        const SizedBox(height: 6),
        Text(done ? l.shiftAgainBody : l.shiftCardBody, style: const TextStyle(color: K.ink, fontSize: 14.5, height: 1.4)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _startShift(context, ref, me),
            icon: Icon(done ? Icons.replay : Icons.play_arrow_rounded),
            label: Text(done ? l.shiftAgain : l.shiftStart),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2200.ms, delay: 1200.ms, color: Colors.white24),
      ]),
    );
  }
}

class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Material(
      color: K.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/review'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: K.warn.withValues(alpha: 0.5))),
          child: Row(children: [
            const Icon(Icons.replay, color: K.warn),
            const SizedBox(width: 10),
            Expanded(child: Text(l.reviewDue(count), style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: K.muted),
          ]),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: K.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Sfx.click();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: K.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: color, size: 26),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted, fontSize: 12)),
            ]),
          ]),
        ),
      ),
    );
  }
}

String moduleName(AppLocalizations l, int n) => [
      l.module1, l.module2, l.module3, l.module4, l.module5, l.module6, l.module7, l.module8, l.module9, l.module10, l.module11, l.module12, l.module13,
    ][n - 1];

String moduleTip(AppLocalizations l, int n) => [
      l.tip1, l.tip2, l.tip3, l.tip4, l.tip5, l.tip6, l.tip7, l.tip8, l.tip9, l.tip10, l.tip11, l.tip12, l.tip13,
    ][n - 1];

IconData moduleIcon(int n) => const [
      Icons.psychology_outlined,
      Icons.alternate_email,
      Icons.link,
      Icons.attach_file,
      Icons.receipt_long_outlined,
      Icons.sms_outlined,
      Icons.call_outlined,
      Icons.qr_code_2,
      Icons.key_outlined,
      Icons.laptop_mac_outlined,
      Icons.groups_2_outlined,
      Icons.door_front_door_outlined,
      Icons.health_and_safety_outlined,
    ][n - 1];

/// The curriculum as a winding path, like a map you walk through. Everything is open: learning is never behind a gate.
class _SkillTree extends StatelessWidget {
  const _SkillTree({required this.me});
  final Me me;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return LayoutBuilder(builder: (context, c) {
      const rowH = 94.0;
      final w = c.maxWidth;
      double xOf(int i) => w / 2 + sin(i * 0.95) * (w / 2 - 62);
      return SizedBox(
        height: 13 * rowH + 10,
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _PathPainter(xOf, rowH, 13))),
          for (var i = 0; i < 13; i++)
            Positioned(
              left: xOf(i) - 62,
              top: i * rowH,
              width: 124,
              child: _ModuleNode(n: i + 1, name: moduleName(l, i + 1), solved: me.moduleProgress[i + 1] ?? 0, total: me.moduleTotals[i + 1] ?? 0, current: me.nextModule == i + 1),
            ),
        ]),
      );
    });
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.xOf, this.rowH, this.count);
  final double Function(int) xOf;
  final double rowH;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(xOf(0), 28);
    for (var i = 1; i < count; i++) {
      final x0 = xOf(i - 1), y0 = (i - 1) * rowH + 28;
      final x1 = xOf(i), y1 = i * rowH + 28;
      path.cubicTo(x0, y0 + rowH / 2, x1, y1 - rowH / 2, x1, y1);
    }
    canvas.drawPath(path, Paint()
      ..color = K.surface2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_PathPainter old) => false;
}

class _ModuleNode extends ConsumerWidget {
  const _ModuleNode({required this.n, required this.name, required this.solved, required this.total, required this.current});
  final int n;
  final String name;
  final int solved;
  final int total;

  /// The fish waits at the module to do next.
  final bool current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = total > 0 && solved >= total;
    final started = solved > 0;
    final color = done ? K.teal : (started || current ? K.warn : K.muted);
    final circle = SizedBox(
      width: 58,
      height: 58,
      child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? K.tealDim : K.surface,
            boxShadow: done ? [BoxShadow(color: K.teal.withValues(alpha: 0.3), blurRadius: 14)] : null,
          ),
          child: Icon(done ? Icons.check : moduleIcon(n), color: color, size: 25),
        ),
        SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(value: total == 0 ? 0 : (solved / total).clamp(0.0, 1.0), strokeWidth: 3, backgroundColor: K.surface2, color: color),
        ),
        if (current) const Positioned(right: -30, top: -4, child: IgnorePointer(child: Mascot(mood: MascotMood.happy, size: 38))),
      ]),
    );
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        Sfx.click();
        await context.push('/module/$n');
        await ref.read(appProvider.notifier).refresh();
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        circle,
        const SizedBox(height: 2),
        Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.15)),
        Text('$solved/$total', style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// For people who want protection, not a game: big, calm, no ranks, no timers.
class _SimpleHome extends ConsumerWidget {
  const _SimpleHome({required this.me, required this.offline, required this.tour});
  final Me me;
  final bool offline;
  final _HomeTourKeys tour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return ListView(padding: const EdgeInsets.all(20), children: [
      if (offline) const OfflineBanner(),
      const Center(child: Mascot(mood: MascotMood.happy, size: 120)),
      Text(l.simpleWelcome, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 18),
      KeyedSubtree(
        key: tour.shift,
        child: _BigButton(icon: Icons.school_outlined, title: l.simplePractice, body: me.energy.shiftCompleted ? l.simplePracticeDone : l.simplePracticeBody, onTap: () => _startShift(context, ref, me)),
      ),
      const SizedBox(height: 12),
      KeyedSubtree(key: tour.check, child: _BigButton(icon: Icons.policy_outlined, title: l.checkTitle, body: l.checkTileSub, onTap: () => context.push('/check'))),
      const SizedBox(height: 12),
      if (me.reviewsDue > 0) ...[
        _BigButton(icon: Icons.replay, title: l.simpleReview, body: l.reviewDue(me.reviewsDue), onTap: () => context.push('/review')),
        const SizedBox(height: 12),
      ],
      _BigButton(icon: Icons.menu_book_outlined, title: l.simpleLearn, body: l.simpleLearnBody, onTap: () => context.push('/module/6')),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () => ref.read(appProvider.notifier).updateSettings(mode: 'standard'),
        icon: const Icon(Icons.business_center_outlined),
        label: Text(l.simpleLeave),
      ),
    ]);
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.icon, required this.title, required this.body, required this.onTap});
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: K.surface2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Icon(icon, size: 38, color: K.teal),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 15, color: K.ink, height: 1.3)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
