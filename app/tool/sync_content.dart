// Bundles /content into the app's assets as the offline fallback.
// Run from app/: dart run tool/sync_content.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final out = Directory('assets/content')..createSync(recursive: true);
  for (final locale in ['de', 'en']) {
    final scenarios = <dynamic>[];
    final files = Directory('../content/scenarios/$locale').listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      scenarios.addAll(jsonDecode(file.readAsStringSync()) as List);
    }
    final cases = <dynamic>[];
    final caseFiles = Directory('../content/cases/$locale').listSync().whereType<File>().toList()..sort((a, b) => a.path.compareTo(b.path));
    for (final file in caseFiles) {
      cases.add(jsonDecode(file.readAsStringSync()));
    }
    File('${out.path}/scenarios_$locale.json').writeAsStringSync(jsonEncode(scenarios));
    File('${out.path}/cases_$locale.json').writeAsStringSync(jsonEncode(cases));
    stdout.writeln('$locale: ${scenarios.length} scenarios, ${cases.length} case files');
  }
}
