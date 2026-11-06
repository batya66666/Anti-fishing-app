import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../effects/mascot.dart';
import '../home/home_screen.dart';

/// All the theory in one place, for whoever wants to read first. Nobody has to: the game teaches by doing.
class TheoryScreen extends StatelessWidget {
  const TheoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.theoryTitle)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        const Center(child: Mascot(mood: MascotMood.neutral, size: 90)),
        Text(l.theoryIntro, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, height: 1.4)),
        const SizedBox(height: 12),
        for (var n = 1; n <= 13; n++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: K.line)),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                leading: Icon(moduleIcon(n), color: K.teal),
                title: Text(moduleName(l, n), style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(moduleTip(l, n), style: const TextStyle(height: 1.45))],
              ),
            ),
          ),
      ]),
    );
  }
}
