import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class TransferWizard extends StatefulWidget {
  const TransferWizard({super.key});

  @override
  State<TransferWizard> createState() => _TransferWizardState();
}

class _TransferWizardState extends State<TransferWizard>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers
  final _amountController = TextEditingController();
  final _beneficiaryController = TextEditingController();
  final _ibanController = TextEditingController();
  final _motifController = TextEditingController();
  final _otpController = TextEditingController();

  // Form data
  String _sourceAccount = 'Compte courant - CI00 1234 5678 9012 3456';
  String _transferType = 'Virement interne';
  bool _isScheduled = false;
  DateTime? _scheduledDate;

  final List<_TransferStep> _steps = [
    _TransferStep(
      title: 'Source',
      subtitle: 'Sélectionnez le compte débiteur',
      icon: Icons.account_balance_outlined,
    ),
    _TransferStep(
      title: 'Destinataire',
      subtitle: 'Informations du bénéficiaire',
      icon: Icons.person_outline,
    ),
    _TransferStep(
      title: 'Montant',
      subtitle: 'Montant et motif du virement',
      icon: Icons.attach_money_outlined,
    ),
    _TransferStep(
      title: 'Confirmation',
      subtitle: 'Vérifiez les détails',
      icon: Icons.fact_check_outlined,
    ),
    _TransferStep(
      title: 'Validation',
      subtitle: 'Code de confirmation',
      icon: Icons.security_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _amountController.dispose();
    _beneficiaryController.dispose();
    _ibanController.dispose();
    _motifController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _resetAnimations();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _resetAnimations();
    }
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _executeTransfer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TransferReceiptDialog(
        sourceAccount: _sourceAccount,
        beneficiary: _beneficiaryController.text,
        iban: _ibanController.text,
        amount: _amountController.text,
        motif: _motifController.text,
        transferType: _transferType,
        isScheduled: _isScheduled,
        scheduledDate: _scheduledDate,
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
          'Nouveau virement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1}/${_steps.length}',
                style: TextStyle(
                  color: BduColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator moderne
          Container(
            padding: const EdgeInsets.all(20),
            child: _ModernStepIndicator(
              steps: _steps,
              currentStep: _currentStep,
            ),
          ),
          // Contenu des étapes
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSourceStep(),
                    _buildBeneficiaryStep(),
                    _buildAmountStep(),
                    _buildConfirmationStep(),
                    _buildValidationStep(),
                  ],
                ),
              ),
            ),
          ),
          // Boutons de navigation
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildSourceStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'Compte débiteur',
            subtitle: 'Sélectionnez le compte à débiter',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 24),
          _ProfessionalAccountSelector(
            accounts: const [
              'Compte courant - CI00 1234 5678 9012 3456',
              'Épargne - CI00 9876 5432 1098 7654',
            ],
            selectedAccount: _sourceAccount,
            onAccountSelected: (account) {
              setState(() => _sourceAccount = account);
            },
          ),
          const SizedBox(height: 24),
          _TransferTypeSelector(
            selectedType: _transferType,
            onTypeSelected: (type) {
              setState(() => _transferType = type);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'Bénéficiaire',
            subtitle: 'Informations du destinataire',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          _ProfessionalTextField(
            controller: _beneficiaryController,
            label: 'Nom du bénéficiaire',
            icon: Icons.person_outline,
            hint: 'Ex: KOUAME Jean-Baptiste',
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Nom requis';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _ProfessionalTextField(
            controller: _ibanController,
            label: 'IBAN du bénéficiaire',
            icon: Icons.account_balance_outlined,
            hint: 'Ex: CI00 1234 5678 9012 3456',
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\s]')),
              _IbanFormatter(),
            ],
            validator: (value) {
              if (value?.isEmpty ?? true) return 'IBAN requis';
              if (value!.length < 27) return 'IBAN invalide';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'Montant et motif',
            subtitle: 'Détails de la transaction',
            icon: Icons.attach_money_outlined,
          ),
          const SizedBox(height: 24),
          _ProfessionalAmountField(
            controller: _amountController,
            label: 'Montant à transférer',
            currency: 'XOF',
          ),
          const SizedBox(height: 16),
          _ProfessionalTextField(
            controller: _motifController,
            label: 'Motif du virement',
            icon: Icons.description_outlined,
            hint: 'Ex: Remboursement, Salaire, Achat...',
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          _ScheduleTransferCard(
            isScheduled: _isScheduled,
            scheduledDate: _scheduledDate,
            onScheduleChanged: (scheduled) {
              setState(() => _isScheduled = scheduled);
            },
            onDateChanged: (date) {
              setState(() => _scheduledDate = date);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'Confirmation',
            subtitle: 'Vérifiez les détails du virement',
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 24),
          _TransferSummaryCard(
            sourceAccount: _sourceAccount,
            beneficiary: _beneficiaryController.text,
            iban: _ibanController.text,
            amount: _amountController.text,
            motif: _motifController.text,
            transferType: _transferType,
            isScheduled: _isScheduled,
            scheduledDate: _scheduledDate,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'Validation',
            subtitle: 'Saisissez votre code de confirmation',
            icon: Icons.security_outlined,
          ),
          const SizedBox(height: 24),
          _OtpInputField(
            controller: _otpController,
            onCompleted: (otp) {
              // Auto-proceed when OTP is complete
              Future.delayed(const Duration(milliseconds: 500), () {
                _executeTransfer();
              });
            },
          ),
          const SizedBox(height: 24),
          _SecurityInfoCard(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _ProfessionalButton(
                text: 'Précédent',
                onPressed: _previousStep,
                variant: ButtonVariant.secondary,
                icon: Icons.arrow_back_outlined,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _ProfessionalButton(
              text: _currentStep == _steps.length - 1 ? 'Valider' : 'Suivant',
              onPressed: _currentStep == _steps.length - 1
                  ? _executeTransfer
                  : _nextStep,
              variant: ButtonVariant.primary,
              icon: _currentStep == _steps.length - 1
                  ? Icons.check_outlined
                  : Icons.arrow_forward_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

// Classes utilitaires et composants personnalisés
class _TransferStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const _TransferStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ModernStepIndicator extends StatelessWidget {
  final List<_TransferStep> steps;
  final int currentStep;

  const _ModernStepIndicator({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isActive = index <= currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [BduColors.primary, BduColors.secondary],
                            )
                          : null,
                      color: isActive ? null : Colors.grey[300],
                      border: isCurrent
                          ? Border.all(color: BduColors.primary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      isActive ? Icons.check : steps[index].icon,
                      color: isActive ? Colors.white : Colors.grey[600],
                      size: 16,
                    ),
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: index < currentStep
                              ? const LinearGradient(
                                  colors: [
                                    BduColors.primary,
                                    BduColors.secondary,
                                  ],
                                )
                              : null,
                          color: index < currentStep ? null : Colors.grey[300],
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Text(
          steps[currentStep].title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: BduColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          steps[currentStep].subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BduColors.primary, BduColors.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfessionalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLines;

  const _ProfessionalTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<_ProfessionalTextField> createState() => _ProfessionalTextFieldState();
}

class _ProfessionalTextFieldState extends State<_ProfessionalTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? BduColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: _isFocused ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        maxLines: widget.maxLines,
        onTap: () => setState(() => _isFocused = true),
        onTapOutside: (_) => setState(() => _isFocused = false),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
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
            borderSide: BorderSide(color: BduColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _ProfessionalAmountField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String currency;

  const _ProfessionalAmountField({
    required this.controller,
    required this.label,
    required this.currency,
  });

  @override
  State<_ProfessionalAmountField> createState() =>
      _ProfessionalAmountFieldState();
}

class _ProfessionalAmountFieldState extends State<_ProfessionalAmountField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BduColors.primary.withValues(alpha: 0.05),
            BduColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? BduColors.primary
              : BduColors.primary.withValues(alpha: 0.2),
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
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: BduColors.primary,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.currency,
          suffixStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(
            Icons.attach_money_outlined,
            color: _isFocused ? BduColors.primary : Colors.grey[600],
            size: 28,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}

class _ProfessionalAccountSelector extends StatelessWidget {
  final List<String> accounts;
  final String selectedAccount;
  final Function(String) onAccountSelected;

  const _ProfessionalAccountSelector({
    required this.accounts,
    required this.selectedAccount,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: accounts.map((account) {
        final isSelected = account == selectedAccount;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onAccountSelected(account),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BduColors.primary : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? BduColors.primary.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [BduColors.primary, BduColors.secondary],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      account,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? BduColors.primary : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: BduColors.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TransferTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const _TransferTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {
        'title': 'Virement interne',
        'subtitle': 'Entre vos comptes BDU',
        'icon': Icons.swap_horiz,
      },
      {
        'title': 'Virement externe',
        'subtitle': 'Vers autre banque',
        'icon': Icons.send_outlined,
      },
      {
        'title': 'Virement international',
        'subtitle': 'Transfert à l\'étranger',
        'icon': Icons.public_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de virement',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...types.map((type) {
          final isSelected = type['title'] == selectedType;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onTypeSelected(type['title'] as String),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BduColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? BduColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      color: isSelected ? BduColors.primary : Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? BduColors.primary
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            type['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.radio_button_checked, color: BduColors.primary)
                    else
                      Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey[400],
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ScheduleTransferCard extends StatelessWidget {
  final bool isScheduled;
  final DateTime? scheduledDate;
  final Function(bool) onScheduleChanged;
  final Function(DateTime) onDateChanged;

  const _ScheduleTransferCard({
    required this.isScheduled,
    required this.scheduledDate,
    required this.onScheduleChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_outlined, color: BduColors.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Programmer le virement',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              Switch(
                value: isScheduled,
                onChanged: onScheduleChanged,
                activeTrackColor: BduColors.primary,
                activeThumbColor: Colors.white,
              ),
            ],
          ),
          if (isScheduled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      scheduledDate ??
                      DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  onDateChanged(date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BduColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: BduColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: BduColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      scheduledDate != null
                          ? 'Le ${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
                          : 'Sélectionner une date',
                      style: TextStyle(
                        color: BduColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransferSummaryCard extends StatelessWidget {
  final String sourceAccount;
  final String beneficiary;
  final String iban;
  final String amount;
  final String motif;
  final String transferType;
  final bool isScheduled;
  final DateTime? scheduledDate;

  const _TransferSummaryCard({
    required this.sourceAccount,
    required this.beneficiary,
    required this.iban,
    required this.amount,
    required this.motif,
    required this.transferType,
    required this.isScheduled,
    required this.scheduledDate,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      {
        'label': 'Compte débiteur',
        'value': sourceAccount,
        'icon': Icons.account_balance_outlined,
      },
      {
        'label': 'Bénéficiaire',
        'value': beneficiary,
        'icon': Icons.person_outline,
      },
      {
        'label': 'IBAN destinataire',
        'value': iban,
        'icon': Icons.credit_card_outlined,
      },
      {
        'label': 'Montant',
        'value': '$amount XOF',
        'icon': Icons.attach_money_outlined,
      },
      {'label': 'Motif', 'value': motif, 'icon': Icons.description_outlined},
      {'label': 'Type', 'value': transferType, 'icon': Icons.category_outlined},
    ];

    if (isScheduled && scheduledDate != null) {
      details.add({
        'label': 'Date programmée',
        'value':
            '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}',
        'icon': Icons.schedule_outlined,
      });
    }

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [BduColors.primary, BduColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Récapitulatif du virement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    detail['icon'] as IconData,
                    color: BduColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail['value'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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

class _OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;

  const _OtpInputField({required this.controller, required this.onCompleted});

  @override
  State<_OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<_OtpInputField> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

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
        children: [
          const Text(
            'Code envoyé par SMS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Saisissez le code à 6 chiffres',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 50,
                height: 60,
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: BduColors.primary,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: BduColors.primary,
                        width: 2,
                      ),
                    ),
                    fillColor: BduColors.primary.withValues(alpha: 0.05),
                    filled: true,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }

                    // Check if all fields are filled
                    final otp = _controllers.map((c) => c.text).join();
                    if (otp.length == 6) {
                      widget.controller.text = otp;
                      widget.onCompleted(otp);
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security_outlined, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction sécurisée',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre virement est protégé par chiffrement SSL',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferReceiptDialog extends StatelessWidget {
  final String sourceAccount;
  final String beneficiary;
  final String iban;
  final String amount;
  final String motif;
  final String transferType;
  final bool isScheduled;
  final DateTime? scheduledDate;

  const _TransferReceiptDialog({
    required this.sourceAccount,
    required this.beneficiary,
    required this.iban,
    required this.amount,
    required this.motif,
    required this.transferType,
    required this.isScheduled,
    required this.scheduledDate,
  });

  @override
  Widget build(BuildContext context) {
    final reference = 'VR${DateTime.now().millisecondsSinceEpoch}';

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
                gradient: const LinearGradient(
                  colors: [Colors.green, Color(0xFF4CAF50)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Virement effectué',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isScheduled
                  ? 'Votre virement a été programmé'
                  : 'Votre virement a été traité avec succès',
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
                  _ReceiptRow(label: 'Référence', value: reference),
                  _ReceiptRow(label: 'Montant', value: '$amount XOF'),
                  _ReceiptRow(label: 'Bénéficiaire', value: beneficiary),
                  _ReceiptRow(
                    label: 'Date',
                    value: isScheduled && scheduledDate != null
                        ? '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}'
                        : 'Immédiat',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ProfessionalButton(
                    text: 'Partager',
                    onPressed: () {
                      // Implement share functionality
                    },
                    variant: ButtonVariant.secondary,
                    icon: Icons.share_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProfessionalButton(
                    text: 'Terminer',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    variant: ButtonVariant.primary,
                    icon: Icons.home_outlined,
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

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

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

// Input formatters
class _IbanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '').toUpperCase();
    final formattedText = text
        .replaceAllMapped(RegExp(r'(.{4})'), (match) => '${match.group(1)} ')
        .trim();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
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
