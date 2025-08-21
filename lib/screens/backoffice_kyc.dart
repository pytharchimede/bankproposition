import 'package:flutter/material.dart';
import '../theme.dart';

class BackofficeKYC extends StatefulWidget {
  const BackofficeKYC({super.key});

  @override
  State<BackofficeKYC> createState() => _BackofficeKYCState();
}

class _BackofficeKYCState extends State<BackofficeKYC> {
  final _queue = <_KycItem>[
    _KycItem(id: 'C-1001', name: 'DOE John', risk: 12, status: 'pending'),
    _KycItem(id: 'C-1002', name: 'ACME SARL', risk: 45, status: 'pending'),
  ];

  void _action(_KycItem it, String action) {
    setState(() => it.status = action);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Action $action sur ${it.id}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Back-Office KYC')),
      body: ListView.builder(
        itemCount: _queue.length,
        itemBuilder: (context, i) {
          final it = _queue[i];
          final Color color = it.risk > 40
              ? BduColors.error
              : (it.risk > 20 ? BduColors.warning : BduColors.secondary);
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(it.risk.toString(), style: TextStyle(color: color)),
              ),
              title: Text('${it.name} • ${it.id}'),
              subtitle: Text('Statut: ${it.status}'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) => _action(it, v),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'approved', child: Text('Approuver')),
                  PopupMenuItem(value: 'rejected', child: Text('Rejeter')),
                  PopupMenuItem(
                    value: 'need-info',
                    child: Text('Demander infos'),
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

class _KycItem {
  final String id;
  final String name;
  final int risk;
  String status;
  _KycItem({
    required this.id,
    required this.name,
    required this.risk,
    required this.status,
  });
}
