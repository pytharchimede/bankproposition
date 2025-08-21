import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: const [
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
          Divider(height: 1),
          ListTile(
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
