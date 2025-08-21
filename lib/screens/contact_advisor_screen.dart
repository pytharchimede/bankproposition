import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class ContactAdvisorScreen extends StatefulWidget {
  const ContactAdvisorScreen({super.key});

  @override
  State<ContactAdvisorScreen> createState() => _ContactAdvisorScreenState();
}

class _ContactAdvisorScreenState extends State<ContactAdvisorScreen>
    with TickerProviderStateMixin {
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
    _fadeController.dispose();
    _slideController.dispose();
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
          'Contacter un conseiller',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header avec avatar conseiller
                _AdvisorHeader(),
                const SizedBox(height: 32),

                // Options de contact
                _ContactOptions(
                  onOptionSelected: (option) =>
                      _handleContactOption(context, option),
                ),
                const SizedBox(height: 24),

                // Informations de contact
                _ContactInfo(),
                const SizedBox(height: 24),

                // Horaires d'ouverture
                _OpeningHours(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleContactOption(BuildContext context, ContactOption option) {
    switch (option.type) {
      case ContactType.chat:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CustomerChatScreen()),
        );
        break;
      case ContactType.phone:
        _makePhoneCall(option.contact);
        break;
      case ContactType.email:
        _sendEmail(option.contact);
        break;
      case ContactType.whatsapp:
        _openWhatsApp(option.contact);
        break;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Demande d\'assistance BDU Mobile',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

class _AdvisorHeader extends StatelessWidget {
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.white,
                child: Icon(
                  Icons.support_agent,
                  size: 40,
                  color: BduColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Service Client BDU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Disponible 7j/7 pour vous accompagner',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatusIndicator(color: Colors.green, text: 'En ligne'),
              const SizedBox(width: 16),
              Text(
                'Temps de réponse: < 2min',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const _StatusIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

enum ContactType { chat, phone, email, whatsapp }

class ContactOption {
  final ContactType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final String contact;

  ContactOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.contact,
  });
}

class _ContactOptions extends StatelessWidget {
  final Function(ContactOption) onOptionSelected;

  const _ContactOptions({required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    final options = [
      ContactOption(
        type: ContactType.chat,
        title: 'Chat en direct',
        subtitle: 'Réponse immédiate',
        icon: Icons.chat_bubble_outline,
        colors: [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
        contact: '',
      ),
      ContactOption(
        type: ContactType.phone,
        title: 'Appel téléphonique',
        subtitle: '+225 27 20 21 20 00',
        icon: Icons.phone_outlined,
        colors: [const Color(0xFF10B981), const Color(0xFF059669)],
        contact: '+22527202120000',
      ),
      ContactOption(
        type: ContactType.email,
        title: 'E-mail',
        subtitle: 'support@bdu.ci',
        icon: Icons.email_outlined,
        colors: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
        contact: 'support@bdu.ci',
      ),
      ContactOption(
        type: ContactType.whatsapp,
        title: 'WhatsApp',
        subtitle: '+225 07 08 09 10 11',
        icon: Icons.message_outlined,
        colors: [const Color(0xFF25D366), const Color(0xFF128C7E)],
        contact: '+2250708091011',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisissez votre mode de contact préféré',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...options.map(
          (option) => _ContactOptionCard(
            option: option,
            onTap: () => onOptionSelected(option),
          ),
        ),
      ],
    );
  }
}

class _ContactOptionCard extends StatefulWidget {
  final ContactOption option;
  final VoidCallback onTap;

  const _ContactOptionCard({required this.option, required this.onTap});

  @override
  State<_ContactOptionCard> createState() => _ContactOptionCardState();
}

class _ContactOptionCardState extends State<_ContactOptionCard>
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: Container(
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.option.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.option.icon,
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
                        widget.option.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.option.subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
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
              Icon(Icons.info_outline, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Informations utiles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Siège social',
            content: 'Avenue Chardy, Plateau\nAbidjan, Côte d\'Ivoire',
          ),
          _InfoRow(
            icon: Icons.language_outlined,
            title: 'Site web',
            content: 'www.bdu.ci',
          ),
          _InfoRow(
            icon: Icons.security_outlined,
            title: 'Urgence sécurité',
            content: '+225 27 20 21 20 99',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
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
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningHours extends StatelessWidget {
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
              Icon(Icons.access_time, color: BduColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Horaires d\'ouverture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HourRow('Lundi - Vendredi', '8h00 - 17h00', true),
          _HourRow('Samedi', '8h00 - 12h00', false),
          _HourRow('Dimanche', 'Fermé', false),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.chat, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Chat disponible 24h/24 et 7j/7',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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

class _HourRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool isToday;

  const _HourRow(this.day, this.hours, this.isToday);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? BduColors.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              color: isToday ? BduColors.primary : Colors.black87,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              color: isToday ? BduColors.primary : Colors.grey[600],
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Import this in the file that uses it
class CustomerChatScreen extends StatefulWidget {
  const CustomerChatScreen({super.key});

  @override
  State<CustomerChatScreen> createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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

    _initializeChat();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    _messages.addAll([
      ChatMessage(
        text:
            'Bonjour ! Je suis Sofia, votre conseillère virtuelle BDU. Comment puis-je vous aider aujourd\'hui ?',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
        avatar: null,
      ),
    ]);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showQuickReplies();
      }
    });
  }

  void _showQuickReplies() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
          isQuickReplies: true,
          quickReplies: [
            'Consulter mes comptes',
            'Faire un virement',
            'Bloquer ma carte',
            'Demander un crédit',
            'Autre question',
          ],
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response
    Future.delayed(const Duration(seconds: 2), () {
      _simulateBotResponse(text);
    });
  }

  void _simulateBotResponse(String userMessage) {
    String response = _generateResponse(userMessage.toLowerCase());

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
          avatar: null,
        ),
      );
    });
    _scrollToBottom();
  }

  String _generateResponse(String message) {
    if (message.contains('compte') || message.contains('solde')) {
      return 'Je vois que vous souhaitez consulter vos comptes. Vous pouvez voir tous vos soldes directement dans l\'application sur la page d\'accueil. Avez-vous besoin d\'aide pour naviguer ?';
    } else if (message.contains('virement') || message.contains('transfert')) {
      return 'Pour effectuer un virement, rendez-vous dans l\'onglet "Virements" de l\'application. Vous pourrez choisir le bénéficiaire et le montant. Le processus est sécurisé avec une double authentification.';
    } else if (message.contains('carte') || message.contains('bloquer')) {
      return 'Pour bloquer votre carte, allez dans "Mes cartes" puis sélectionnez l\'option "Bloquer temporairement". En cas de perte ou vol, contactez immédiatement le +225 27 20 21 20 99.';
    } else if (message.contains('crédit') || message.contains('prêt')) {
      return 'Notre simulateur de crédit vous permet d\'estimer vos mensualités. Vous le trouverez dans l\'onglet "Crédit". Pour une demande officielle, nous devrons étudier votre dossier.';
    } else if (message.contains('problème') || message.contains('aide')) {
      return 'Je suis là pour vous aider ! Pouvez-vous me décrire plus précisément le problème que vous rencontrez ? Cela m\'aidera à mieux vous orienter.';
    } else {
      return 'Merci pour votre message. Un conseiller humain peut vous contacter pour un suivi personnalisé. Souhaitez-vous que je programme un rappel ?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: BduColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Icon(
                    Icons.support_agent,
                    color: BduColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sofia - Service Client',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'En ligne',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatMenu(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _TypingIndicator();
                  }
                  return _ChatBubble(
                    message: _messages[index],
                    onQuickReply: _sendMessage,
                  );
                },
              ),
            ),
            _ChatInput(controller: _messageController, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Nouvelle conversation'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _messages.clear();
                  _initializeChat();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Passer un appel'),
              onTap: () {
                Navigator.pop(context);
                // Implement phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Envoyer un email'),
              onTap: () {
                Navigator.pop(context);
                // Implement email
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? avatar;
  final bool isQuickReplies;
  final List<String>? quickReplies;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.avatar,
    this.isQuickReplies = false,
    this.quickReplies,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onQuickReply;

  const _ChatBubble({required this.message, required this.onQuickReply});

  @override
  Widget build(BuildContext context) {
    if (message.isQuickReplies) {
      return _QuickReplies(
        replies: message.quickReplies ?? [],
        onReply: onQuickReply,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser && message.avatar != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Icon(
                    Icons.support_agent,
                    color: BduColors.primary,
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? BduColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  final List<String> replies;
  final Function(String) onReply;

  const _QuickReplies({required this.replies, required this.onReply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggestions :',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: replies
                .map(
                  (reply) => GestureDetector(
                    onTap: () => onReply(reply),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: BduColors.primary),
                      ),
                      child: Text(
                        reply,
                        style: TextStyle(
                          color: BduColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.support_agent,
              color: BduColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(controller: _controller, delay: 0),
                const SizedBox(width: 4),
                _TypingDot(controller: _controller, delay: 300),
                const SizedBox(width: 4),
                _TypingDot(controller: _controller, delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatelessWidget {
  final AnimationController controller;
  final int delay;

  const _TypingDot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animationValue = (controller.value * 1500 - delay) / 300;
        final opacity = animationValue >= 0 && animationValue <= 1
            ? (0.5 + 0.5 * (1 - (animationValue - 0.5).abs() * 2)).clamp(
                0.3,
                1.0,
              )
            : 0.3;

        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(
                  hintText: 'Tapez votre message...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (text) => widget.onSend(text),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: _hasText ? BduColors.primary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _hasText
                  ? () => widget.onSend(widget.controller.text)
                  : null,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
