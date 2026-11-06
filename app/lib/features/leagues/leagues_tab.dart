import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';

class LeaguesTab extends ConsumerStatefulWidget {
  const LeaguesTab({super.key});

  @override
  ConsumerState<LeaguesTab> createState() => _LeaguesTabState();
}

class _LeaguesTabState extends ConsumerState<LeaguesTab> {
  String _scope = 'league';
  late Future<List<BoardRow>> _rows = _load();

  Future<List<BoardRow>> _load() => ref.read(repoProvider).leaderboard(_scope);

  void _select(String scope) {
    setState(() {
      _scope = scope;
      _rows = _load();
    });
  }

  String _tierName(AppLocalizations l, String tier) => switch (tier) {
        'diamond' => l.tierDiamond,
        'gold' => l.tierGold,
        'silver' => l.tierSilver,
        _ => l.tierBronze,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final me = ref.watch(appProvider).me;
    if (me == null) return const SizedBox.shrink();
    final tierColor = switch (me.leagueTier) {
      'diamond' => K.blue,
      'gold' => K.warn,
      'silver' => K.muted,
      _ => const Color(0xFFCD8B5A),
    };
    return RefreshIndicator(
      onRefresh: () async => _select(_scope),
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        Text(l.leagueTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: tierColor.withValues(alpha: 0.7))),
          child: Row(children: [
            Icon(Icons.shield, color: tierColor, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.leagueTier(_tierName(l, me.leagueTier)), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Text(l.leagueSub(me.weeklyXp), style: const TextStyle(color: K.muted, fontSize: 13)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 'league', label: Text(l.boardWeek)),
            ButtonSegment(value: 'global', label: Text(l.boardGlobal)),
            ButtonSegment(value: 'org', label: Text(l.boardCompany)),
          ],
          selected: {_scope},
          onSelectionChanged: (s) => _select(s.first),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<BoardRow>>(
          future: _rows,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()));
            }
            final rows = snap.data ?? const <BoardRow>[];
            if (rows.isEmpty) {
              return Padding(padding: const EdgeInsets.all(26), child: Text(l.boardEmpty, textAlign: TextAlign.center, style: const TextStyle(color: K.muted)));
            }
            return Column(children: [for (final r in rows) _BoardTile(row: r, me: r.userId == me.id)]);
          },
        ),
        const SizedBox(height: 8),
        Text(l.boardPrivacy, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({required this.row, required this.me});
  final BoardRow row;
  final bool me;

  @override
  Widget build(BuildContext context) {
    final rankColor = switch (row.rank) {
      1 => const Color(0xFFFFD166),
      2 => const Color(0xFFC9D6E2),
      3 => const Color(0xFFCD8B5A),
      _ => K.muted,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: me ? K.tealDim : K.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: me ? K.teal : K.line)),
      child: Row(children: [
        SizedBox(width: 28, child: Text('${row.rank}', style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 17, color: rankColor))),
        Avatars.of(row.avatar, size: 34),
        const SizedBox(width: 10),
        Expanded(child: Text(row.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
        if (row.streak > 1) ...[
          const Icon(Icons.local_fire_department, size: 15, color: K.warn),
          Text('${row.streak}', style: const TextStyle(color: K.warn, fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
        ],
        Text('${row.xp} XP', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
      ]),
    );
  }
}
