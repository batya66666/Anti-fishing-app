import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';

/// Plans as a preview. Payments are not part of the hackathon build, and the screen says so.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.premiumTitle)),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        Text(l.premiumIntro, style: const TextStyle(color: K.muted, height: 1.4)),
        const SizedBox(height: 14),
        _Plan(name: 'Free', price: '0 €', body: l.planFree, color: K.teal),
        _Plan(name: 'Premium', price: l.pricePremium, body: l.planPremium, color: K.warn),
        _Plan(name: 'Family', price: l.priceFamily, body: l.planFamily, color: K.violet),
        const SizedBox(height: 10),
        Text(l.premiumB2bTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _Plan(name: 'Team', price: l.priceTeam, body: l.planTeam, color: K.blue),
        _Plan(name: 'Business', price: l.priceBusiness, body: l.planBusiness, color: K.blue),
        _Plan(name: 'Enterprise', price: l.priceEnterprise, body: l.planEnterprise, color: K.blue),
        const SizedBox(height: 6),
        Text(l.premiumNote, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.name, required this.price, required this.body, required this.color});
  final String name;
  final String price;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: K.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: TextStyle(fontFamily: K.display, fontWeight: FontWeight.w700, fontSize: 18, color: color))),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        Text(body, style: const TextStyle(color: K.muted, height: 1.38, fontSize: 13.5)),
      ]),
    );
  }
}
