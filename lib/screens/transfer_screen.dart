import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';
import '../widgets/bdu_input.dart';
import '../theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String _source = 'Compte courant';
  final _benefCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _benefCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Virement envoyé à ${_benefCtrl.text} pour ${_amountCtrl.text} XOF',
        ),
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
      appBar: AppBar(title: const Text('Virement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Compte source'),
            const SizedBox(height: 6),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: BduColors.primary),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  value: _source,
                  items: const [
                    DropdownMenuItem(
                      value: 'Compte courant',
                      child: Text('Compte courant'),
                    ),
                    DropdownMenuItem(value: 'Épargne', child: Text('Épargne')),
                  ],
                  onChanged: (v) => setState(() => _source = v ?? _source),
                ),
              ),
            ),
            const SizedBox(height: 16),
            BduInput(
              label: 'Bénéficiaire',
              hintText: 'Nom ou RIB/IBAN',
              controller: _benefCtrl,
            ),
            const SizedBox(height: 16),
            BduInput(
              label: 'Montant',
              hintText: 'Ex: 25000',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            BduButton(
              label: 'Valider',
              type: BduButtonType.secondary,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
