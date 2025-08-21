import 'package:flutter/material.dart';
import '../widgets/bdu_input.dart';
import '../widgets/bdu_button.dart';

class ChequebookRequestScreen extends StatefulWidget {
  const ChequebookRequestScreen({super.key});

  @override
  State<ChequebookRequestScreen> createState() =>
      _ChequebookRequestScreenState();
}

class _ChequebookRequestScreenState extends State<ChequebookRequestScreen> {
  String _account = 'Compte courant - ****5678';
  String _format = '50 feuilles';
  bool _pickupBranch = true;
  final _address = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _submit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Demande envoyée'),
        content: Text(
          'Chéquier ($_format) pour "$_account"\n${_pickupBranch ? 'Retrait en agence' : 'Livraison: ${_address.text.isEmpty ? '—' : _address.text}'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demande de chéquier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Compte'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _account,
            items: const [
              DropdownMenuItem(
                value: 'Compte courant - ****5678',
                child: Text('Compte courant - ****5678'),
              ),
              DropdownMenuItem(
                value: 'Épargne - ****5432',
                child: Text('Épargne - ****5432'),
              ),
            ],
            onChanged: (v) => setState(() => _account = v!),
          ),
          const SizedBox(height: 16),
          const Text('Format'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _format,
            items: const [
              DropdownMenuItem(
                value: '25 feuilles',
                child: Text('25 feuilles'),
              ),
              DropdownMenuItem(
                value: '50 feuilles',
                child: Text('50 feuilles'),
              ),
            ],
            onChanged: (v) => setState(() => _format = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Retrait en agence'),
            value: _pickupBranch,
            onChanged: (v) => setState(() => _pickupBranch = v),
          ),
          if (!_pickupBranch) ...[
            const SizedBox(height: 8),
            BduInput(
              label: 'Adresse de livraison',
              controller: _address,
              hintText: 'Rue, ville',
            ),
          ],
          const SizedBox(height: 24),
          BduButton(label: 'Envoyer la demande', onPressed: _submit),
        ],
      ),
    );
  }
}
