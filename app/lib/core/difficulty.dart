import 'package:flutter/material.dart';

import 'l10n.dart';
import 'theme.dart';

const difficulties = ['bronze', 'silver', 'gold', 'diamond'];

String difficultyName(AppLocalizations l, String d) => switch (d) {
      'bronze' => l.difficultyBronze,
      'silver' => l.difficultySilver,
      'gold' => l.difficultyGold,
      _ => l.difficultyDiamond,
    };

String difficultyBody(AppLocalizations l, String d) => switch (d) {
      'bronze' => l.difficultyBronzeBody,
      'silver' => l.difficultySilverBody,
      'gold' => l.difficultyGoldBody,
      _ => l.difficultyDiamondBody,
    };

IconData difficultyIcon(String d) => d == 'diamond' ? Icons.diamond_outlined : Icons.military_tech_outlined;

Color difficultyColor(String d) => switch (d) {
      'bronze' => const Color(0xFFD08A52),
      'silver' => const Color(0xFFB9C6D2),
      'gold' => const Color(0xFFFFD166),
      _ => K.blue,
    };
