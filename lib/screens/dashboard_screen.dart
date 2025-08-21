import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:fl_chart/fl_chart.dart';

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
          Text(
            'Dépenses 30 jours',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: BduColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: BduColors.primary.withValues(alpha: 0.08),
                    ),
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 2.2),
                      FlSpot(2, 1.8),
                      FlSpot(3, 2.6),
                      FlSpot(4, 2.1),
                      FlSpot(5, 2.9),
                      FlSpot(6, 2.4),
                    ],
                  ),
                ],
              ),
            ),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                hideBalance
                    ? '•••••••• XOF'
                    : '${account.balance.toStringAsFixed(2)} ${account.currency}',
                key: ValueKey<bool>(hideBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
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
            colors: const [Color(0xFF25579A), Color(0xFF2E6AAE)],
            onTap: () => Navigator.pushNamed(context, '/transfer-wizard'),
          ),
          _QuickButton(
            icon: Icons.savings_outlined,
            label: 'Épargne',
            colors: const [Color(0xFF469C23), Color(0xFF57B42B)],
            onTap: () => Navigator.pushNamed(context, '/savings'),
          ),
          _QuickButton(
            icon: Icons.credit_score_outlined,
            label: 'Crédit',
            colors: const [Color(0xFF25579A), Color(0xFF1B3E6F)],
            onTap: () => Navigator.pushNamed(context, '/credit'),
          ),
          _QuickButton(
            icon: Icons.receipt_long_outlined,
            label: 'Chéquier',
            colors: const [Color(0xFF1B3E6F), Color(0xFF25579A)],
            onTap: () => Navigator.pushNamed(context, '/chequebook'),
          ),
          _QuickButton(
            icon: Icons.shield_outlined,
            label: 'Assurance',
            colors: const [Color(0xFF469C23), Color(0xFF2E6A17)],
            onTap: () => Navigator.pushNamed(context, '/insurance'),
          ),
        ];
        if (isTight) {
          const gap = 12.0;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: children
                .map(
                  (c) => SizedBox(
                    width: (constraints.maxWidth - gap) / 2,
                    child: c,
                  ),
                )
                .toList(),
          );
        }
        final rowChildren = <Widget>[];
        for (var i = 0; i < children.length; i++) {
          rowChildren.add(Expanded(child: children[i]));
          if (i != children.length - 1) {
            rowChildren.add(const SizedBox(width: 12));
          }
        }
        return Row(children: rowChildren);
      },
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 4),
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 4),
          ],
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
