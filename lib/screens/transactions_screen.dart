import 'package:flutter/material.dart';
import '../theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txs = List.generate(
      20,
      (i) => _Tx(
        id: 'TX-${1000 + i}',
        label: i % 2 == 0 ? 'Paiement marchand' : 'Virement reçu',
        amount: (i.isEven ? 3500 : -12000) + i * 10,
        date: DateTime.now().subtract(Duration(days: i)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_outlined),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: txs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = txs[index];
          final credit = t.amount >= 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: (credit ? BduColors.secondary : BduColors.error)
                  .withValues(alpha: 0.1),
              child: Icon(
                credit ? Icons.arrow_downward : Icons.arrow_upward,
                color: credit ? BduColors.secondary : BduColors.error,
              ),
            ),
            title: Text(t.label),
            subtitle: Text(
              '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}',
            ),
            trailing: Text(
              '${credit ? '+' : ''}${t.amount.toStringAsFixed(0)} XOF',
              style: TextStyle(
                color: credit ? BduColors.secondary : BduColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Détail de l\'opération'),
                content: Text(
                  'Réf: ${t.id}\nLibellé: ${t.label}\nMontant: ${t.amount} XOF',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Tx {
  final String id;
  final String label;
  final double amount;
  final DateTime date;
  _Tx({
    required this.id,
    required this.label,
    required this.amount,
    required this.date,
  });
}
