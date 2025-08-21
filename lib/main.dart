import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';
import 'screens/beneficiaries_page.dart';
import 'screens/transfer_wizard.dart';
import 'screens/claims_page.dart';
import 'screens/cards_page.dart';
import 'screens/backoffice_kyc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDU Mobile',
      theme: BduTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const AppShell(),
        '/app': (context) => const AppShell(),
        '/beneficiaries': (context) => const BeneficiariesPage(),
        '/transfer-wizard': (context) => const TransferWizard(),
        '/claims': (context) => const ClaimsPage(),
        '/cards': (context) => const CardsPage(),
        '/backoffice/kyc': (context) => const BackofficeKYC(),
      },
    );
  }
}
