import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import 'dart:math' as math;

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();

  // Simulation data
  double _loanAmount = 1000000;
  int _durationMonths = 24;
  String _loanType = 'Personnel';
  double _interestRate = 12.0;

  // Results
  double _monthlyPayment = 0;
  double _totalAmount = 0;
  double _totalInterest = 0;
  double _debtRatio = 0;
  bool _isEligible = false;

  final Map<String, double> _loanTypes = {
    'Personnel': 12.0,
    'Auto': 8.5,
    'Immobilier': 6.5,
    'Professionnel': 10.0,
    'Étudiant': 4.5,
  };

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
    _calculateLoan();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _calculateLoan() {
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

    // Calculate debt ratio
    final income =
        double.tryParse(_incomeController.text.replaceAll(' ', '')) ?? 0;
    final expenses =
        double.tryParse(_expensesController.text.replaceAll(' ', '')) ?? 0;

    if (income > 0) {
      _debtRatio = ((_monthlyPayment + expenses) / income) * 100;
      _isEligible = _debtRatio <= 33; // Standard debt ratio threshold
    }

    setState(() {});
  }

  void _submitLoanApplication() {
    showDialog(
      context: context,
      builder: (context) => _LoanApplicationDialog(
        loanAmount: _loanAmount,
        monthlyPayment: _monthlyPayment,
        loanType: _loanType,
        duration: _durationMonths,
        isEligible: _isEligible,
      ),
    );
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
          'Simulateur de crédit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
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
              tooltip: 'Informations',
              icon: Icon(Icons.info_outline, color: BduColors.primary),
              onPressed: () => _showLoanInfo(),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeCard(),
                const SizedBox(height: 24),
                _LoanTypeSelector(
                  selectedType: _loanType,
                  loanTypes: _loanTypes,
                  onTypeChanged: (type) {
                    setState(() {
                      _loanType = type;
                      _interestRate = _loanTypes[type]!;
                    });
                    _calculateLoan();
                  },
                ),
                const SizedBox(height: 24),
                _LoanAmountSlider(
                  amount: _loanAmount,
                  onChanged: (value) {
                    setState(() => _loanAmount = value);
                    _calculateLoan();
                  },
                ),
                const SizedBox(height: 24),
                _DurationSelector(
                  duration: _durationMonths,
                  onChanged: (value) {
                    setState(() => _durationMonths = value);
                    _calculateLoan();
                  },
                ),
                const SizedBox(height: 24),
                _IncomeExpensesCard(
                  incomeController: _incomeController,
                  expensesController: _expensesController,
                  onChanged: _calculateLoan,
                ),
                const SizedBox(height: 32),
                _LoanResultsCard(
                  monthlyPayment: _monthlyPayment,
                  totalAmount: _totalAmount,
                  totalInterest: _totalInterest,
                  debtRatio: _debtRatio,
                  isEligible: _isEligible,
                  interestRate: _interestRate,
                ),
                const SizedBox(height: 24),
                _ActionButtons(
                  isEligible: _isEligible,
                  onSimulateMore: () {
                    // Reset form for new simulation
                    setState(() {
                      _loanAmount = 1000000;
                      _durationMonths = 24;
                      _loanType = 'Personnel';
                      _interestRate = 12.0;
                      _incomeController.clear();
                      _expensesController.clear();
                    });
                    _calculateLoan();
                  },
                  onApply: _submitLoanApplication,
                ),
                const SizedBox(height: 24),
                _LoanTipsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoanInfo() {
    showDialog(context: context, builder: (context) => _LoanInfoDialog());
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BduColors.primary, BduColors.secondary],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Simulateur intelligent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Découvrez votre capacité d\'emprunt et simulez votre crédit en quelques minutes. Notre outil intelligent calcule votre mensualité et vérifie votre éligibilité.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanTypeSelector extends StatelessWidget {
  final String selectedType;
  final Map<String, double> loanTypes;
  final Function(String) onTypeChanged;

  const _LoanTypeSelector({
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
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
              const SizedBox(width: 12),
              const Text(
                'Type de crédit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [BduColors.primary, BduColors.secondary],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.value.toStringAsFixed(1)}%',
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

class _LoanAmountSlider extends StatelessWidget {
  final double amount;
  final Function(double) onChanged;

  const _LoanAmountSlider({required this.amount, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money_outlined, color: BduColors.primary),
              const SizedBox(width: 12),
              const Text(
                'Montant du crédit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BduColors.primary.withValues(alpha: 0.1),
                    BduColors.secondary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BduColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: BduColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: BduColors.primary,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: BduColors.primary,
              overlayColor: BduColors.primary.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: amount,
              min: 100000,
              max: 50000000,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100K XOF',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '50M XOF',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int duration;
  final Function(int) onChanged;

  const _DurationSelector({required this.duration, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final durations = [6, 12, 18, 24, 36, 48, 60, 72, 84, 96];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
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
              const SizedBox(width: 12),
              const Text(
                'Durée de remboursement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$duration mois (${(duration / 12).toStringAsFixed(duration % 12 == 0 ? 0 : 1)} ${duration == 12 ? 'an' : 'ans'})',
            style: TextStyle(
              color: BduColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: durations.length,
            itemBuilder: (context, index) {
              final months = durations[index];
              final isSelected = months == duration;

              return GestureDetector(
                onTap: () => onChanged(months),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [BduColors.primary, BduColors.secondary],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${months}m',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IncomeExpensesCard extends StatelessWidget {
  final TextEditingController incomeController;
  final TextEditingController expensesController;
  final VoidCallback onChanged;

  const _IncomeExpensesCard({
    required this.incomeController,
    required this.expensesController,
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: BduColors.primary,
              ),
              const SizedBox(width: 12),
              const Text(
                'Situation financière',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ces informations nous aident à évaluer votre capacité d\'emprunt',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          _FinanceField(
            controller: incomeController,
            label: 'Revenus mensuels nets',
            icon: Icons.trending_up_outlined,
            hint: 'Votre salaire net mensuel',
            onChanged: onChanged,
          ),
          const SizedBox(height: 16),
          _FinanceField(
            controller: expensesController,
            label: 'Charges mensuelles',
            icon: Icons.trending_down_outlined,
            hint: 'Loyer, autres crédits, charges...',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FinanceField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final VoidCallback onChanged;

  const _FinanceField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_FinanceField> createState() => _FinanceFieldState();
}

class _FinanceFieldState extends State<_FinanceField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isFocused
            ? BduColors.primary.withValues(alpha: 0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? BduColors.primary : Colors.grey[300]!,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CurrencyFormatter(),
        ],
        onTap: () => setState(() => _isFocused = true),
        onTapOutside: (_) => setState(() => _isFocused = false),
        onChanged: (_) => widget.onChanged(),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixText: 'XOF',
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? BduColors.primary : Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _LoanResultsCard extends StatelessWidget {
  final double monthlyPayment;
  final double totalAmount;
  final double totalInterest;
  final double debtRatio;
  final bool isEligible;
  final double interestRate;

  const _LoanResultsCard({
    required this.monthlyPayment,
    required this.totalAmount,
    required this.totalInterest,
    required this.debtRatio,
    required this.isEligible,
    required this.interestRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEligible
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isEligible ? Colors.green : Colors.orange).withValues(
              alpha: 0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  isEligible
                      ? Icons.check_circle_outline
                      : Icons.warning_outlined,
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
                      isEligible
                          ? 'Crédit possible !'
                          : 'Attention au taux d\'endettement',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isEligible
                          ? 'Votre dossier peut être accepté'
                          : 'Ajustez le montant ou la durée',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ResultRow(
                  label: 'Mensualité',
                  value:
                      '${monthlyPayment.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                  isHighlight: true,
                ),
                const Divider(color: Colors.white30, height: 24),
                _ResultRow(
                  label: 'Taux d\'intérêt',
                  value: '${interestRate.toStringAsFixed(1)}%',
                ),
                _ResultRow(
                  label: 'Coût total du crédit',
                  value:
                      '${totalInterest.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                ),
                _ResultRow(
                  label: 'Montant total à rembourser',
                  value:
                      '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                ),
                if (debtRatio > 0) ...[
                  const Divider(color: Colors.white30, height: 24),
                  _ResultRow(
                    label: 'Taux d\'endettement',
                    value: '${debtRatio.toStringAsFixed(1)}%',
                    isWarning: debtRatio > 33,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isWarning;

  const _ResultRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (isWarning)
                Icon(Icons.warning_outlined, color: Colors.white, size: 16),
              if (isWarning) const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHighlight ? 18 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isEligible;
  final VoidCallback onSimulateMore;
  final VoidCallback onApply;

  const _ActionButtons({
    required this.isEligible,
    required this.onSimulateMore,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfessionalButton(
            text: 'Nouvelle simulation',
            onPressed: onSimulateMore,
            variant: ButtonVariant.secondary,
            icon: Icons.refresh_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ProfessionalButton(
            text: isEligible ? 'Faire une demande' : 'Réajuster',
            onPressed: onApply,
            variant: ButtonVariant.primary,
            icon: isEligible ? Icons.send_outlined : Icons.tune_outlined,
          ),
        ),
      ],
    );
  }
}

class _LoanTipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'icon': Icons.lightbulb_outline,
        'title': 'Optimisez votre dossier',
        'description': 'Un apport personnel améliore vos conditions d\'emprunt',
      },
      {
        'icon': Icons.trending_down_outlined,
        'title': 'Réduisez vos charges',
        'description': 'Moins de charges = plus de capacité d\'emprunt',
      },
      {
        'icon': Icons.schedule_outlined,
        'title': 'Choisissez la bonne durée',
        'description': 'Plus c\'est long, plus les intérêts augmentent',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined, color: BduColors.primary),
              const SizedBox(width: 12),
              const Text(
                'Conseils d\'expert',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BduColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: BduColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'] as String,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanApplicationDialog extends StatelessWidget {
  final double loanAmount;
  final double monthlyPayment;
  final String loanType;
  final int duration;
  final bool isEligible;

  const _LoanApplicationDialog({
    required this.loanAmount,
    required this.monthlyPayment,
    required this.loanType,
    required this.duration,
    required this.isEligible,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isEligible
                    ? const LinearGradient(
                        colors: [Colors.green, Color(0xFF4CAF50)],
                      )
                    : const LinearGradient(
                        colors: [Colors.orange, Color(0xFFFF9800)],
                      ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEligible ? Icons.send_outlined : Icons.tune_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEligible ? 'Demande de crédit' : 'Réajustement nécessaire',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isEligible
                  ? 'Votre simulation est éligible ! Confirmez votre demande.'
                  : 'Ajustez vos paramètres pour améliorer votre éligibilité.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _DialogRow(label: 'Type', value: loanType),
                  _DialogRow(
                    label: 'Montant',
                    value:
                        '${loanAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                  ),
                  _DialogRow(label: 'Durée', value: '$duration mois'),
                  _DialogRow(
                    label: 'Mensualité',
                    value:
                        '${monthlyPayment.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ProfessionalButton(
                    text: 'Retour',
                    onPressed: () => Navigator.of(context).pop(),
                    variant: ButtonVariant.secondary,
                    icon: Icons.arrow_back_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfessionalButton(
                    text: isEligible ? 'Confirmer' : 'Modifier',
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (isEligible) {
                        // Navigate to loan application form
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Redirection vers le formulaire de demande...',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    variant: ButtonVariant.primary,
                    icon: isEligible
                        ? Icons.check_outlined
                        : Icons.edit_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _LoanInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [BduColors.primary, BduColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'À propos du crédit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Taux d\'endettement',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Le taux d\'endettement recommandé ne doit pas dépasser 33% de vos revenus nets. C\'est un indicateur clé pour l\'acceptation de votre crédit.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Calcul des mensualités',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Les mensualités sont calculées selon la formule standard des annuités constantes, incluant le capital et les intérêts.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: _ProfessionalButton(
                text: 'Compris',
                onPressed: () => Navigator.of(context).pop(),
                variant: ButtonVariant.primary,
                icon: Icons.check_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ButtonVariant { primary, secondary }

class _ProfessionalButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final IconData? icon;

  const _ProfessionalButton({
    required this.text,
    required this.onPressed,
    required this.variant,
    this.icon,
  });

  @override
  State<_ProfessionalButton> createState() => _ProfessionalButtonState();
}

class _ProfessionalButtonState extends State<_ProfessionalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: widget.variant == ButtonVariant.primary
                ? const LinearGradient(
                    colors: [BduColors.primary, BduColors.secondary],
                  )
                : null,
            color: widget.variant == ButtonVariant.secondary
                ? Colors.grey[100]
                : null,
            borderRadius: BorderRadius.circular(12),
            border: widget.variant == ButtonVariant.secondary
                ? Border.all(color: Colors.grey[300]!)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.variant == ButtonVariant.primary
                      ? Colors.white
                      : BduColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.variant == ButtonVariant.primary
                      ? Colors.white
                      : BduColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final int value = int.tryParse(newValue.text.replaceAll(' ', '')) ?? 0;
    final formattedText = value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
