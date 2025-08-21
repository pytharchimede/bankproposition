import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentAccount = 0;
  bool _hideBalance = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  final _accounts = const [
    _Account(
      id: 'CC001',
      name: 'Compte courant',
      type: 'Compte de dépôt',
      iban: 'CI00 1234 5678 9012 3456',
      balance: 1_250_000.50,
      availableBalance: 1_200_000.50,
      currency: 'XOF',
      openedDate: '15 Jan 2023',
      lastTransaction: 'Aujourd\'hui 14:30',
      status: 'Actif',
      gradient: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      cardNumber: '**** **** **** 1234',
    ),
    _Account(
      id: 'EP001',
      name: 'Épargne',
      type: 'Livret d\'épargne',
      iban: 'CI00 9876 5432 1098 7654',
      balance: 3_500_000.00,
      availableBalance: 3_500_000.00,
      currency: 'XOF',
      openedDate: '03 Mar 2022',
      lastTransaction: 'Hier 16:45',
      status: 'Actif',
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
      cardNumber: '**** **** **** 9876',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: BduColors.primary,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: BduColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              tooltip: _hideBalance ? 'Afficher le solde' : 'Masquer le solde',
              icon: Icon(
                _hideBalance
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: BduColors.primary,
              ),
              onPressed: () => setState(() => _hideBalance = !_hideBalance),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Carrousel de comptes avec design professionnel
              SizedBox(
                height: 280,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.88),
                  onPageChanged: (i) => setState(() => _currentAccount = i),
                  itemCount: _accounts.length,
                  itemBuilder: (context, i) => _ProfessionalAccountCard(
                    account: _accounts[i],
                    hideBalance: _hideBalance,
                    isActive: i == _currentAccount,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Indicateurs de page améliorés
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _accounts.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == _currentAccount ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: i == _currentAccount
                          ? const LinearGradient(
                              colors: [BduColors.primary, BduColors.secondary],
                            )
                          : null,
                      color: i == _currentAccount ? null : Colors.black12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _EnhancedQuickActions(),
              const SizedBox(height: 32),
              _GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: BduColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dépenses 30 jours',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                              barWidth: 4,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: BduColors.primary,
                                        ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    BduColors.primary.withValues(alpha: 0.3),
                                    BduColors.primary.withValues(alpha: 0.05),
                                  ],
                                ),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card_outlined,
                          color: BduColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mes cartes',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          _EnhancedBankCard(
                            type: 'VISA',
                            masked: '**** **** **** 1234',
                            gradient: [Color(0xFF25579A), Color(0xFF2E6AAE)],
                          ),
                          SizedBox(width: 12),
                          _EnhancedBankCard(
                            type: 'GIM-UEMOA',
                            masked: '**** **** **** 9876',
                            gradient: [Color(0xFF469C23), Color(0xFF57B42B)],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          color: BduColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dernières infos',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _EnhancedNewsCard(
                      title: 'Nouveaux services BDU Mobile',
                      subtitle:
                          'Découvrez nos fonctionnalités de virement améliorées.',
                      icon: Icons.new_releases_outlined,
                    ),
                    const SizedBox(height: 12),
                    const _EnhancedNewsCard(
                      title: 'Sécurité',
                      subtitle:
                          'Activez la double authentification dans votre profil.',
                      icon: Icons.security_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Glassmorphic Account Card avec effets 3D
class _GlassmorphicAccountCard extends StatefulWidget {
  final _Account account;
  final bool hideBalance;
  final bool isActive;

  const _GlassmorphicAccountCard({
    required this.account,
    required this.hideBalance,
    required this.isActive,
  });

  @override
  State<_GlassmorphicAccountCard> createState() =>
      _GlassmorphicAccountCardState();
}

class _GlassmorphicAccountCardState extends State<_GlassmorphicAccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedScale(
        scale: widget.isActive ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 300),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: widget.account.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.account.gradient[0].withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.account.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.account.iban,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          widget.hideBalance
                              ? '•••••••• XOF'
                              : '${widget.account.balance.toStringAsFixed(2)} ${widget.account.currency}',
                          key: ValueKey<bool>(widget.hideBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glass Container pour sections
class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Enhanced Quick Actions avec animations
class _EnhancedQuickActions extends StatelessWidget {
  const _EnhancedQuickActions();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 360;
        final children = [
          _EnhancedQuickButton(
            icon: Icons.swap_horiz,
            label: 'Virement',
            colors: const [Color(0xFF25579A), Color(0xFF2E6AAE)],
            onTap: () => Navigator.pushNamed(context, '/transfer-wizard'),
          ),
          _EnhancedQuickButton(
            icon: Icons.savings_outlined,
            label: 'Épargne',
            colors: const [Color(0xFF469C23), Color(0xFF57B42B)],
            onTap: () => Navigator.pushNamed(context, '/savings'),
          ),
          _EnhancedQuickButton(
            icon: Icons.credit_score_outlined,
            label: 'Crédit',
            colors: const [Color(0xFF25579A), Color(0xFF1B3E6F)],
            onTap: () => Navigator.pushNamed(context, '/credit'),
          ),
          _EnhancedQuickButton(
            icon: Icons.receipt_long_outlined,
            label: 'Chéquier',
            colors: const [Color(0xFF1B3E6F), Color(0xFF25579A)],
            onTap: () => Navigator.pushNamed(context, '/chequebook'),
          ),
          _EnhancedQuickButton(
            icon: Icons.shield_outlined,
            label: 'Assurance',
            colors: const [Color(0xFF469C23), Color(0xFF2E6A17)],
            onTap: () => Navigator.pushNamed(context, '/insurance'),
          ),
        ];

        if (isTight) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: children
                .map(
                  (c) => SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
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

class _EnhancedQuickButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _EnhancedQuickButton({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_EnhancedQuickButton> createState() => _EnhancedQuickButtonState();
}

class _EnhancedQuickButtonState extends State<_EnhancedQuickButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _shadowAnimation = Tween<double>(
      begin: 8.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors[0].withValues(alpha: 0.3),
                    blurRadius: _shadowAnimation.value,
                    offset: Offset(0, _shadowAnimation.value / 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _EnhancedBankCard extends StatelessWidget {
  final String type;
  final String masked;
  final List<Color> gradient;

  const _EnhancedBankCard({
    required this.type,
    required this.masked,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
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
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.contactless_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  masked,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnhancedNewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EnhancedNewsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BduColors.primary, BduColors.secondary],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}

class _Account {
  final String id;
  final String name;
  final String type;
  final String iban;
  final double balance;
  final double availableBalance;
  final String currency;
  final String openedDate;
  final String lastTransaction;
  final String status;
  final List<Color> gradient;
  final String cardNumber;

  const _Account({
    required this.id,
    required this.name,
    required this.type,
    required this.iban,
    required this.balance,
    required this.availableBalance,
    required this.currency,
    required this.openedDate,
    required this.lastTransaction,
    required this.status,
    required this.gradient,
    required this.cardNumber,
  });
}

// Carte de compte professionnelle et moderne
class _ProfessionalAccountCard extends StatefulWidget {
  final _Account account;
  final bool hideBalance;
  final bool isActive;

  const _ProfessionalAccountCard({
    required this.account,
    required this.hideBalance,
    required this.isActive,
  });

  @override
  State<_ProfessionalAccountCard> createState() =>
      _ProfessionalAccountCardState();
}

class _ProfessionalAccountCardState extends State<_ProfessionalAccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedScale(
        scale: widget.isActive ? 1.0 : 0.94,
        duration: const Duration(milliseconds: 300),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header avec gradient
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.account.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.account.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.account.type,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.account.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          widget.hideBalance
                              ? '•••••••• XOF'
                              : '${widget.account.balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                          key: ValueKey<bool>(widget.hideBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Détails du compte
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _AccountDetailRow(
                          icon: Icons.account_balance_outlined,
                          label: 'IBAN',
                          value: widget.account.iban,
                        ),
                        _AccountDetailRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Solde disponible',
                          value: widget.hideBalance
                              ? '•••••••• XOF'
                              : '${widget.account.availableBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                        ),
                        _AccountDetailRow(
                          icon: Icons.schedule_outlined,
                          label: 'Dernière opération',
                          value: widget.account.lastTransaction,
                        ),
                        _AccountDetailRow(
                          icon: Icons.date_range_outlined,
                          label: 'Ouvert le',
                          value: widget.account.openedDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: BduColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: BduColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
