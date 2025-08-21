import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';
import '../theme.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  double _amount = 500000;
  double _months = 12;

  void _simulate() {
    final rate = 0.12;
    final mRate = rate / 12;
    final n = _months;
    final m = _amount * (mRate * (pow(1 + mRate, n))) / (pow(1 + mRate, n) - 1);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mensualité estimée'),
        content: Text('${m.toStringAsFixed(0)} XOF'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crédit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Simulateur rapide'),
            const SizedBox(height: 8),
            const Text('Montant'),
            Slider(
              value: _amount,
              min: 100000,
              max: 10000000,
              divisions: 100,
              label: _amount.toStringAsFixed(0),
              onChanged: (v) => setState(() => _amount = v),
              activeColor: BduColors.secondary,
            ),
            Text('${_amount.toStringAsFixed(0)} XOF'),
            const SizedBox(height: 12),
            const Text('Durée (mois)'),
            Slider(
              value: _months,
              min: 6,
              max: 84,
              divisions: 78,
              label: _months.toStringAsFixed(0),
              onChanged: (v) => setState(() => _months = v),
              activeColor: BduColors.secondary,
            ),
            Text('${_months.toStringAsFixed(0)} mois'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: BduButton(
                label: 'Calculer',
                type: BduButtonType.secondary,
                onPressed: _simulate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
