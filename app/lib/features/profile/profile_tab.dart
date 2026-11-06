import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/sfx.dart';
import '../../core/theme.dart';
import '../../data/models.dart';

const allBadges = [
  'first_shift', 'perfect_shift', 'first_report', 'reporter_25', 'ceo_proof', 'mfa_iron', 'macro_hunter', 'homoglyph_eye', 'qr_sceptic',
  'first_duel', 'duel_winner', 'streak_3', 'streak_7', 'learned_the_hard_way',
];

(String, IconData) badgeInfo(AppLocalizations l, String id) => switch (id) {
      'first_shift' => (l.badgeFirstShift, Icons.work_outline),
      'perfect_shift' => (l.badgePerfectShift, Icons.star_outline),
      'first_report' => (l.badgeFirstReport, Icons.flag_outlined),
      'reporter_25' => (l.badgeReporter, Icons.campaign_outlined),
      'ceo_proof' => (l.badgeCeo, Icons.business_center_outlined),
      'mfa_iron' => (l.badgeMfa, Icons.notifications_off_outlined),
      'macro_hunter' => (l.badgeMacro, Icons.bug_report_outlined),
      'homoglyph_eye' => (l.badgeHomoglyph, Icons.visibility_outlined),
      'qr_sceptic' => (l.badgeQr, Icons.qr_code_2),
      'first_duel' => (l.badgeFirstDuel, Icons.sports_mma_outlined),
      'duel_winner' => (l.badgeDuelWinner, Icons.emoji_events_outlined),
      'streak_3' => (l.badgeStreak3, Icons.local_fire_department_outlined),
      'streak_7' => (l.badgeStreak7, Icons.whatshot_outlined),
      _ => (l.badgeHardWay, Icons.healing_outlined),
    };

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final me = ref.watch(appProvider).me;
    if (me == null) return const SizedBox.shrink();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
      Row(children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _pickAvatar(context, ref, me),
          child: Avatars.of(me.avatar, size: 68),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: () => _rename(context, ref, me),
              child: Row(children: [
                Flexible(child: Text(me.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge)),
                const SizedBox(width: 6),
                const Icon(Icons.edit_outlined, size: 16, color: K.muted),
              ]),
            ),
            Text(l.levelLine(me.level, me.title), style: const TextStyle(color: K.teal, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.08,
        children: [
          _Stat(value: me.reportingRate == null ? '–' : '${me.reportingRate}%', label: l.statReporting, color: K.teal),
          _Stat(value: me.accuracy == null ? '–' : '${me.accuracy}%', label: l.statAccuracy, color: K.blue),
          _Stat(value: '${me.bestStreak}', label: l.statBestStreak, color: K.warn),
          _Stat(value: '${me.attacksReported}', label: l.statReported, color: K.teal),
          _Stat(value: '${me.timesHacked}', label: l.statHacked, color: K.danger),
          _Stat(value: '${me.falseAlarms}', label: l.statFalseAlarms, color: K.warn),
        ],
      ),
      const SizedBox(height: 18),
      Text(l.badges, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.78,
        children: [for (final b in allBadges) _Badge(id: b, earned: me.badges.contains(b))],
      ),
      const SizedBox(height: 20),
      Text(l.settings, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      _SettingsCard(me: me),
    ]);
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref, Me me) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: K.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: [
            for (var i = 0; i < Avatars.icons.length; i++)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  ref.read(appProvider.notifier).updateSettings(avatar: i);
                  Navigator.pop(ctx);
                },
                child: Avatars.of(i, size: 62),
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Me me) async {
    final l = context.l;
    final controller = TextEditingController(text: me.displayName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.renameTitle),
        content: TextField(controller: controller, maxLength: 40, autofocus: true, onSubmitted: (v) => Navigator.pop(ctx, v)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(l.save)),
        ],
      ),
    );
    controller.dispose();
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(appProvider.notifier).updateSettings(name: name.trim());
    }
  }
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard({required this.me});
  final Me me;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final app = ref.read(appProvider.notifier);
    final locale = ref.watch(appProvider.select((s) => s.locale));
    return Container(
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: K.line)),
      child: Column(children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l.settingLanguage),
          trailing: DropdownButton<String>(
            value: locale,
            underline: const SizedBox.shrink(),
            items: const [DropdownMenuItem(value: 'de', child: Text('Deutsch')), DropdownMenuItem(value: 'en', child: Text('English'))],
            onChanged: (v) => app.updateSettings(locale: v),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_outlined),
          title: Text(l.settingSound),
          value: Sfx.enabled,
          onChanged: app.setSound,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.favorite_border),
          title: Text(l.modeSimple),
          subtitle: Text(l.modeSimpleBody, style: const TextStyle(color: K.muted, fontSize: 12.5)),
          value: me.simple,
          onChanged: (v) => app.updateSettings(mode: v ? 'simple' : 'standard'),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.leaderboard_outlined),
          title: Text(l.settingPublicBoard),
          value: me.publicBoard,
          onChanged: (v) => app.updateSettings(publicBoard: v),
        ),
        ListTile(
          leading: const Icon(Icons.workspace_premium_outlined, color: K.warn),
          title: Text(l.premiumTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/premium'),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: Text(l.settingExport),
          subtitle: Text(l.settingExportSub, style: const TextStyle(color: K.muted, fontSize: 12.5)),
          onTap: () async {
            final data = await app.repo.exportData();
            await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.settingExportDone)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever_outlined, color: K.danger),
          title: Text(l.settingDelete, style: const TextStyle(color: K.danger)),
          onTap: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l.settingDelete),
                content: Text(l.settingDeleteBody),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                  FilledButton(style: FilledButton.styleFrom(backgroundColor: K.danger, foregroundColor: Colors.white), onPressed: () => Navigator.pop(ctx, true), child: Text(l.settingDeleteConfirm)),
                ],
              ),
            );
            if (ok == true) {
              await app.deleteAccount();
              if (context.mounted) context.go('/onboarding');
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.replay_circle_filled_outlined, color: K.muted),
          title: Text(l.settingDemoReset),
          subtitle: Text(l.settingDemoResetSub, style: const TextStyle(color: K.muted, fontSize: 12.5)),
          onTap: () async {
            try {
              await app.demoReset();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.settingDemoResetDone)));
            } catch (_) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.errorGeneric)));
            }
          },
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: K.line)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 24, color: color)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted, fontSize: 11.5, height: 1.15)),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.id, required this.earned});
  final String id;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final (name, icon) = badgeInfo(context.l, id);
    return Tooltip(
      message: name,
      child: Column(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: earned ? K.tealDim : K.surface,
            border: Border.all(color: earned ? K.teal : K.line, width: earned ? 2 : 1),
          ),
          child: Icon(icon, color: earned ? K.teal : K.line, size: 25),
        ),
        const SizedBox(height: 4),
        Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, height: 1.1, color: earned ? K.ink : K.muted)),
      ]),
    );
  }
}
