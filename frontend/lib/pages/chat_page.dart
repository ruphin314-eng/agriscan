import 'package:agriscan/services/api_config.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String? imagePath;
  const ChatPage({super.key, this.imagePath});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Messages locaux affichés dans l'UI
  final List<Map<String, dynamic>> _messages = [];

  bool _isLoading = false;

  // ID de la conversation créée en base (null = pas encore créée)
  int? _conversationId;

  // Saison courante déterminée automatiquement
  String _saisonCourante = _getSaisonCourante();

  // ── Détermine la saison selon le mois ──────────────────────
  static String _getSaisonCourante() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'Printemps';
    if (month >= 6 && month <= 8) return 'Été';
    if (month >= 9 && month <= 11) return 'Automne';
    return 'Hiver';
  }

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _messages.add({
        'role': 'user',
        'type': 'image',
        'imagePath': widget.imagePath,
        'contenu': '',
      });
      _analyserImage(widget.imagePath!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll vers le bas ─────────────────────────────────────
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

  // ── Créer la conversation en base (premier échange) ────────
  Future<int?> _creerConversation({
    required String titre,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();
      if (token == null || userId == null) return null;

      final messagesDto = messages.map((m) => {
        'role': m['role'],
        'contenu': m['contenu'] ?? '',
        'type': m['type'] ?? 'text',
        if (m['imageUrl'] != null) 'imageUrl': m['imageUrl'],
      }).toList();

      final response = await http.post(
        Uri.parse(ApiConfig.conversations),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'clientId': userId,
          'titre': titre,
          'saison': _saisonCourante,
          'messages': messagesDto,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as int;
      }
    } catch (e) {
      debugPrint('Erreur création conversation: $e');
    }
    return null;
  }

  // ── Ajouter un message à la conversation existante ─────────
  Future<void> _ajouterMessageEnBase({
    required String role,
    required String contenu,
    String type = 'text',
    String? imageUrl,
  }) async {
    if (_conversationId == null) return;
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return;

      await http.post(
        Uri.parse(ApiConfig.ajouterMessage(_conversationId!)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': role,
          'contenu': contenu,
          'type': type,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      );
    } catch (e) {
      debugPrint('Erreur ajout message: $e');
    }
  }

  // ── Analyser une image ─────────────────────────────────────
  Future<void> _analyserImage(String imagePath) async {
    setState(() => _isLoading = true);
    _scrollToBottom();

    // Simuler l'appel IA (remplace par ton vrai endpoint IA si disponible)
    await Future.delayed(const Duration(seconds: 2));

    const reponseIA =
        'J\'analyse votre image... 🌿\n\n'
        'Je détecte une possible maladie fongique sur votre plante. '
        'Voici mes recommandations :\n\n'
        '• Traitement fongicide recommandé\n'
        '• Éviter l\'arrosage excessif\n'
        '• Isoler la plante des autres cultures';

    setState(() {
      _messages.add({
        'role': 'assistant',
        'type': 'text',
        'contenu': reponseIA,
      });
      _isLoading = false;
    });
    _scrollToBottom();

    // Sauvegarder en base
    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!isLoggedIn) return;

    if (_conversationId == null) {
      // Créer la conversation avec les 2 messages (image + réponse IA)
      final id = await _creerConversation(
        titre: 'Analyse de plante',
        messages: [
          {
            'role': 'user',
            'contenu': '',
            'type': 'image',
            // imageUrl à remplir si tu uploads l'image sur le serveur
          },
          {
            'role': 'assistant',
            'contenu': reponseIA,
            'type': 'text',
          },
        ],
      );
      if (mounted) setState(() => _conversationId = id);
    } else {
      await _ajouterMessageEnBase(
        role: 'user',
        contenu: '',
        type: 'image',
      );
      await _ajouterMessageEnBase(
        role: 'assistant',
        contenu: reponseIA,
      );
    }
  }

  // ── Envoyer un message texte ───────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    setState(() {
      _messages.add({'role': 'user', 'type': 'text', 'contenu': text});
      _isLoading = true;
    });
    _scrollToBottom();

    // Simuler réponse IA (remplace par ton vrai endpoint IA)
    await Future.delayed(const Duration(seconds: 1));
    final reponse = 'Je traite votre question sur l\'agriculture... 🌱\n\n'
        'Voici quelques conseils adaptés à votre situation : "$text"';

    setState(() {
      _messages.add({'role': 'assistant', 'type': 'text', 'contenu': reponse});
      _isLoading = false;
    });
    _scrollToBottom();

    // Sauvegarder en base
    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!isLoggedIn) return;

    if (_conversationId == null) {
      // Première conversation texte
      final id = await _creerConversation(
        titre: text.length > 40 ? '${text.substring(0, 40)}...' : text,
        messages: [
          {'role': 'user', 'contenu': text, 'type': 'text'},
          {'role': 'assistant', 'contenu': reponse, 'type': 'text'},
        ],
      );
      if (mounted) setState(() => _conversationId = id);
    } else {
      // Ajouter à la conversation existante
      await _ajouterMessageEnBase(role: 'user', contenu: text);
      await _ajouterMessageEnBase(role: 'assistant', contenu: reponse);
    }
  }

  // ── Nouvelle discussion ────────────────────────────────────
  void _nouvelleDiscussion() {
    setState(() {
      _messages.clear();
      _conversationId = null;
    });
  }

  // ── Ajouter une image depuis caméra/galerie ────────────────
  Future<void> _ajouterImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'type': 'image',
        'imagePath': image.path,
        'contenu': '',
      });
    });
    _scrollToBottom();
    await _analyserImage(image.path);
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ThemeProvider>(context).darkMode;
    final bgColor =
    darkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final inputBgColor =
    darkMode ? const Color(0xFF2A2A2A) : Colors.grey[200]!;
    final bubbleBgColor = darkMode ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = darkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CD964),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agriscan AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: Colors.white),
            tooltip: 'Nouvelle discussion',
            onPressed: _nouvelleDiscussion,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(textColor)
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length) {
                  return _buildTypingIndicator(bubbleBgColor);
                }
                return _buildMessage(
                  _messages[i],
                  bubbleBgColor,
                  textColor,
                );
              },
            ),
          ),
          _buildInputBar(inputBgColor, darkMode),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────
  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 64, color: Color(0xFF4CD964)),
          const SizedBox(height: 16),
          Text(
            'Agriscan AI',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prenez ou importez une photo\npour analyser vos plantes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bulle de message ───────────────────────────────────────
  Widget _buildMessage(
      Map<String, dynamic> message,
      Color bubbleBgColor,
      Color textColor,
      ) {
    final isUser = message['role'] == 'user';
    final isImage = message['type'] == 'image';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4CD964),
              child: Icon(Icons.eco, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: isImage
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF4CD964).withValues(alpha: 0.2)
                    : bubbleBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isImage
                  ? _buildImageBubble(message)
                  : Text(
                message['contenu'] ?? '',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ── Bulle image (locale ou réseau) ────────────────────────
  Widget _buildImageBubble(Map<String, dynamic> message) {
    final imagePath = message['imagePath'] as String?;
    final imageUrl = message['imageUrl'] as String?;

    Widget imageWidget;

    if (imagePath != null) {
      imageWidget = Image.file(
        File(imagePath),
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.image, size: 80, color: Colors.grey),
      );
    } else if (imageUrl != null) {
      imageWidget = Image.network(
        imageUrl,
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.image, size: 80, color: Colors.grey),
      );
    } else {
      imageWidget = const Icon(Icons.image, size: 80, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  // ── Indicateur de frappe ───────────────────────────────────
  Widget _buildTypingIndicator(Color bubbleBgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF4CD964),
            child: Icon(Icons.eco, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotIndicator(delay: 0),
                SizedBox(width: 4),
                _DotIndicator(delay: 200),
                SizedBox(width: 4),
                _DotIndicator(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre de saisie ────────────────────────────────────────
  Widget _buildInputBar(Color inputBgColor, bool darkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inputBgColor,
        border:
        Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF4CD964)),
            onPressed: () => _ajouterImage(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Color(0xFF4CD964)),
            onPressed: () => _ajouterImage(ImageSource.gallery),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black87,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor:
                darkMode ? const Color(0xFF3A3A3A) : Colors.grey[300],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF4CD964),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dot animé ──────────────────────────────────────────────────
class _DotIndicator extends StatefulWidget {
  final int delay;
  const _DotIndicator({required this.delay});

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF4CD964),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}