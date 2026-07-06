import 'package:agriscan/services/api_config.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
  final List<Map<String, dynamic>> _messages = [];

  bool _isLoading = false;
  int? _conversationId;

  // Résultat de la dernière analyse (pour donner les solutions si demandé)
  Map<String, dynamic>? _dernierResultatAnalyse;

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

  // ── Créer la conversation en base ─────────────────────────
  Future<int?> _creerConversation({
    required String titre,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();
      if (token == null || userId == null) return null;

      final messagesDto = messages
          .map((m) => {
        'role': m['role'],
        'contenu': m['contenu'] ?? '',
        'type': m['type'] ?? 'text',
        if (m['imageUrl'] != null) 'imageUrl': m['imageUrl'],
      })
          .toList();

      final response = await http.post(
        Uri.parse(ApiConfig.conversations),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'clientId': userId,
          'titre': titre,
          'saison': _getSaisonCourante(),
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

  // ── Ajouter un message en base ────────────────────────────
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

  // ── Analyser l'image via le backend ───────────────────────
  Future<void> _analyserImage(String imagePath) async {
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();

      // Construire la requête multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.analyseImage +
            (userId != null ? '?clientId=$userId' : '')),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final extension = imagePath.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'png' : 'jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType('image', mimeType),
        ),
      );

      final streamedResponse =
      await request.send().timeout(const Duration(seconds: 180));
      final response =
      await http.Response.fromStream(streamedResponse);

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Analyse réussie
        final data = jsonDecode(response.body);
        _dernierResultatAnalyse = data;

        final String messagePrincipal =
            data['messagePrincipal'] ?? 'Analyse terminée.';
        final List<dynamic> risques =
            data['risquesSaisonniers'] ?? [];
        final String saison = data['saison'] ?? '';
        final String questionSuivi = data['questionSuivi'] ??
            'Voulez-vous les solutions ? 🌿';

        // Construire le message complet
        String messageComplet = messagePrincipal;

        if (risques.isNotEmpty) {
          messageComplet += '\n\n🗓️ **Risques saisonniers ($saison) :**\n';
          for (final risque in risques) {
            messageComplet += '\n$risque';
          }
        }

        messageComplet += '\n\n$questionSuivi';

        setState(() {
          _messages.add({
            'role': 'assistant',
            'type': 'text',
            'contenu': messageComplet,
          });
          _isLoading = false;
        });

        // Sauvegarder en base
        final isLoggedIn = await AuthStorage.isLoggedIn();
        if (!isLoggedIn) return;

        if (_conversationId == null) {
          final id = await _creerConversation(
            titre: 'Analyse maïs — $saison',
            messages: [
              {'role': 'user', 'contenu': '', 'type': 'image'},
              {'role': 'assistant', 'contenu': messageComplet, 'type': 'text'},
            ],
          );
          if (mounted) setState(() => _conversationId = id);
        } else {
          await _ajouterMessageEnBase(
              role: 'user', contenu: '', type: 'image');
          await _ajouterMessageEnBase(
              role: 'assistant', contenu: messageComplet);
        }
      } else if (response.statusCode == 400) {
        // ❌ Pas du maïs
        final erreur = response.body.contains('{')
            ? jsonDecode(response.body).toString()
            : response.body;

        setState(() {
          _messages.add({
            'role': 'assistant',
            'type': 'text',
            'contenu':
            '⚠️ $erreur\n\nConseils pour une bonne analyse :\n\n'
                '📸 Photographiez une **feuille de maïs** entière\n'
                '🌿 Assurez-vous que la feuille remplit bien le cadre\n'
                '☀️ Prenez la photo en pleine lumière',
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'type': 'text',
            'contenu':
            '❌ Erreur lors de l\'analyse. Veuillez réessayer.',
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'type': 'text',
          'contenu':
          '❌ Impossible de joindre le serveur. '
              'Vérifiez votre connexion internet.',
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
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

    String reponse;

    // ✅ Détecter si l'utilisateur demande les solutions
    final textLower = text.toLowerCase();
    final demandeSolutions = textLower.contains('oui') ||
        textLower.contains('solution') ||
        textLower.contains('traitement') ||
        textLower.contains('comment') ||
        textLower.contains('soigner') ||
        textLower.contains('remède');

    if (demandeSolutions && _dernierResultatAnalyse != null) {
      reponse = _construireReponsesSolutions();
    } else if (_dernierResultatAnalyse != null) {
      // Question générale sur l'analyse en cours
      reponse = '🌿 Je suis spécialisé dans l\'analyse du maïs. '
          'Voici ce que je peux faire :\n\n'
          '📸 Analysez une nouvelle photo\n'
          '💊 Demandez les solutions pour les maladies détectées\n'
          '❓ Posez une question sur votre culture de maïs';
    } else {
      reponse = '🌽 Bonjour ! Je suis votre assistant spécialisé '
          'dans la santé du maïs.\n\n'
          'Pour commencer, prenez ou importez une photo '
          'd\'une feuille de maïs en utilisant les icônes '
          'caméra ou galerie ci-dessous. 📸';
    }

    setState(() {
      _messages.add({'role': 'assistant', 'type': 'text', 'contenu': reponse});
      _isLoading = false;
    });
    _scrollToBottom();

    // Sauvegarder en base
    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!isLoggedIn) return;

    if (_conversationId == null) {
      final id = await _creerConversation(
        titre: text.length > 40 ? '${text.substring(0, 40)}...' : text,
        messages: [
          {'role': 'user', 'contenu': text, 'type': 'text'},
          {'role': 'assistant', 'contenu': reponse, 'type': 'text'},
        ],
      );
      if (mounted) setState(() => _conversationId = id);
    } else {
      await _ajouterMessageEnBase(role: 'user', contenu: text);
      await _ajouterMessageEnBase(role: 'assistant', contenu: reponse);
    }
  }

  // ── Construire les solutions selon les maladies détectées ──
  String _construireReponsesSolutions() {
    final data = _dernierResultatAnalyse!;
    final List<dynamic> maladies = data['maladies'] ?? [];

    if (maladies.isEmpty) {
      return '✅ Aucune maladie détectée sur votre plant de maïs !\n\n'
          'Pour prévenir les maladies courantes :\n\n'
          '💧 Maintenez un arrosage régulier sans excès\n'
          '🌱 Pratiquez la rotation des cultures\n'
          '🌿 Éliminez les mauvaises herbes régulièrement\n'
          '👁️ Surveillez vos plants chaque semaine\n'
          '🧹 Nettoyez les résidus de récolte après chaque saison';
    }

    final sb = StringBuffer();
    sb.write('💊 **Solutions pour les maladies détectées :**\n\n');

    for (final maladie in maladies) {
      final nom = maladie['nom'] ?? 'Maladie inconnue';
      final probabilite = ((maladie['probabilite'] ?? 0) * 100).round();

      sb.write('---\n');
      sb.write('🔴 **$nom** ($probabilite%)\n\n');
      sb.write(_getSolutionPourMaladie(nom));
      sb.write('\n\n');
    }

    sb.write('---\n');
    sb.write('⚠️ **Conseil général :**\n');
    sb.write('Consultez un agronome local pour un diagnostic de terrain '
        'et des traitements adaptés à votre région.\n\n');
    sb.write(
        '📸 Voulez-vous analyser une autre feuille de maïs ?');

    return sb.toString();
  }

  // ── Solutions par maladie connue ──────────────────────────
  String _getSolutionPourMaladie(String nomMaladie) {
    final nom = nomMaladie.toLowerCase();

    if (nom.contains('rust') || nom.contains('rouille') ||
        nom.contains('puccinia')) {
      return '**Traitement rouille :**\n'
          '• Fongicide : propiconazole ou azoxystrobine\n'
          '• Appliquer dès les premiers symptômes\n'
          '• Éviter l\'arrosage foliaire le soir\n'
          '• Choisir des variétés résistantes pour la prochaine saison';
    }

    if (nom.contains('blight') || nom.contains('helminthosporium') ||
        nom.contains('exserohilum') || nom.contains('tache')) {
      return '**Traitement brûlure/taches foliaires :**\n'
          '• Fongicide : mancozèbe ou chlorothalonil\n'
          '• Rotation des cultures (éviter maïs consécutif)\n'
          '• Éliminer les résidus de récolte infectés\n'
          '• Améliorer la circulation d\'air entre les rangs';
    }

    if (nom.contains('smut') || nom.contains('charbon') ||
        nom.contains('ustilago')) {
      return '**Traitement charbon :**\n'
          '• Pas de traitement curatif efficace\n'
          '• Arracher et brûler les plants touchés\n'
          '• Traitement des semences avant plantation\n'
          '• Rotation des cultures sur 2-3 ans\n'
          '• Variétés résistantes recommandées';
    }

    if (nom.contains('fusarium') || nom.contains('pourriture') ||
        nom.contains('rot')) {
      return '**Traitement pourriture (Fusarium) :**\n'
          '• Améliorer le drainage du sol\n'
          '• Fongicide : thiabendazole en traitement semences\n'
          '• Éviter les blessures aux racines\n'
          '• Rotation des cultures obligatoire\n'
          '• Éliminer les plants très atteints';
    }

    if (nom.contains('anthracnose') ||
        nom.contains('colletotrichum')) {
      return '**Traitement anthracnose :**\n'
          '• Labour profond pour enfouir les résidus\n'
          '• Rotation des cultures (2 ans minimum)\n'
          '• Fertilisation équilibrée (éviter excès d\'azote)\n'
          '• Fongicides peu efficaces : privilégier la prévention';
    }

    if (nom.contains('healthy') || nom.contains('sain')) {
      return '✅ **Plant en bonne santé !**\n'
          'Continuez vos bonnes pratiques culturales.';
    }

    // Solution générique
    return '**Recommandations générales :**\n'
        '• Consultez un agronome pour identifier précisément cette maladie\n'
        '• Isolez les plants touchés pour éviter la propagation\n'
        '• Appliquez un fongicide à large spectre en traitement préventif\n'
        '• Améliorez les conditions de culture (drainage, aération)';
  }

  // ── Nouvelle discussion ────────────────────────────────────
  void _nouvelleDiscussion() {
    setState(() {
      _messages.clear();
      _conversationId = null;
      _dernierResultatAnalyse = null;
    });
  }

  // ── Ajouter une image ──────────────────────────────────────
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
          'Agriscan AI 🌽',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: Colors.white),
            tooltip: 'Nouvelle analyse',
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
              itemCount:
              _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length) {
                  return _buildTypingIndicator(bubbleBgColor);
                }
                return _buildMessage(
                    _messages[i], bubbleBgColor, textColor);
              },
            ),
          ),
          _buildInputBar(inputBgColor, darkMode),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌽', style: TextStyle(fontSize: 64)),
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
            'Spécialisé dans l\'analyse\ndes maladies du maïs',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CD964).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4CD964).withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              '📸 Photographiez une feuille de maïs\npour détecter les maladies et risques',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4CD964),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message,
      Color bubbleBgColor, Color textColor) {
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
              child: Text('🌽',
                  style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: isImage
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
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

  Widget _buildImageBubble(Map<String, dynamic> message) {
    final imagePath = message['imagePath'] as String?;
    final imageUrl = message['imageUrl'] as String?;

    Widget imageWidget;
    if (imagePath != null) {
      imageWidget = Image.file(File(imagePath),
          width: 220, height: 220, fit: BoxFit.cover);
    } else if (imageUrl != null) {
      imageWidget = Image.network(imageUrl,
          width: 220, height: 220, fit: BoxFit.cover);
    } else {
      imageWidget =
      const Icon(Icons.image, size: 80, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  Widget _buildTypingIndicator(Color bubbleBgColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF4CD964),
            child: Text('🌽', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
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

  Widget _buildInputBar(Color inputBgColor, bool darkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inputBgColor,
        border: Border(
            top: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined,
                color: Color(0xFF4CD964)),
            tooltip: 'Prendre une photo',
            onPressed: () => _ajouterImage(ImageSource.camera),
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined,
                color: Color(0xFF4CD964)),
            tooltip: 'Importer une image',
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
                fillColor: darkMode
                    ? const Color(0xFF3A3A3A)
                    : Colors.grey[300],
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
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
        duration: const Duration(milliseconds: 600));
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