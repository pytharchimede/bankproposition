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
import 'screens/savings_screen.dart';
import 'screens/credit_simulator_ultra.dart';
import 'screens/insurance_screen.dart';
import 'screens/chequebook_request_screen.dart';
import 'screens/agency_map_screen.dart';
import 'screens/contact_advisor_screen.dart';

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
      debugShowCheckedModeBanner: false,
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
        '/savings': (context) => const SavingsScreen(),
        '/credit': (context) => const CreditSimulatorUltra(),
        '/insurance': (context) => const InsuranceScreen(),
        '/chequebook': (context) => const ChequebookRequestScreen(),
        '/agencies': (context) => const AgencyMapScreen(),
        '/contact-advisor': (context) => const ContactAdvisorScreen(),
      },
    );
  }
}
