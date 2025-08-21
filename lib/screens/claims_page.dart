import 'package:flutter/material.dart';
import '../widgets/bdu_button.dart';
import '../widgets/bdu_input.dart';
import '../theme.dart';

class ClaimsPage extends StatefulWidget {
  const ClaimsPage({super.key});

  @override
  State<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> {
  final _tickets = <_Ticket>[];
  String _filter = 'all';

  void _createTicket() {
    final cat = ValueNotifier<String>('Paiement');
    final desc = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Catégorie'),
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<String>(
              valueListenable: cat,
              builder: (context, value, _) => DecoratedBox(
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
                    value: value,
                    items: const [
                      DropdownMenuItem(
                        value: 'Paiement',
                        child: Text('Paiement'),
                      ),
                      DropdownMenuItem(
                        value: 'Virement',
                        child: Text('Virement'),
                      ),
                      DropdownMenuItem(value: 'Carte', child: Text('Carte')),
                    ],
                    onChanged: (v) => cat.value = v ?? value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            BduInput(
              label: 'Description',
              hintText: 'Décrivez votre problème',
              controller: desc,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          BduButton(
            label: 'Créer',
            type: BduButtonType.secondary,
            onPressed: () {
              if (desc.text.isEmpty) return;
              setState(() {
                _tickets.add(
                  _Ticket(
                    id: 'T${_tickets.length + 1}',
                    category: cat.value,
                    description: desc.text,
                    status: 'open',
                  ),
                );
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  List<_Ticket> get _filteredTickets => _filter == 'all'
      ? _tickets
      : _tickets.where((t) => t.status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réclamations'),
        actions: [
          IconButton(onPressed: _createTicket, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Filtre:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tous')),
                    DropdownMenuItem(value: 'open', child: Text('Ouverts')),
                    DropdownMenuItem(value: 'closed', child: Text('Fermés')),
                  ],
                  onChanged: (v) => setState(() => _filter = v ?? 'all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTickets.isEmpty
                ? const Center(child: Text('Aucun ticket'))
                : ListView.separated(
                    itemCount: _filteredTickets.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final t = _filteredTickets[i];
                      return ListTile(
                        leading: Icon(
                          Icons.confirmation_num_outlined,
                          color: t.status == 'open'
                              ? BduColors.warning
                              : BduColors.secondary,
                        ),
                        title: Text('#${t.id} • ${t.category}'),
                        subtitle: Text(t.description),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) => setState(() => t.status = v),
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'open', child: Text('Ouvrir')),
                            PopupMenuItem(
                              value: 'closed',
                              child: Text('Fermer'),
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

class _Ticket {
  final String id;
  final String category;
  final String description;
  String status;
  _Ticket({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
  });
}
