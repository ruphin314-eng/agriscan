import 'package:agriscan/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _messages.add({
        'role': 'user',
        'type': 'image',
        'imagePath': widget.imagePath,
      });
      _analyserImage();
    }
  }

  Future<void> _analyserImage() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _messages.add({
        'role': 'assistant',
        'type': 'text',
        'content':
            'J\'analyse votre image... 🌿\n\nJe détecte une possible maladie fongique sur votre plante. Voici mes recommandations :\n\n• Traitement fongicide recommandé\n• Éviter l\'arrosage excessif\n• Isoler la plante des autres cultures',
      });
      _isLoading = false;
    });
    _scrollToBottom();
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

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    setState(() {
      _messages.add({'role': 'user', 'type': 'text', 'content': text});
      _isLoading = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _messages.add({
        'role': 'assistant',
        'type': 'text',
        'content': 'Je traite votre question : "$text"\n\nVoici ma réponse...',
      });
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _nouvelleDiscussion() => setState(() => _messages.clear());

  Future<void> _ajouterImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;
    setState(() {
      _messages.add({'role': 'user', 'type': 'image', 'imagePath': image.path});
    });
    _scrollToBottom();
    _analyserImage();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Provider.of<ThemeProvider>(context).darkMode;
    final bgColor = darkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF5F5F5);
    final inputBgColor = darkMode ? const Color(0xFF2A2A2A) : Colors.grey[200]!;
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
          "Agriscan AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment, color: Colors.white),
            tooltip: "Nouvelle discussion",
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
          _buildInputBar(inputBgColor),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 64, color: Color(0xFF4CD964)),
          const SizedBox(height: 16),
          Text(
            "Agriscan AI",
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Prenez ou importez une photo\npour analyser vos plantes",
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14),
          ),
        ],
      ),
    );
  }

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
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
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
                    ? const Color(0xFF4CD964).withOpacity(0.2)
                    : bubbleBgColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(message['imagePath']),
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      message['content'],
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildInputBar(Color inputBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: inputBgColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFF4CD964),
            ),
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
                color: Provider.of<ThemeProvider>(context).darkMode
                    ? Colors.white
                    : Colors.black87,
              ),
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Posez votre question...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Provider.of<ThemeProvider>(context).darkMode
                    ? const Color(0xFF3A3A3A)
                    : Colors.grey[300],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
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
