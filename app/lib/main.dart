import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_state.dart';
import 'core/l10n.dart';
import 'core/phone_frame.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'effects/hacked_overlay.dart';

void main() {
  runApp(const ProviderScope(child: KoederApp()));
}

class KoederApp extends ConsumerStatefulWidget {
  const KoederApp({super.key});

  @override
  ConsumerState<KoederApp> createState() => _KoederAppState();
}

class _KoederAppState extends ConsumerState<KoederApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(appProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(appProvider.select((s) => s.locale));
    final simple = ref.watch(appProvider.select((s) => s.simple));
    return MaterialApp.router(
      title: 'KÖDER',
      debugShowCheckedModeBanner: false,
      theme: K.theme(),
      routerConfig: router,
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Simple mode: larger type for everyone who needs it, on top of the system setting.
        final scaled = simple ? media.copyWith(textScaler: TextScaler.linear(media.textScaler.scale(1.0) * 1.22)) : media;
        return MediaQuery(
          data: scaled,
          child: HackedLayer(child: PhoneFrame(child: child ?? const SizedBox.shrink())),
        );
      },
    );
  }
}
