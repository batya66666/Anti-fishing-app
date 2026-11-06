import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../effects/mascot.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final app = ref.watch(appProvider);
    final me = app.me;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Simple mode: no ranks, no duels, no pressure.
    if (me.simple) {
      return Scaffold(body: SafeArea(child: _SimpleHome(me: me, offline: app.offline)));
    }
    final tabs = [
      _StartTab(me: me, offline: app.offline),
      const DuelLobbyTab(),
      const LeaguesTab(),
      const ProfileTab(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _tab, children: tabs)),
      bottomNavigationBar: NavigationBar(
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
  const _StartTab({required this.me, required this.offline});
  final Me me;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        sliver: SliverList.list(children: [
          if (offline) const OfflineBanner(),
          Row(children: [
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
          _ShiftCard(me: me),
          const SizedBox(height: 12),
          if (me.reviewsDue > 0) ...[
            _ReviewBanner(count: me.reviewsDue),
            const SizedBox(height: 12),
          ],
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.42,
            children: [
              _ModeTile(icon: Icons.swipe, color: K.violet, title: l.modeSwipe, subtitle: l.swipeLeft(me.energy.swipeRoundsLeft), onTap: () => context.push('/swipe')),
              _ModeTile(icon: Icons.flag_outlined, color: K.danger, title: l.modeFlags, subtitle: l.modeFlagsSub, onTap: () => context.push('/flags')),
              _ModeTile(icon: Icons.folder_special_outlined, color: K.warn, title: l.modeCases, subtitle: l.modeCasesSub, onTap: () => context.push('/cases')),
              _ModeTile(icon: Icons.masks_outlined, color: K.blue, title: l.modeRedTeam, subtitle: l.modeRedTeamSub, onTap: () => context.push('/redteam')),
            ],
          ),
          const SizedBox(height: 10),
          _CheckTile(),
          const SizedBox(height: 18),
          Text(l.skillTree, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(l.skillTreeSub, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          _SkillTree(progress: me.moduleProgress),
          const SizedBox(height: 24),
        ]),
      ),
    ]);
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.me});
  final Me me;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final done = me.energy.shiftCompleted;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: done ? const [K.surface, K.surface2] : const [Color(0xFF0F4D47), Color(0xFF12334A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: done ? K.line : K.teal.withValues(alpha: 0.6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(done ? Icons.nightlight_round : Icons.mark_email_unread_outlined, color: done ? K.muted : K.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(done ? l.shiftDoneTitle : l.shiftCardTitle, style: Theme.of(context).textTheme.titleLarge)),
        ]),
        const SizedBox(height: 6),
        Text(done ? l.shiftDoneBody : l.shiftCardBody, style: const TextStyle(color: K.ink, fontSize: 14.5, height: 1.4)),
        if (!done) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Sfx.click();
                context.push('/shift');
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l.shiftStart),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2200.ms, delay: 1200.ms, color: Colors.white24),
        ],
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

class _CheckTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Material(
      color: K.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/check'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: K.line)),
          child: Row(children: [
            const Icon(Icons.policy_outlined, color: K.teal, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.checkTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                Text(l.checkTileSub, style: const TextStyle(color: K.muted, fontSize: 12.5)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: K.muted),
          ]),
        ),
      ),
    );
  }
}

String moduleName(AppLocalizations l, int n) => [
      l.module1, l.module2, l.module3, l.module4, l.module5, l.module6, l.module7, l.module8, l.module9, l.module10, l.module11, l.module12, l.module13,
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
  const _SkillTree({required this.progress});
  final Map<int, int> progress;

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
              child: _ModuleNode(n: i + 1, name: moduleName(l, i + 1), solved: progress[i + 1] ?? 0),
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

class _ModuleNode extends StatelessWidget {
  const _ModuleNode({required this.n, required this.name, required this.solved});
  final int n;
  final String name;
  final int solved;

  @override
  Widget build(BuildContext context) {
    final stars = solved.clamp(0, 3);
    final color = stars >= 2 ? K.teal : (stars == 1 ? K.warn : K.muted);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Sfx.click();
        context.push('/module/$n');
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: stars >= 2 ? K.tealDim : K.surface,
            border: Border.all(color: color, width: 2.5),
            boxShadow: stars >= 2 ? [BoxShadow(color: K.teal.withValues(alpha: 0.3), blurRadius: 14)] : null,
          ),
          child: Icon(moduleIcon(n), color: color, size: 25),
        ),
        const SizedBox(height: 3),
        Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.15)),
      ]),
    );
  }
}

/// For people who want protection, not a game: big, calm, no ranks, no timers.
class _SimpleHome extends ConsumerWidget {
  const _SimpleHome({required this.me, required this.offline});
  final Me me;
  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    return ListView(padding: const EdgeInsets.all(20), children: [
      if (offline) const OfflineBanner(),
      const Center(child: Mascot(mood: MascotMood.happy, size: 120)),
      Text(l.simpleWelcome, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 18),
      _BigButton(icon: Icons.school_outlined, title: l.simplePractice, body: l.simplePracticeBody, onTap: () => context.push('/shift'), enabled: !me.energy.shiftCompleted, doneText: l.simplePracticeDone),
      const SizedBox(height: 12),
      _BigButton(icon: Icons.policy_outlined, title: l.checkTitle, body: l.checkTileSub, onTap: () => context.push('/check')),
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
  const _BigButton({required this.icon, required this.title, required this.body, required this.onTap, this.enabled = true, this.doneText});
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool enabled;
  final String? doneText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? K.surface2 : K.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Icon(enabled ? icon : Icons.check_circle, size: 38, color: K.teal),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(enabled ? body : (doneText ?? body), style: const TextStyle(fontSize: 15, color: K.ink, height: 1.3)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
