import 'package:flutter/material.dart';
import '../theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentAccount = 0;
  bool _hideBalance = false;

  final _accounts = const [
    _Account(
      name: 'Compte courant',
      iban: 'CI00 1234 **** 5678',
      balance: 1_250_000.50,
      currency: 'XOF',
      gradient: [Color(0xFF25579A), Color(0xFF1B3E6F)],
    ),
    _Account(
      name: 'Épargne',
      iban: 'CI00 9876 **** 5432',
      balance: 3_500_000.00,
      currency: 'XOF',
      gradient: [Color(0xFF469C23), Color(0xFF2E6A17)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            tooltip: _hideBalance ? 'Afficher le solde' : 'Masquer le solde',
            icon: Icon(
              _hideBalance
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _hideBalance = !_hideBalance),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Carrousel de comptes
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              onPageChanged: (i) => setState(() => _currentAccount = i),
              itemCount: _accounts.length,
              itemBuilder: (context, i) => _AccountCard(
                account: _accounts[i],
                hideBalance: _hideBalance,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _accounts.length,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentAccount
                      ? BduColors.primary
                      : Colors.black12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _QuickActions(
            onAction: (action) {
              switch (action) {
                case 'virement':
                  Navigator.pushNamed(context, '/transfer-wizard');
                  break;
                default:
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Action: $action')));
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Mes cartes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _BankCard(
                  type: 'VISA',
                  masked: '**** **** **** 1234',
                  gradient: [Color(0xFF25579A), Color(0xFF2E6AAE)],
                ),
                SizedBox(width: 12),
                _BankCard(
                  type: 'GIM-UEMOA',
                  masked: '**** **** **** 9876',
                  gradient: [Color(0xFF469C23), Color(0xFF57B42B)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Dernières infos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const _NewsCard(
            title: 'Nouveaux services BDU Mobile',
            subtitle: 'Découvrez nos fonctionnalités de virement améliorées.',
          ),
          const _NewsCard(
            title: 'Sécurité',
            subtitle: 'Activez la double authentification dans votre profil.',
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final _Account account;
  final bool hideBalance;
  const _AccountCard({required this.account, required this.hideBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: account.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              account.iban,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
            const Spacer(),
            Text(
              hideBalance
                  ? '•••••••• XOF'
                  : '${account.balance.toStringAsFixed(2)} ${account.currency}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Account {
  final String name;
  final String iban;
  final double balance;
  final String currency;
  final List<Color> gradient;
  const _Account({
    required this.name,
    required this.iban,
    required this.balance,
    required this.currency,
    required this.gradient,
  });
}

// (Supprimé) _ActionChip devenu obsolète après refonte des QuickActions

class _QuickActions extends StatelessWidget {
  final void Function(String action) onAction;
  const _QuickActions({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 360;
        final children = [
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
        ];
        if (isTight) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: children
                .map(
                  (c) =>
                      SizedBox(width: (constraints.maxWidth - 8) / 2, child: c),
                )
                .toList(),
          );
        }
        return Row(children: children.map((c) => Expanded(child: c)).toList());
      },
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

class _BankCard extends StatelessWidget {
  final String type;
  final String masked;
  final List<Color> gradient;
  const _BankCard({
    required this.type,
    required this.masked,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.waves_outlined, color: Colors.white),
            ],
          ),
          const Spacer(),
          Text(
            masked,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
