import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'features/admin/admin_app.dart';

/// Second entry point of the same project: the company admin panel, built for Flutter Web.
void main() {
  runApp(const AdminRoot());
}

class AdminRoot extends StatelessWidget {
  const AdminRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KÖDER Admin',
      debugShowCheckedModeBanner: false,
      theme: K.theme(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AdminApp(),
    );
  }
}
