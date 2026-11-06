import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/config.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../effects/mascot.dart';
import 'admin_api.dart';
import 'download_web.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  final AdminApi _api = AdminApi();
  bool _signedIn = false;

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _signedIn ? _Console(api: _api) : _Login(api: _api, onDone: () => setState(() => _signedIn = true));
  }
}

class _Login extends StatefulWidget {
  const _Login({required this.api, required this.onDone});
  final AdminApi api;
  final VoidCallback onDone;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final _email = TextEditingController(text: 'thomas@muster-automotive.example');
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = context.l;
    try {
      await widget.api.login(_email.text.trim(), _password.text);
      widget.onDone();
    } on DioException catch (e) {
      setState(() => _error = e.response?.statusCode == 401 ? l.adminBadLogin : l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Center(child: Mascot(mood: MascotMood.happy, size: 100)),
              Text(l.adminTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(l.adminSubtitle, textAlign: TextAlign.center, style: const TextStyle(color: K.muted)),
              const SizedBox(height: 18),
              TextField(controller: _email, decoration: InputDecoration(labelText: l.adminEmail)),
              const SizedBox(height: 10),
              TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: l.adminPassword), onSubmitted: (_) => _submit()),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: K.danger))),
              const SizedBox(height: 14),
              FilledButton(onPressed: _busy ? null : _submit, child: Text(l.adminSignIn)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Console extends StatefulWidget {
  const _Console({required this.api});
  final AdminApi api;

  @override
  State<_Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<_Console> {
  Map<String, dynamic>? _data;
  bool _live = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    widget.api.dashboard().then((d) {
      if (mounted) setState(() => _data = d);
    });
    widget.api.listen((d) {
      if (mounted) setState(() => _data = d);
    }, (c) {
      if (mounted) setState(() => _live = c);
    });
  }

  Future<void> _downloadReport() async {
    final locale = Localizations.localeOf(context).languageCode;
    final bytes = await widget.api.report(locale);
    downloadBytes(bytes, 'koeder-compliance.pdf', 'application/pdf');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = _data;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(children: [
          const Text('KÖDER', style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: K.teal)),
          const SizedBox(width: 14),
          if (d != null) Flexible(child: Text(d['name'] as String, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: K.muted, fontFamily: 'Inter'))),
        ]),
        actions: [
          _LiveDot(live: _live, label: l.adminLive),
          const SizedBox(width: 14),
          SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: 0, label: Text(l.adminTabDashboard), icon: const Icon(Icons.dashboard_outlined, size: 17)),
              ButtonSegment(value: 1, label: Text(l.adminTabScenarios), icon: const Icon(Icons.auto_awesome_outlined, size: 17)),
              ButtonSegment(value: 2, label: Text(l.adminTabJury), icon: const Icon(Icons.qr_code_2, size: 17)),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: d == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _tab, children: [
              _Dashboard(data: d, onReport: _downloadReport),
              _Generator(api: widget.api, companyName: d['name'] as String),
              const _JuryPanel(),
            ]),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot({required this.live, required this.label});
  final bool live;
  final String label;

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: live ? K.teal : K.muted));
    if (live) dot = dot.animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 800.ms, begin: 1);
    return Row(children: [dot, const SizedBox(width: 6), Text(live ? label : '–', style: const TextStyle(color: K.muted, fontSize: 13, fontWeight: FontWeight.w600))]);
  }
}

// ------------------------------------------------------------------ colours for risk

/// One hue, dark to bright: magnitude only. The number in the cell carries the value, so colour is never alone.
Color riskColor(num risk) => Color.lerp(const Color(0xFF1B2A3A), const Color(0xFFFF4D5E), (risk / 70).clamp(0, 1).toDouble())!;

String attackLabel(AppLocalizations l, String t) => switch (t) {
      'invoice_fraud' => l.attackInvoice,
      'credential_phishing' => l.attackCredentials,
      'ceo_fraud' => l.attackCeo,
      'malicious_attachment' => l.attackAttachment,
      'smishing' => l.attackSmishing,
      'vishing' => l.attackVishing,
      'quishing' => l.attackQuishing,
      'mfa_fatigue' => l.attackMfa,
      'legit' => l.attackLegit,
      _ => l.attackOther,
    };

const _heatColumns = ['invoice_fraud', 'ceo_fraud', 'credential_phishing', 'malicious_attachment', 'smishing', 'vishing', 'quishing', 'mfa_fatigue'];

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.data, required this.onReport});
  final Map<String, dynamic> data;
  final Future<void> Function() onReport;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final departments = (data['departments'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final cells = (data['heatmap'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final trend = (data['trend'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final feed = (data['feed'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 1050;
      final left = [
        _Card(
          title: l.adminHeatmap,
          subtitle: l.adminHeatmapSub,
          child: _Heatmap(departments: departments, cells: cells),
        ),
        const SizedBox(height: 14),
        _Card(title: l.adminDepartments, child: _DepartmentTable(departments: departments)),
      ];
      final right = [
        _Card(title: l.adminTrendRisk, subtitle: l.adminTrendRiskSub, child: _TrendChart(points: trend, field: 'risk', color: const Color(0xFFFF7A87), maxY: 80, suffix: '')),
        const SizedBox(height: 14),
        _Card(title: l.adminTrendReporting, subtitle: l.adminTrendReportingSub, child: _TrendChart(points: trend, field: 'reportingRate', color: K.teal, maxY: 100, suffix: ' %')),
        const SizedBox(height: 14),
        _Card(title: l.adminFeed, subtitle: l.adminFeedSub, child: _Feed(feed: feed)),
      ];
      return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        if (data['demoData'] == true)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              const Icon(Icons.science_outlined, size: 16, color: K.warn),
              const SizedBox(width: 6),
              Expanded(child: Text(l.adminDemoData, style: const TextStyle(color: K.warn, fontSize: 13))),
              OutlinedButton.icon(onPressed: onReport, icon: const Icon(Icons.picture_as_pdf_outlined, size: 18), label: Text(l.adminReport)),
            ]),
          ),
        _Kpis(data: data),
        const SizedBox(height: 14),
        if (wide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: Column(children: left)),
            const SizedBox(width: 14),
            Expanded(flex: 2, child: Column(children: right)),
          ])
        else ...[
          ...left,
          const SizedBox(height: 14),
          ...right,
        ],
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lock_outline, size: 15, color: K.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(l.adminPrivacy((data['minDepartmentSize'] as num).toInt()), style: Theme.of(context).textTheme.bodySmall)),
        ]),
      ]);
    });
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: K.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 16.5)),
        if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final risk = (data['risk'] as num?)?.toInt();
    final (riskWord, riskColor_, riskIcon) = switch (risk ?? 0) {
      < 25 => (l.riskLow, K.teal, Icons.verified_user_outlined),
      < 45 => (l.riskMedium, K.warn, Icons.shield_outlined),
      _ => (l.riskHigh, K.danger, Icons.gpp_maybe_outlined),
    };
    return LayoutBuilder(builder: (context, c) {
      final tiles = <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: riskColor_.withValues(alpha: 0.6))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.adminRisk, style: const TextStyle(color: K.muted, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text('${risk ?? '–'}', key: ValueKey(risk), style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 52, height: 1)),
              ),
              const Text(' / 100', style: TextStyle(color: K.muted, fontSize: 15)),
              const Spacer(),
              Icon(riskIcon, color: riskColor_, size: 18),
              const SizedBox(width: 4),
              Text(riskWord, style: TextStyle(color: riskColor_, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
        _Kpi(label: l.adminReportingRate, value: '${data['reportingRate'] ?? '–'} %', hint: l.adminReportingHint),
        _Kpi(label: l.adminClickRate, value: '${data['clickRate'] ?? '–'} %', hint: l.adminClickHint),
        _Kpi(label: l.adminDecisions, value: '${data['answers']}', hint: l.adminDecisionsHint),
      ];
      if (c.maxWidth > 900) {
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(flex: 2, child: tiles[0]),
            for (final t in tiles.skip(1)) ...[const SizedBox(width: 12), Expanded(child: t)],
          ]),
        );
      }
      return Wrap(runSpacing: 10, children: [for (final t in tiles) SizedBox(width: double.infinity, child: t)]);
    });
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.hint});
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: K.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: K.muted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 32, height: 1.1)),
        const SizedBox(height: 4),
        Text(hint, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

/// Department × attack type. Which group needs which training, at one glance. Never who.
class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.departments, required this.cells});
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> cells;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    int? risk(String depId, String type) {
      for (final c in cells) {
        if (c['departmentId'] == depId && c['attackType'] == type) return (c['risk'] as num?)?.toInt();
      }
      return null;
    }

    final visible = departments.where((d) => d['hidden'] != true).toList()
      ..sort((a, b) => ((b['risk'] as num?) ?? 0).compareTo((a['risk'] as num?) ?? 0));
    final hidden = departments.where((d) => d['hidden'] == true).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (context, c) {
        const nameW = 118.0;
        final cellW = max(52.0, (c.maxWidth - nameW) / _heatColumns.length);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const SizedBox(width: nameW),
              for (final t in _heatColumns)
                SizedBox(
                  width: cellW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(attackLabel(l, t), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: K.muted, fontSize: 11, fontWeight: FontWeight.w600, height: 1.15)),
                  ),
                ),
            ]),
            const SizedBox(height: 6),
            for (final d in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  SizedBox(width: nameW, child: Text(d['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  for (final t in _heatColumns)
                    SizedBox(
                      width: cellW,
                      height: 36,
                      child: Padding(padding: const EdgeInsets.all(1), child: _HeatCell(department: d['name'] as String, attack: attackLabel(l, t), risk: risk(d['id'] as String, t))),
                    ),
                ]),
              ),
          ]),
        );
      }),
      const SizedBox(height: 10),
      Row(children: [
        Text(l.adminLegendLow, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 6),
        Container(
          width: 120,
          height: 8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), gradient: LinearGradient(colors: [riskColor(0), riskColor(35), riskColor(70)])),
        ),
        const SizedBox(width: 6),
        Text(l.adminLegendHigh, style: Theme.of(context).textTheme.bodySmall),
      ]),
      if (hidden.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l.adminHidden(hidden.map((d) => d['name']).join(', ')), style: Theme.of(context).textTheme.bodySmall),
        ),
    ]);
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.department, required this.attack, required this.risk});
  final String department;
  final String attack;
  final int? risk;

  @override
  Widget build(BuildContext context) {
    final r = risk;
    return Tooltip(
      message: '$department · $attack: ${r ?? '–'}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(color: r == null ? K.bg : riskColor(r), borderRadius: BorderRadius.circular(5)),
        alignment: Alignment.center,
        child: Text(r == null ? '' : '$r', style: const TextStyle(fontFamily: K.mono, fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _DepartmentTable extends StatelessWidget {
  const _DepartmentTable({required this.departments});
  final List<Map<String, dynamic>> departments;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final rows = [...departments]..sort((a, b) => ((b['risk'] as num?) ?? -1).compareTo((a['risk'] as num?) ?? -1));
    const head = TextStyle(color: K.muted, fontSize: 12, fontWeight: FontWeight.w600);
    return Column(children: [
      Row(children: [
        Expanded(flex: 3, child: Text(l.adminColDepartment, style: head)),
        Expanded(child: Text(l.adminColSize, textAlign: TextAlign.right, style: head)),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: Text(l.adminColRisk, style: head)),
        Expanded(child: Text(l.adminColReporting, textAlign: TextAlign.right, style: head)),
      ]),
      const Divider(height: 14),
      for (final d in rows)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            Expanded(flex: 3, child: Text(d['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
            Expanded(child: Text('${d['headcount']}', textAlign: TextAlign.right, style: const TextStyle(fontFamily: K.mono, fontSize: 13))),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: d['hidden'] == true
                  ? Text(l.adminTooSmall, style: Theme.of(context).textTheme.bodySmall)
                  : Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: ((d['risk'] as num?) ?? 0) / 100, minHeight: 7, backgroundColor: K.surface2, color: const Color(0xFFFF7A87)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(width: 24, child: Text('${d['risk'] ?? '–'}', textAlign: TextAlign.right, style: const TextStyle(fontFamily: K.mono, fontSize: 13, fontWeight: FontWeight.w700))),
                    ]),
            ),
            Expanded(child: Text(d['hidden'] == true ? '' : '${d['reportingRate'] ?? '–'} %', textAlign: TextAlign.right, style: const TextStyle(fontFamily: K.mono, fontSize: 13))),
          ]),
        ),
    ]);
  }
}

/// One measure per chart: risk and reporting have different meanings and scales, so they never share an axis.
class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points, required this.field, required this.color, required this.maxY, required this.suffix});
  final List<Map<String, dynamic>> points;
  final String field;
  final Color color;
  final double maxY;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    final labels = <int, String>{};
    for (final (i, p) in points.indexed) {
      final v = p[field] as num?;
      final week = DateTime.tryParse(p['week'] as String);
      if (week != null) labels[i] = '${week.day}.${week.month}.';
      if (v != null) spots.add(FlSpot(i.toDouble(), v.toDouble()));
    }
    if (spots.length < 2) return const SizedBox(height: 40);
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => const FlLine(color: K.line, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: maxY / 4,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(color: K.muted, fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 2,
                getTitlesWidget: (v, _) => Text(labels[v.toInt()] ?? '', style: const TextStyle(color: K.muted, fontSize: 11)),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => K.surface2,
              getTooltipItems: (items) => items.map((i) => LineTooltipItem('${labels[i.x.toInt()] ?? ''}  ${i.y.toStringAsFixed(field == 'risk' ? 0 : 1)}$suffix', const TextStyle(color: K.ink, fontWeight: FontWeight.w600, fontSize: 12))).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({required this.feed});
  final List<Map<String, dynamic>> feed;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    if (feed.isEmpty) return Text(l.adminFeedEmpty, style: const TextStyle(color: K.muted, fontSize: 13.5));
    return Column(children: [
      for (final f in feed.take(7))
        Padding(
          key: ValueKey('${f['at']}${f['department']}'),
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(children: [
            Icon(
              switch (f['kind']) {
                'reported' => Icons.flag,
                'hacked' => Icons.gpp_bad,
                'handled' => Icons.check_circle_outline,
                _ => Icons.help_outline,
              },
              size: 17,
              color: switch (f['kind']) {
                'reported' => K.teal,
                'hacked' => K.danger,
                'handled' => K.blue,
                _ => K.warn,
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.adminFeedLine(
                  f['department'] as String,
                  switch (f['kind']) {
                    'reported' => l.feedReported,
                    'hacked' => l.feedHacked,
                    'handled' => l.feedHandled,
                    _ => l.feedMissed,
                  },
                  attackLabel(l, f['attackType'] as String),
                ),
                style: const TextStyle(fontSize: 13.5),
              ),
            ),
          ]),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.04, end: 0),
    ]);
  }
}

/// "We are a car parts supplier using SAP" → scenarios for this company, as drafts a human reviews first.
class _Generator extends StatefulWidget {
  const _Generator({required this.api, required this.companyName});
  final AdminApi api;
  final String companyName;

  @override
  State<_Generator> createState() => _GeneratorState();
}

class _GeneratorState extends State<_Generator> {
  late final _company = TextEditingController(text: widget.companyName);
  final _industry = TextEditingController(text: 'Automobilzulieferer');
  final _tools = TextEditingController(text: 'SAP, OfficeCloud');
  final _partners = TextEditingController(text: 'Kessler Stahl, Bauer Elektrik');
  bool _busy = false;
  String? _source;
  String? _error;
  List<Map<String, dynamic>> _drafts = [];
  final Set<String> _published = {};

  @override
  void dispose() {
    _company.dispose();
    _industry.dispose();
    _tools.dispose();
    _partners.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final locale = Localizations.localeOf(context).languageCode;
    final l = context.l;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await widget.api.generate(company: _company.text, industry: _industry.text, tools: _tools.text, partners: _partners.text, employees: 300, count: 4, locale: locale);
      setState(() {
        _source = r['source'] as String;
        _drafts = (r['scenarios'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      });
    } catch (_) {
      setState(() => _error = l.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish(String id) async {
    await widget.api.publish(id);
    setState(() => _published.add(id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
      Narrow(
        maxWidth: 820,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(l.genTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(l.genIntro, style: const TextStyle(color: K.muted, height: 1.4)),
          const SizedBox(height: 14),
          TextField(controller: _company, decoration: InputDecoration(labelText: l.genCompany)),
          const SizedBox(height: 8),
          TextField(controller: _industry, decoration: InputDecoration(labelText: l.genIndustry)),
          const SizedBox(height: 8),
          TextField(controller: _tools, decoration: InputDecoration(labelText: l.genTools)),
          const SizedBox(height: 8),
          TextField(controller: _partners, decoration: InputDecoration(labelText: l.genPartners)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome),
            label: Text(l.genButton),
          ),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: K.danger))),
          if (_source != null) ...[
            const SizedBox(height: 14),
            Row(children: [
              Icon(_source == 'ai' ? Icons.auto_awesome : Icons.description_outlined, size: 16, color: K.warn),
              const SizedBox(width: 6),
              Expanded(child: Text(_source == 'ai' ? l.genSourceAi : l.genSourceTemplate, style: const TextStyle(color: K.warn, fontSize: 13))),
            ]),
            const SizedBox(height: 10),
          ],
          for (final (i, s) in _drafts.indexed)
            _DraftCard(draft: s, published: _published.contains(s['id']), onPublish: () => _publish(s['id'] as String)).animate().fadeIn(delay: (i * 140).ms).slideY(begin: 0.05, end: 0),
        ]),
      ),
    ]);
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.draft, required this.published, required this.onPublish});
  final Map<String, dynamic> draft;
  final bool published;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = Map<String, dynamic>.from(draft['content'] as Map);
    final attack = draft['is_attack'] == true;
    final flags = (draft['red_flags'] as List?) ?? const [];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: K.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Pill(icon: attack ? Icons.phishing : Icons.verified_outlined, label: attack ? l.genAttack : l.genGenuine, color: attack ? K.danger : K.teal),
          const Spacer(),
          if (published)
            Pill(icon: Icons.check, label: l.genPublished, color: K.teal)
          else
            OutlinedButton(onPressed: onPublish, child: Text(l.genPublish)),
        ]),
        const SizedBox(height: 10),
        Text('${c['from_name']} <${c['from_email']}>', style: const TextStyle(fontFamily: K.mono, fontSize: 12.5, color: K.muted)),
        const SizedBox(height: 4),
        Text(c['subject'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 5),
        Text(c['body_md'] as String, style: const TextStyle(height: 1.4, fontSize: 14)),
        if (flags.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final f in flags)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(padding: EdgeInsets.only(top: 2), child: Icon(Icons.flag, size: 13, color: K.danger)),
                const SizedBox(width: 5),
                Expanded(child: Text((f as Map)['hint'] as String, style: const TextStyle(color: K.muted, fontSize: 12.5, height: 1.3))),
              ]),
            ),
        ],
      ]),
    );
  }
}

/// The slide-sized QR code: everyone in the room lands in a duel within seconds.
class _JuryPanel extends StatelessWidget {
  const _JuryPanel();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.juryTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(l.jurySub, textAlign: TextAlign.center, style: const TextStyle(color: K.muted, fontSize: 16)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: QrImageView(data: Config.arenaLink, size: 340, padding: EdgeInsets.zero),
          ),
          const SizedBox(height: 12),
          SelectableText(Config.arenaLink, style: const TextStyle(fontFamily: K.mono, color: K.teal, fontSize: 14)),
        ]),
      ),
    );
  }
}
