import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          _ProfileTile(
            icon: Icons.web,
            title: 'Web Banking',
            subtitle: 'Accès via navigateur',
          ),
          _ProfileTile(
            icon: Icons.phone_android,
            title: 'Mobile Banking',
            subtitle: 'Accès via app mobile',
          ),
          _ProfileTile(
            icon: Icons.sms_outlined,
            title: 'SMS Banking',
            subtitle: 'Alertes et notifications',
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.people_alt_outlined,
              color: BduColors.primary,
            ),
            title: const Text('Bénéficiaires'),
            subtitle: const Text('Gérer vos bénéficiaires'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/beneficiaries'),
          ),
          ListTile(
            leading: const Icon(
              Icons.swap_horizontal_circle_outlined,
              color: BduColors.primary,
            ),
            title: const Text('Virement (Assistant)'),
            subtitle: const Text(
              'Étapes: Détails -> Bénéficiaire -> Récapitulatif -> OTP -> Reçu',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/transfer-wizard'),
          ),
          ListTile(
            leading: const Icon(
              Icons.receipt_long_outlined,
              color: BduColors.primary,
            ),
            title: const Text('Réclamations'),
            subtitle: const Text('Ouvrir et suivre vos tickets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/claims'),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card, color: BduColors.primary),
            title: const Text('Cartes'),
            subtitle: const Text('Gestion des cartes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/cards'),
          ),
          ListTile(
            leading: const Icon(
              Icons.receipt_long_outlined,
              color: BduColors.primary,
            ),
            title: const Text('Chéquier'),
            subtitle: const Text('Demande de chéquier'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/chequebook'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.verified_user_outlined,
              color: BduColors.primary,
            ),
            title: const Text('Back-Office KYC (démo)'),
            subtitle: const Text('Examen KYC, actions et audit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/backoffice/kyc'),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.support_agent, color: BduColors.primary),
            title: Text('Contacter mon conseiller'),
            subtitle: Text('+225 XX XX XX XX'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: BduColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.toggle_on, color: BduColors.secondary),
    );
  }
}
