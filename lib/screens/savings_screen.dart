import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';
import '../widgets/bdu_input.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _amount = TextEditingController();
  final _label = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _label.dispose();
    super.dispose();
  }

  void _open() {
    if (_amount.text.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Épargne ouverte'),
        content: Text(
          'Epargne "${_label.text.isEmpty ? 'Sans nom' : _label.text}" de ${_amount.text} XOF créée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Épargne')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ouvrir un compte épargne'),
            const SizedBox(height: 12),
            BduInput(
              label: 'Libellé (optionnel)',
              controller: _label,
              hintText: 'Mes projets',
            ),
            const SizedBox(height: 12),
            BduInput(
              label: 'Montant initial',
              controller: _amount,
              hintText: 'Ex: 100000',
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            BduButton(
              label: 'Valider',
              type: BduButtonType.secondary,
              onPressed: _open,
            ),
          ],
        ),
      ),
    );
  }
}
