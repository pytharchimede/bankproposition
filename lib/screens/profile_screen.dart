import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: BduColors.primary,
        title: const Text(
          'Mon Profil',
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
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // Paramètres
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Carte de profil utilisateur
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: BduColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar et informations
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jean KOUAME',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Client Premium • N° 123456789',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Compte vérifié',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats rapides
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.account_balance_outlined,
                          value: '2',
                          label: 'Comptes',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.credit_card_outlined,
                          value: '2',
                          label: 'Cartes',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.schedule_outlined,
                          value: '3 ans',
                          label: 'Client depuis',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Services bancaires
            _ProfessionalSection(
              title: 'Services Bancaires',
              icon: Icons.account_balance_outlined,
              children: [
                _ProfessionalTile(
                  icon: Icons.web_outlined,
                  title: 'Web Banking',
                  subtitle: 'Accès via navigateur web',
                  isEnabled: true,
                  onTap: () {},
                ),
                _ProfessionalTile(
                  icon: Icons.phone_android_outlined,
                  title: 'Mobile Banking',
                  subtitle: 'Application mobile sécurisée',
                  isEnabled: true,
                  onTap: () {},
                ),
                _ProfessionalTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS Banking',
                  subtitle: 'Notifications et alertes',
                  isEnabled: false,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Gestion des comptes
            _ProfessionalSection(
              title: 'Gestion des Comptes',
              icon: Icons.manage_accounts_outlined,
              children: [
                _ProfessionalNavigationTile(
                  icon: Icons.people_alt_outlined,
                  title: 'Bénéficiaires',
                  subtitle: 'Gérer vos bénéficiaires de virement',
                  onTap: () => Navigator.pushNamed(context, '/beneficiaries'),
                ),
                _ProfessionalNavigationTile(
                  icon: Icons.swap_horizontal_circle_outlined,
                  title: 'Assistant Virement',
                  subtitle: 'Étapes guidées pour vos virements',
                  onTap: () => Navigator.pushNamed(context, '/transfer-wizard'),
                ),
                _ProfessionalNavigationTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Demande de Chéquier',
                  subtitle: 'Commander un nouveau chéquier',
                  onTap: () => Navigator.pushNamed(context, '/chequebook'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Support et réclamations
            _ProfessionalSection(
              title: 'Support Client',
              icon: Icons.support_agent_outlined,
              children: [
                _ProfessionalNavigationTile(
                  icon: Icons.help_outline,
                  title: 'Réclamations',
                  subtitle: 'Ouvrir et suivre vos tickets',
                  onTap: () => Navigator.pushNamed(context, '/claims'),
                ),
                _ProfessionalNavigationTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Gestion des Cartes',
                  subtitle: 'Activer, bloquer, renouveler',
                  onTap: () => Navigator.pushNamed(context, '/cards'),
                ),
                _ProfessionalNavigationTile(
                  icon: Icons.phone_outlined,
                  title: 'Contacter un Conseiller',
                  subtitle: '+225 XX XX XX XX',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Administration (si applicable)
            _ProfessionalSection(
              title: 'Administration',
              icon: Icons.admin_panel_settings_outlined,
              children: [
                _ProfessionalNavigationTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Back-Office KYC (Démo)',
                  subtitle: 'Interface de validation KYC',
                  onTap: () => Navigator.pushNamed(context, '/backoffice/kyc'),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton déconnexion
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_outlined, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Se déconnecter',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfessionalSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BduColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: BduColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          ...children.map(
            (child) => Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[100]!, width: 1),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ProfessionalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BduColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: BduColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) => onTap(),
        activeTrackColor: BduColors.secondary,
        activeThumbColor: Colors.white,
      ),
    );
  }
}

class _ProfessionalNavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfessionalNavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: BduColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: BduColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
      ),
      onTap: onTap,
    );
  }
}
