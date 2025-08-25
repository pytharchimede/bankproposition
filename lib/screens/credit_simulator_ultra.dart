import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'dart:math' as math;

class CreditSimulatorUltra extends StatefulWidget {
  const CreditSimulatorUltra({super.key});

  @override
  State<CreditSimulatorUltra> createState() => _CreditSimulatorUltraState();
}

class _CreditSimulatorUltraState extends State<CreditSimulatorUltra>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _rotationAnimation;

  // Form controllers
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();
  final _savingsController = TextEditingController();
  final _existingLoansController = TextEditingController();

  // ULTRA Simulation data avec plus de paramètres
  double _loanAmount = 1000000;
  int _durationMonths = 24;
  String _loanType = 'Personnel';
  double _interestRate = 12.0;
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  double _existingSavings = 0;
  double _existingLoans = 0;

  // ULTRA Features - Analyse avancée
  String _employmentType = 'CDI';
  int _workExperience = 1;
  String _sector = 'Privé';
  double _creditScore = 750;
  bool _hasCollateral = false;
  double _collateralValue = 0;

  // Results
  double _monthlyPayment = 0;
  double _totalAmount = 0;
  double _totalInterest = 0;
  double _debtRatio = 0;
  bool _isEligible = false;

  // New features
  final List<_MonthlyPaymentData> _paymentSchedule = [];
  double _maxAffordableAmount = 0;
  double _riskScore = 0;

  final Map<String, _LoanTypeData> _loanTypes = {
    'Personnel': _LoanTypeData(
      rate: 12.0,
      color: Color(0xFF3B82F6),
      maxAmount: 5000000,
    ),
    'Auto': _LoanTypeData(
      rate: 8.5,
      color: Color(0xFF10B981),
      maxAmount: 15000000,
    ),
    'Immobilier': _LoanTypeData(
      rate: 6.5,
      color: Color(0xFF8B5CF6),
      maxAmount: 50000000,
    ),
    'Professionnel': _LoanTypeData(
      rate: 10.0,
      color: Color(0xFFF59E0B),
      maxAmount: 20000000,
    ),
    'Étudiant': _LoanTypeData(
      rate: 4.5,
      color: Color(0xFFEF4444),
      maxAmount: 2000000,
    ),
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutExpo),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _rotationController.repeat();
    _calculateLoan();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _rotationController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    _savingsController.dispose();
    _existingLoansController.dispose();
    super.dispose();
  }

  void _calculateLoan() {
    setState(() {
      _interestRate = _loanTypes[_loanType]!.rate;
      final double monthlyRate = (_interestRate / 100) / 12;
      final int n = _durationMonths;

      if (monthlyRate == 0) {
        _monthlyPayment = _loanAmount / n;
      } else {
        _monthlyPayment =
            _loanAmount *
            (monthlyRate * math.pow(1 + monthlyRate, n)) /
            (math.pow(1 + monthlyRate, n) - 1);
      }

      _totalAmount = _monthlyPayment * n;
      _totalInterest = _totalAmount - _loanAmount;

      // Calculate affordability and risk
      final income =
          double.tryParse(_incomeController.text.replaceAll(' ', '')) ?? 0;
      final expenses =
          double.tryParse(_expensesController.text.replaceAll(' ', '')) ?? 0;
      final netIncome = income - expenses;

      if (netIncome > 0) {
        _debtRatio = (_monthlyPayment / netIncome) * 100;
        _maxAffordableAmount = (netIncome * 0.33) * n; // 33% rule
        _riskScore = math.min(100, _debtRatio * 2);
        _isEligible = _debtRatio <= 33 && income >= 150000;
      }

      // Generate payment schedule
      _generatePaymentSchedule();
    });

    _progressController.reset();
    _progressController.forward();
  }

  void _generatePaymentSchedule() {
    _paymentSchedule.clear();
    double remainingBalance = _loanAmount;
    final double monthlyRate = (_interestRate / 100) / 12;

    for (int month = 1; month <= _durationMonths; month++) {
      final double interestPayment = remainingBalance * monthlyRate;
      final double principalPayment = _monthlyPayment - interestPayment;
      remainingBalance -= principalPayment;

      _paymentSchedule.add(
        _MonthlyPaymentData(
          month: month,
          payment: _monthlyPayment,
          principal: principalPayment,
          interest: interestPayment,
          balance: math.max(0, remainingBalance),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: BduColors.primary,
        title: Row(
          children: [
            RotationTransition(
              turns: _rotationAnimation,
              child: Icon(
                Icons.auto_awesome,
                color: BduColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Simulateur ULTRA AI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
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
              icon: Icon(Icons.help_outline, color: BduColors.primary),
              onPressed: () => _showHelpDialog(),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ULTRA AI Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade600,
                        Colors.blue.shade600,
                        BduColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          RotationTransition(
                            turns: _rotationAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IA ULTRA AVANCÉE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Analyse prédictive & scoring personnalisé',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),

                // Header avec visualisation du crédit
                _UltraCreditHeader(
                  loanAmount: _loanAmount,
                  monthlyPayment: _monthlyPayment,
                  isEligible: _isEligible,
                  riskScore: _riskScore,
                  animation: _progressAnimation,
                ),
                const SizedBox(height: 24),

                // Sélection du type de crédit
                _UltraLoanTypeSelector(
                  selectedType: _loanType,
                  loanTypes: _loanTypes,
                  onTypeChanged: (type) {
                    setState(() => _loanType = type);
                    _calculateLoan();
                  },
                ),
                const SizedBox(height: 24),

                // Configuration du prêt
                _UltraLoanConfiguration(
                  loanAmount: _loanAmount,
                  durationMonths: _durationMonths,
                  maxAmount: _loanTypes[_loanType]!.maxAmount,
                  onAmountChanged: (amount) {
                    setState(() => _loanAmount = amount);
                    _calculateLoan();
                  },
                  onDurationChanged: (duration) {
                    setState(() => _durationMonths = duration);
                    _calculateLoan();
                  },
                ),
                const SizedBox(height: 24),

                // Analyse financière
                _UltraFinancialAnalysis(
                  incomeController: _incomeController,
                  expensesController: _expensesController,
                  debtRatio: _debtRatio,
                  maxAffordableAmount: _maxAffordableAmount,
                  onChanged: _calculateLoan,
                ),
                const SizedBox(height: 24),

                // Résultats détaillés
                _UltraResults(
                  monthlyPayment: _monthlyPayment,
                  totalAmount: _totalAmount,
                  totalInterest: _totalInterest,
                  isEligible: _isEligible,
                  animation: _progressAnimation,
                ),
                const SizedBox(height: 24),

                // Échéancier de remboursement
                _UltraPaymentSchedule(
                  paymentSchedule: _paymentSchedule,
                  loanType: _loanType,
                  color: _loanTypes[_loanType]!.color,
                ),
                const SizedBox(height: 32),

                // Actions
                _UltraActionButtons(
                  isEligible: _isEligible,
                  onSimulateAgain: () {
                    setState(() {
                      _loanAmount = 1000000;
                      _durationMonths = 24;
                      _loanType = 'Personnel';
                      _incomeController.clear();
                      _expensesController.clear();
                    });
                    _calculateLoan();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: BduColors.primary),
            const SizedBox(width: 8),
            const Text('Aide au simulateur'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.calculate,
              title: 'Simulation',
              description:
                  'Ajustez le montant et la durée pour voir l\'impact sur vos mensualités.',
            ),
            _HelpItem(
              icon: Icons.analytics,
              title: 'Analyse financière',
              description:
                  'Renseignez vos revenus pour une analyse personnalisée.',
            ),
            _HelpItem(
              icon: Icons.trending_up,
              title: 'Score de risque',
              description:
                  'Indique la probabilité d\'acceptation de votre demande.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

class _LoanTypeData {
  final double rate;
  final Color color;
  final double maxAmount;

  _LoanTypeData({
    required this.rate,
    required this.color,
    required this.maxAmount,
  });
}

class _MonthlyPaymentData {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;

  _MonthlyPaymentData({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

class _UltraCreditHeader extends StatelessWidget {
  final double loanAmount;
  final double monthlyPayment;
  final bool isEligible;
  final double riskScore;
  final Animation<double> animation;

  const _UltraCreditHeader({
    required this.loanAmount,
    required this.monthlyPayment,
    required this.isEligible,
    required this.riskScore,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BduColors.primary, BduColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BduColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulation de Crédit',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Text(
                          '${(loanAmount * animation.value).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isEligible
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEligible
                        ? Colors.green.withValues(alpha: 0.5)
                        : Colors.orange.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  isEligible ? 'Éligible' : 'À étudier',
                  style: TextStyle(
                    color: isEligible ? Colors.green[100] : Colors.orange[100],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  label: 'Mensualité',
                  value:
                      '${monthlyPayment.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                  icon: Icons.payments_outlined,
                  animation: animation,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HeaderStat(
                  label: 'Score risque',
                  value: '${riskScore.toStringAsFixed(0)}%',
                  icon: Icons.trending_up,
                  animation: animation,
                  color: riskScore < 25
                      ? Colors.green
                      : riskScore < 50
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Animation<double> animation;
  final Color? color;

  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.animation,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Text(
                value,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Continuera avec les autres composants ultra-professionnels...
// [Le fichier est trop long, je vais créer les autres composants dans la suite]

class _UltraLoanTypeSelector extends StatelessWidget {
  final String selectedType;
  final Map<String, _LoanTypeData> loanTypes;
  final Function(String) onTypeChanged;

  const _UltraLoanTypeSelector({
    required this.selectedType,
    required this.loanTypes,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category_outlined, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Type de crédit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: loanTypes.entries.map((entry) {
              final isSelected = entry.key == selectedType;
              return GestureDetector(
                onTap: () => onTypeChanged(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? entry.value.color : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : entry.value.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.value.rate}%',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UltraLoanConfiguration extends StatelessWidget {
  final double loanAmount;
  final int durationMonths;
  final double maxAmount;
  final Function(double) onAmountChanged;
  final Function(int) onDurationChanged;

  const _UltraLoanConfiguration({
    required this.loanAmount,
    required this.durationMonths,
    required this.maxAmount,
    required this.onAmountChanged,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Configuration du prêt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Montant
          Text(
            'Montant souhaité',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${loanAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: BduColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: BduColors.primary,
              thumbColor: BduColors.primary,
              overlayColor: BduColors.primary.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: loanAmount,
              min: 100000,
              max: maxAmount,
              divisions: 50,
              onChanged: onAmountChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100 000 XOF',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                '${(maxAmount / 1000000).toStringAsFixed(0)}M XOF',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Durée
          Text(
            'Durée de remboursement',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$durationMonths mois (${(durationMonths / 12).toStringAsFixed(1)} ans)',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: BduColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: BduColors.secondary,
              thumbColor: BduColors.secondary,
              overlayColor: BduColors.secondary.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: durationMonths.toDouble(),
              min: 6,
              max: 84,
              divisions: 26,
              onChanged: (value) => onDurationChanged(value.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '6 mois',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                '7 ans',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UltraFinancialAnalysis extends StatelessWidget {
  final TextEditingController incomeController;
  final TextEditingController expensesController;
  final double debtRatio;
  final double maxAffordableAmount;
  final VoidCallback onChanged;

  const _UltraFinancialAnalysis({
    required this.incomeController,
    required this.expensesController,
    required this.debtRatio,
    required this.maxAffordableAmount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Analyse financière',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _UltraTextField(
                  controller: incomeController,
                  label: 'Revenus mensuels',
                  suffix: 'XOF',
                  icon: Icons.trending_up,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _UltraTextField(
                  controller: expensesController,
                  label: 'Charges mensuelles',
                  suffix: 'XOF',
                  icon: Icons.trending_down,
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),

          if (debtRatio > 0) ...[
            const SizedBox(height: 20),
            _RatioIndicator(
              ratio: debtRatio,
              maxAffordableAmount: maxAffordableAmount,
            ),
          ],
        ],
      ),
    );
  }
}

class _UltraTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final Function(String) onChanged;

  const _UltraTextField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CurrencyInputFormatter(),
          ],
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: BduColors.primary),
            suffixText: suffix,
            suffixStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: BduColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }
}

class _RatioIndicator extends StatelessWidget {
  final double ratio;
  final double maxAffordableAmount;

  const _RatioIndicator({
    required this.ratio,
    required this.maxAffordableAmount,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (ratio <= 25) return Colors.green;
      if (ratio <= 33) return Colors.orange;
      return Colors.red;
    }

    String getLabel() {
      if (ratio <= 25) return 'Excellent';
      if (ratio <= 33) return 'Acceptable';
      return 'Risqué';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getColor().withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taux d\'endettement',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getLabel(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: math.min(ratio / 50, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(getColor()),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ratio.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: getColor(),
                  fontSize: 16,
                ),
              ),
              Text(
                'Recommandé: < 33%',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UltraResults extends StatelessWidget {
  final double monthlyPayment;
  final double totalAmount;
  final double totalInterest;
  final bool isEligible;
  final Animation<double> animation;

  const _UltraResults({
    required this.monthlyPayment,
    required this.totalAmount,
    required this.totalInterest,
    required this.isEligible,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Résultats de simulation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _ResultCard(
                  title: 'Mensualité',
                  value: monthlyPayment,
                  icon: Icons.payments_outlined,
                  color: BduColors.primary,
                  animation: animation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultCard(
                  title: 'Total à rembourser',
                  value: totalAmount,
                  icon: Icons.account_balance_outlined,
                  color: BduColors.secondary,
                  animation: animation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ResultCard(
            title: 'Intérêts totaux',
            value: totalInterest,
            icon: Icons.trending_up_outlined,
            color: Colors.orange,
            animation: animation,
            isWide: true,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final Animation<double> animation;
  final bool isWide;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.animation,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: isWide
          ? Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(child: _buildContent()),
              ],
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isWide) Icon(icon, color: color, size: 20),
        if (!isWide) const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Text(
              '${(value * animation.value).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
              style: TextStyle(
                color: color,
                fontSize: isWide ? 18 : 16,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UltraPaymentSchedule extends StatelessWidget {
  final List<_MonthlyPaymentData> paymentSchedule;
  final String loanType;
  final Color color;

  const _UltraPaymentSchedule({
    required this.paymentSchedule,
    required this.loanType,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_outlined, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Échéancier de remboursement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (paymentSchedule.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: math.min(paymentSchedule.length, 12),
                itemBuilder: (context, index) {
                  final payment = paymentSchedule[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mois ${payment.month}',
                          style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ScheduleItem(
                          label: 'Capital',
                          value: payment.principal,
                          color: Colors.green,
                        ),
                        _ScheduleItem(
                          label: 'Intérêts',
                          value: payment.interest,
                          color: Colors.orange,
                        ),
                        _ScheduleItem(
                          label: 'Restant',
                          value: payment.balance,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ScheduleItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${(value / 1000).toStringAsFixed(0)}k',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UltraActionButtons extends StatelessWidget {
  final bool isEligible;
  final VoidCallback onSimulateAgain;

  const _UltraActionButtons({
    required this.isEligible,
    required this.onSimulateAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSimulateAgain,
            icon: const Icon(Icons.refresh),
            label: const Text('Nouvelle simulation'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: BduColors.primary),
              foregroundColor: BduColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isEligible
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Demande de crédit initiée !'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.send),
            label: const Text('Faire une demande'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isEligible ? BduColors.primary : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BduColors.primary, size: 20),
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
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final int value = int.tryParse(newValue.text.replaceAll(' ', '')) ?? 0;
    final String formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
