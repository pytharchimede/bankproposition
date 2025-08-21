import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';
import '../widgets/bdu_input.dart';
import '../theme.dart';

class BeneficiariesPage extends StatefulWidget {
  const BeneficiariesPage({super.key});

  @override
  State<BeneficiariesPage> createState() => _BeneficiariesPageState();
}

class _BeneficiariesPageState extends State<BeneficiariesPage> {
  final _items = <_Beneficiary>[
    _Beneficiary(
      id: 'B1',
      name: 'KOFFI Jean',
      ibanOrRib: 'CI123456789',
      bankCode: 'BDUCI',
      kycStatus: 'verified',
    ),
    _Beneficiary(
      id: 'B2',
      name: 'ACME SARL',
      ibanOrRib: 'CI987654321',
      bankCode: 'SGBCI',
      kycStatus: 'unverified',
    ),
  ];
  String _q = '';

  List<_Beneficiary> get _filtered => _items
      .where(
        (b) =>
            b.name.toLowerCase().contains(_q.toLowerCase()) ||
            b.ibanOrRib.toLowerCase().contains(_q.toLowerCase()),
      )
      .toList();

  void _openForm({_Beneficiary? item}) {
    final nameCtrl = TextEditingController(text: item?.name);
    final ribCtrl = TextEditingController(text: item?.ibanOrRib);
    String bank = item?.bankCode ?? 'BDUCI';
    String kyc = item?.kycStatus ?? 'unverified';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          item == null ? 'Ajouter un bénéficiaire' : 'Modifier bénéficiaire',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BduInput(
                label: 'Nom',
                controller: nameCtrl,
                hintText: 'Nom complet',
              ),
              const SizedBox(height: 12),
              BduInput(
                label: 'RIB/IBAN',
                controller: ribCtrl,
                hintText: 'Ex: CI12...',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Banque'),
              ),
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
                    value: bank,
                    items: const [
                      DropdownMenuItem(value: 'BDUCI', child: Text('BDU-CI')),
                      DropdownMenuItem(
                        value: 'SGBCI',
                        child: Text('Société Générale'),
                      ),
                      DropdownMenuItem(value: 'NSIA', child: Text('NSIA')),
                    ],
                    onChanged: (v) => bank = v ?? bank,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Statut KYC'),
              ),
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
                    value: kyc,
                    items: const [
                      DropdownMenuItem(
                        value: 'verified',
                        child: Text('Vérifié'),
                      ),
                      DropdownMenuItem(
                        value: 'unverified',
                        child: Text('Non vérifié'),
                      ),
                      DropdownMenuItem(value: 'blocked', child: Text('Bloqué')),
                    ],
                    onChanged: (v) => kyc = v ?? kyc,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          BduButton(
            label: item == null ? 'Ajouter' : 'Enregistrer',
            type: BduButtonType.secondary,
            onPressed: () {
              if (nameCtrl.text.isEmpty || ribCtrl.text.isEmpty) return;
              setState(() {
                if (item == null) {
                  _items.add(
                    _Beneficiary(
                      id: 'B${_items.length + 1}',
                      name: nameCtrl.text,
                      ibanOrRib: ribCtrl.text,
                      bankCode: bank,
                      kycStatus: kyc,
                    ),
                  );
                } else {
                  final idx = _items.indexWhere((e) => e.id == item.id);
                  _items[idx] = _Beneficiary(
                    id: item.id,
                    name: nameCtrl.text,
                    ibanOrRib: ribCtrl.text,
                    bankCode: bank,
                    kycStatus: kyc,
                  );
                }
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bénéficiaires')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = _filtered[i];
                return ListTile(
                  leading: const Icon(
                    Icons.account_circle_outlined,
                    color: BduColors.primary,
                  ),
                  title: Text(b.name),
                  subtitle: Text('${b.bankCode} • ${b.ibanOrRib}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _KycBadge(status: b.kycStatus),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openForm(item: b),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(
                          () => _items.removeWhere((e) => e.id == b.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Beneficiary {
  final String id;
  final String name;
  final String ibanOrRib;
  final String bankCode;
  final String kycStatus;
  _Beneficiary({
    required this.id,
    required this.name,
    required this.ibanOrRib,
    required this.bankCode,
    required this.kycStatus,
  });
}

class _KycBadge extends StatelessWidget {
  final String status;
  const _KycBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'verified':
        color = BduColors.secondary;
        break;
      case 'blocked':
        color = BduColors.error;
        break;
      default:
        color = BduColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
