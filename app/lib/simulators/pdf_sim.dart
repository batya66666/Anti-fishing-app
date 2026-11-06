import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/l10n.dart';
import '../core/sfx.dart';
import '../core/theme.dart';
import 'common.dart';

/// Opens a PDF attachment in a viewer of its own. Looking at a PDF is usually fine: what counts is what you do then.
/// The player's decision comes back to the message through [props].
Future<void> showPdfViewer(BuildContext context, {required String name, required Map<String, dynamic> pdf, required SimProps props}) {
  Sfx.click();
  return Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => PdfViewerSim(name: name, pdf: pdf, props: props),
  ));
}

class PdfViewerSim extends StatelessWidget {
  const PdfViewerSim({super.key, required this.name, required this.pdf, required this.props});
  final String name;
  final Map<String, dynamic> pdf;
  final SimProps props;

  void _act(BuildContext context, String action) {
    Navigator.of(context).pop();
    props.onAction?.call(action);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final lines = ((pdf['lines'] as List?) ?? const []).cast<String>();
    final cta = pdf['cta'] == null ? null : Map<String, dynamic>.from(pdf['cta'] as Map);
    final qr = pdf['qr'] as String?;
    final flagged = props.answered && props.isFlagged('attachment:0');
    return Scaffold(
      backgroundColor: const Color(0xFF3A3F47),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23272E),
        foregroundColor: Colors.white,
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: K.mono, fontSize: 13.5, color: Colors.white)),
        leading: IconButton(icon: const Icon(Icons.close), tooltip: l.close, onPressed: () => Navigator.of(context).pop()),
        actions: const [Padding(padding: EdgeInsets.only(right: 14), child: Center(child: Text('1 / 1', style: TextStyle(color: Colors.white70, fontSize: 13))))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 3))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text((pdf['issuer'] as String?) ?? '', style: const TextStyle(color: K.simMuted, fontSize: 12)),
              const Divider(color: K.simLine, height: 22),
              Text((pdf['title'] as String?) ?? '', style: const TextStyle(color: K.simInk, fontWeight: FontWeight.w700, fontSize: 19, height: 1.25)),
              const SizedBox(height: 14),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Text(line, style: const TextStyle(color: K.simInk, fontSize: 14.5, height: 1.4)),
                ),
              if (qr != null) ...[
                const SizedBox(height: 10),
                Center(
                  child: FlagHighlight(
                    active: flagged,
                    child: Padding(padding: const EdgeInsets.all(6), child: QrImageView(data: qr, size: 150, padding: EdgeInsets.zero)),
                  ),
                ),
                const SizedBox(height: 10),
                if (props.onAction != null)
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: K.simInk, side: const BorderSide(color: K.simLine)),
                      onPressed: () => _act(context, 'scan_open'),
                      icon: const Icon(Icons.qr_code_scanner, size: 19),
                      label: Text(l.pdfScan),
                    ),
                  )
                else
                  Center(child: Text.rich(urlSpan(qr), style: const TextStyle(fontFamily: K.mono, fontSize: 12.5, color: K.simInk))),
              ],
              if (cta != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: FlagHighlight(
                    active: flagged,
                    child: GestureDetector(
                      onLongPress: () => showLinkPeek(context, cta['href'] as String, onOpen: props.onAction == null ? null : () => _act(context, 'click_link')),
                      onSecondaryTap: () => showLinkPeek(context, cta['href'] as String, onOpen: props.onAction == null ? null : () => _act(context, 'click_link')),
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1F5FA8), foregroundColor: Colors.white),
                        onPressed: props.onAction == null ? () => showLinkPeek(context, cta['href'] as String) : () => _act(context, 'click_link'),
                        child: Text(cta['text'] as String),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (props.onAction != null) Center(child: Text(l.pdfHoldHint, textAlign: TextAlign.center, style: const TextStyle(color: K.simMuted, fontSize: 12))),
              ],
            ]),
          ),
        ),
      ),
      bottomNavigationBar: props.onAction == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(l.pdfBack),
                ),
              ),
            ),
    );
  }
}
