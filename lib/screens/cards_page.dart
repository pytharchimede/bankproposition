import 'package:flutter/material.dart';
import '../theme.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardItem(type: 'VISA', masked: '**** **** **** 1234', active: true),
      _CardItem(
        type: 'GIM-UEMOA',
        masked: '**** **** **** 9876',
        active: false,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Cartes')),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, i) {
          final c = cards[i];
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.credit_card,
                color: c.active ? BduColors.secondary : BduColors.error,
              ),
              title: Text(
                '${c.type} • ${c.masked}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(c.active ? 'Active' : 'Inactif'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$v demandé')));
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Activer', child: Text('Activer')),
                  PopupMenuItem(
                    value: 'Geler/Dégeler',
                    child: Text('Geler/Dégeler'),
                  ),
                  PopupMenuItem(value: 'Opposition', child: Text('Opposition')),
                  PopupMenuItem(
                    value: 'Modifier plafonds',
                    child: Text('Modifier plafonds'),
                  ),
                  PopupMenuItem(value: 'Voir PIN', child: Text('Voir PIN')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CardItem {
  final String type;
  final String masked;
  final bool active;
  _CardItem({required this.type, required this.masked, required this.active});
}
