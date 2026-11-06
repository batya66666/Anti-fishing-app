import 'package:flutter/widgets.dart';
import 'package:koeder/l10n/app_localizations.dart';

export 'package:koeder/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}
