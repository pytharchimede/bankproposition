import 'package:flutter/material.dart';
import '../theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'Tous';
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

  final _transactions = const [
    _Transaction(
      id: 'TXN001',
      type: 'Virement reçu',
      description: 'Salaire Octobre 2024',
      amount: 850000.0,
      date: '21 Août 2024',
      time: '14:30',
      isCredit: true,
      category: 'Salaire',
      accountNumber: '****1234',
      reference: 'VIR240821001',
      status: 'Validé',
    ),
    _Transaction(
      id: 'TXN002',
      type: 'Paiement marchand',
      description: 'Orange Money - Recharge',
      amount: 5000.0,
      date: '20 Août 2024',
      time: '09:15',
      isCredit: false,
      category: 'Télécoms',
      accountNumber: '****1234',
      reference: 'PAY240820002',
      status: 'Validé',
    ),
    _Transaction(
      id: 'TXN003',
      type: 'Retrait DAB',
      description: 'DAB BDU-CI Plateau',
      amount: 50000.0,
      date: '19 Août 2024',
      time: '16:45',
      isCredit: false,
      category: 'Retrait',
      accountNumber: '****1234',
      reference: 'ATM240819003',
      status: 'Validé',
    ),
    _Transaction(
      id: 'TXN004',
      type: 'Virement émis',
      description: 'Transfer vers Épargne',
      amount: 100000.0,
      date: '18 Août 2024',
      time: '11:20',
      isCredit: false,
      category: 'Épargne',
      accountNumber: '****9876',
      reference: 'VIR240818004',
      status: 'Validé',
    ),
    _Transaction(
      id: 'TXN005',
      type: 'Prélèvement',
      description: 'Facture CIE - Électricité',
      amount: 23500.0,
      date: '17 Août 2024',
      time: '06:00',
      isCredit: false,
      category: 'Utilities',
      accountNumber: '****1234',
      reference: 'PRE240817005',
      status: 'Validé',
    ),
  ];

  List<_Transaction> get _filteredTransactions {
    if (_selectedFilter == 'Tous') return _transactions;
    if (_selectedFilter == 'Crédit') {
      return _transactions.where((t) => t.isCredit).toList();
    }
    if (_selectedFilter == 'Débit') {
      return _transactions.where((t) => !t.isCredit).toList();
    }
    return _transactions;
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
          'Transactions',
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
              icon: const Icon(Icons.search),
              onPressed: () {
                // Recherche de transactions
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Filtres élégants
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
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
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tous',
                    isSelected: _selectedFilter == 'Tous',
                    onTap: () => setState(() => _selectedFilter = 'Tous'),
                  ),
                  _FilterChip(
                    label: 'Crédit',
                    isSelected: _selectedFilter == 'Crédit',
                    onTap: () => setState(() => _selectedFilter = 'Crédit'),
                  ),
                  _FilterChip(
                    label: 'Débit',
                    isSelected: _selectedFilter == 'Débit',
                    onTap: () => setState(() => _selectedFilter = 'Débit'),
                  ),
                ],
              ),
            ),
            // Résumé du solde
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: BduColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solde actuel',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '1 250 000.50 XOF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Liste des transactions
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredTransactions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];
                  return _ProfessionalTransactionCard(
                    transaction: transaction,
                    onTap: () => _showTransactionDetails(context, transaction),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, _Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsModal(transaction: transaction),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? BduColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfessionalTransactionCard extends StatelessWidget {
  final _Transaction transaction;
  final VoidCallback onTap;

  const _ProfessionalTransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Icône avec catégorie
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  transaction.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: _getCategoryColor(transaction.category),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Détails de la transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${transaction.isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: transaction.isCredit
                              ? const Color(0xFF059669)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.type,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${transaction.date} • ${transaction.time}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: transaction.status == 'Validé'
                              ? const Color(0xFF059669)
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Salaire':
        return Icons.work_outline;
      case 'Télécoms':
        return Icons.phone_android_outlined;
      case 'Retrait':
        return Icons.atm_outlined;
      case 'Épargne':
        return Icons.savings_outlined;
      case 'Utilities':
        return Icons.bolt_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Salaire':
        return const Color(0xFF059669);
      case 'Télécoms':
        return const Color(0xFF3B82F6);
      case 'Retrait':
        return const Color(0xFFDC2626);
      case 'Épargne':
        return const Color(0xFF7C3AED);
      case 'Utilities':
        return const Color(0xFFEA580C);
      default:
        return BduColors.primary;
    }
  }
}

class _TransactionDetailsModal extends StatelessWidget {
  final _Transaction transaction;

  const _TransactionDetailsModal({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: transaction.isCredit
                    ? [const Color(0xFF059669), const Color(0xFF10B981)]
                    : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.isCredit ? 'Crédit' : 'Débit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${transaction.isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} XOF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Détails
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.description_outlined,
                  label: 'Description',
                  value: transaction.description,
                ),
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Type',
                  value: transaction.type,
                ),
                _DetailRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Référence',
                  value: transaction.reference,
                ),
                _DetailRow(
                  icon: Icons.schedule_outlined,
                  label: 'Date et heure',
                  value: '${transaction.date} à ${transaction.time}',
                ),
                _DetailRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Compte',
                  value: transaction.accountNumber,
                ),
                _DetailRow(
                  icon: Icons.check_circle_outline,
                  label: 'Statut',
                  value: transaction.status,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Partager les détails
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Partager'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.grey[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Télécharger le reçu
                        },
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Reçu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BduColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Transaction {
  final String id;
  final String type;
  final String description;
  final double amount;
  final String date;
  final String time;
  final bool isCredit;
  final String category;
  final String accountNumber;
  final String reference;
  final String status;

  const _Transaction({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.time,
    required this.isCredit,
    required this.category,
    required this.accountNumber,
    required this.reference,
    required this.status,
  });
}
