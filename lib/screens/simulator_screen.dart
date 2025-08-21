import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/bdu_button.dart';
import '../theme.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double _amount = 500000;
  double _months = 12;

  void _calculate() {
    final rate = 0.12;
    final mRate = rate / 12;
    final n = _months;
    final m = _amount * (mRate * (pow(1 + mRate, n))) / (pow(1 + mRate, n) - 1);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Simulation'),
        content: Text('Mensualité estimée: ${m.toStringAsFixed(0)} XOF'),
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
      appBar: AppBar(title: const Text('Simulateur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Montant'),
            Slider(
              value: _amount,
              min: 100000,
              max: 5000000,
              divisions: 50,
              activeColor: BduColors.secondary,
              label: _amount.toStringAsFixed(0),
              onChanged: (v) => setState(() => _amount = v),
            ),
            const SizedBox(height: 8),
            Text('${_amount.toStringAsFixed(0)} XOF'),
            const SizedBox(height: 16),
            const Text('Durée (mois)'),
            Slider(
              value: _months,
              min: 6,
              max: 72,
              divisions: 66,
              activeColor: BduColors.secondary,
              label: _months.toStringAsFixed(0),
              onChanged: (v) => setState(() => _months = v),
            ),
            const SizedBox(height: 8),
            Text('${_months.toStringAsFixed(0)} mois'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: BduButton(
                label: 'Calculer',
                type: BduButtonType.secondary,
                onPressed: _calculate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
