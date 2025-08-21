import 'package:flutter/material.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BalanceCard(balance: 1250000.50, currency: 'XOF'),
          const SizedBox(height: 12),
          _QuickActions(
            onAction: (action) {
              switch (action) {
                case 'virement':
                  DefaultTabController.of(context);
                  Navigator.pushNamed(context, '/app');
                  break;
                default:
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Action: $action')));
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Dernières infos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _NewsCard(
            title: 'Nouveaux services BDU Mobile',
            subtitle: 'Découvrez nos fonctionnalités de virement améliorées.',
          ),
          _NewsCard(
            title: 'Sécurité',
            subtitle: 'Activez la double authentification dans votre profil.',
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  const _BalanceCard({required this.balance, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solde disponible',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance.toStringAsFixed(2)} $currency',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: BduColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _ActionChip(label: 'Virement', icon: Icons.swap_horiz),
                SizedBox(width: 8),
                _ActionChip(label: 'Épargne', icon: Icons.savings_outlined),
                SizedBox(width: 8),
                _ActionChip(label: 'Crédit', icon: Icons.credit_score_outlined),
                SizedBox(width: 8),
                _ActionChip(label: 'Assurance', icon: Icons.shield_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ActionChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: BduColors.primary),
      label: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: BduColors.primary),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _QuickActions extends StatelessWidget {
  final void Function(String action) onAction;
  const _QuickActions({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickButton(
          icon: Icons.swap_horiz,
          label: 'Virement',
          color: BduColors.primary,
          onTap: () => onAction('virement'),
        ),
        _QuickButton(
          icon: Icons.savings_outlined,
          label: 'Épargne',
          color: BduColors.secondary,
          onTap: () => onAction('epargne'),
        ),
        _QuickButton(
          icon: Icons.credit_score_outlined,
          label: 'Crédit',
          color: BduColors.primary,
          onTap: () => onAction('credit'),
        ),
        _QuickButton(
          icon: Icons.shield_outlined,
          label: 'Assurance',
          color: BduColors.secondary,
          onTap: () => onAction('assurance'),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _NewsCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined, color: BduColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: TextButton(onPressed: () {}, child: const Text('Voir plus')),
      ),
    );
  }
}
