import 'package:flutter/material.dart';

/// Dark "hacker" shell, friendly neon accents. The simulators inside are deliberately light and realistic.
class K {
  static const bg = Color(0xFF070D14);
  static const surface = Color(0xFF0F1A26);
  static const surface2 = Color(0xFF17273A);
  static const line = Color(0xFF243548);
  static const ink = Color(0xFFEAF2F8);
  static const muted = Color(0xFF93A7BA);
  static const teal = Color(0xFF2EE6C5);
  static const tealDim = Color(0xFF0F3F3B);
  static const danger = Color(0xFFFF4D5E);
  static const dangerDim = Color(0xFF3A141C);
  static const warn = Color(0xFFFFB020);
  static const violet = Color(0xFF9D8CFF);
  static const blue = Color(0xFF55B7FF);

  // Simulator palette: a normal office phone.
  static const simBg = Color(0xFFFFFFFF);
  static const simBg2 = Color(0xFFF2F4F7);
  static const simInk = Color(0xFF1B2733);
  static const simMuted = Color(0xFF647686);
  static const simLine = Color(0xFFE0E5EA);
  static const simLink = Color(0xFF1668D6);

  static const display = 'SpaceGrotesk';
  static const mono = 'JetBrainsMono';

  static ThemeData theme() {
    const scheme = ColorScheme.dark(
      primary: teal,
      onPrimary: Color(0xFF04211D),
      secondary: violet,
      surface: surface,
      onSurface: ink,
      error: danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, fontSize: 32, height: 1.1, color: ink),
        headlineSmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, fontSize: 24, height: 1.15, color: ink),
        titleLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, fontSize: 20, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: ink),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: ink),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: ink),
        bodySmall: TextStyle(fontSize: 12, height: 1.35, color: muted),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, fontSize: 20, color: ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Inter'),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ink,
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Inter'),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: line)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        hintStyle: const TextStyle(color: muted),
      ),
      dividerColor: line,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: surface2, contentTextStyle: TextStyle(color: ink)),
    );
  }
}

/// The eight avatars: simple creatures of the pond.
class Avatars {
  static const icons = <IconData>[
    Icons.phishing,
    Icons.pets,
    Icons.flutter_dash,
    Icons.cruelty_free,
    Icons.bug_report,
    Icons.emoji_nature,
    Icons.sailing,
    Icons.shield_moon,
  ];
  static const colors = <Color>[K.teal, K.warn, K.blue, K.violet, Color(0xFFFF7BAC), Color(0xFF7BE36A), Color(0xFF4FD8FF), Color(0xFFFFD166)];

  static Widget of(int index, {double size = 40}) {
    final i = index % icons.length;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i].withValues(alpha: 0.16), border: Border.all(color: colors[i], width: 1.5)),
      child: Icon(icons[i], color: colors[i], size: size * 0.56),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.icon, required this.label, this.color = K.teal});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }
}

/// Keeps text and controls at a comfortable phone width on tablets and projectors.
class Narrow extends StatelessWidget {
  const Narrow({super.key, required this.child, this.maxWidth = 480});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child));
}
