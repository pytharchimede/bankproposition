import 'package:flutter/material.dart';
import '../widgets/bdu_input.dart';
import '../theme.dart';

class TransferWizard extends StatefulWidget {
  const TransferWizard({super.key});

  @override
  State<TransferWizard> createState() => _TransferWizardState();
}

class _TransferWizardState extends State<TransferWizard> {
  int _step = 0;
  String _source = 'Compte courant';
  final _amount = TextEditingController();
  final _benef = TextEditingController();
  final _otp = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _benef.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 4) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _finish() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reçu de virement'),
        content: Text(
          'Source: $_source\nBénéficiaire: ${_benef.text}\nMontant: ${_amount.text} XOF\nRéf: VR-${DateTime.now().millisecondsSinceEpoch}',
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
      appBar: AppBar(title: const Text('Virement (Assistant)')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step == 3) {
            _finish();
          } else {
            _next();
          }
        },
        onStepCancel: _back,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(_step == 3 ? 'Terminer' : 'Suivant'),
              ),
              const SizedBox(width: 12),
              if (_step > 0)
                OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Précédent'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Détails'),
            isActive: _step >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compte source'),
                const SizedBox(height: 6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: BduColors.primary),
                    borderRadius: BorderRadius.circular(8),
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
                        DropdownMenuItem(
                          value: 'Épargne',
                          child: Text('Épargne'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _source = v ?? _source),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BduInput(
                  label: 'Montant',
                  hintText: 'Ex: 25000',
                  controller: _amount,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Bénéficiaire'),
            isActive: _step >= 1,
            content: BduInput(
              label: 'Nom / RIB',
              hintText: 'Ex: KONE AWA / CI12...',
              controller: _benef,
            ),
          ),
          Step(
            title: const Text('Récapitulatif'),
            isActive: _step >= 2,
            content: Card(
              child: ListTile(
                title: const Text('Virement'),
                subtitle: Text(
                  'Source: $_source\nBénéficiaire: ${_benef.text}\nMontant: ${_amount.text} XOF',
                ),
              ),
            ),
          ),
          Step(
            title: const Text('OTP'),
            isActive: _step >= 3,
            content: TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(hintText: 'Code à 6 chiffres'),
            ),
          ),
          Step(
            title: const Text('Reçu'),
            isActive: _step >= 4,
            content: const Text('Un reçu sera affiché à la fin.'),
          ),
        ],
      ),
    );
  }
}
