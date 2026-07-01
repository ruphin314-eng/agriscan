import 'package:agriscan/pages/main_page.dart';
import 'package:agriscan/pages/login_page.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:agriscan/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final int userId;
  final String token;

  const ProfilePage({super.key, required this.userId, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool loading = true;
  String? error;
  int _currentIndex = 2;

  // ✅ Photo locale en attente d'upload (affichée immédiatement)
  File? _photoLocale;

  // ✅ URL de la photo stockée sur le serveur
  String? _photoUrl;

  bool _uploadingPhoto = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    fetchProfil();
    _loadPhotoLocale();
  }

  // ── Charger la photo locale sauvegardée ────────────────────
  Future<void> _loadPhotoLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('photo_locale_${widget.userId}');
    if (path != null && File(path).existsSync()) {
      setState(() => _photoLocale = File(path));
    }
  }

  // ── Charger le profil depuis le backend ────────────────────
  Future<void> fetchProfil() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        setState(() {
          error = 'session_expiree';
          loading = false;
        });
        return;
      }

      final response = await http
          .get(
        Uri.parse(ApiConfig.client(widget.userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data;
          // ✅ Récupérer photoUrl depuis le backend
          _photoUrl = data['photoUrl'] as String?;
          loading = false;
          _retryCount = 0;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await AuthStorage.clear();
        setState(() {
          error = 'session_expiree';
          loading = false;
        });
      } else {
        setState(() {
          error = 'erreur_serveur';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'timeout';
        loading = false;
      });
    }
  }

  // ── Changer la photo : sélection + upload ─────────────────
  Future<void> changerPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    final file = File(image.path);

    // Afficher immédiatement la photo localement
    setState(() {
      _photoLocale = file;
      _uploadingPhoto = true;
    });

    // Sauvegarder localement
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photo_locale_${widget.userId}', image.path);

    // ── Uploader vers le backend ──────────────────────────
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        setState(() => _uploadingPhoto = false);
        return;
      }

      // Détecter le type MIME
      final extension = image.path.split('.').last.toLowerCase();
      final mimeType = extension == 'png' ? 'png' : 'jpeg';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadPhoto(widget.userId)),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', mimeType),
        ),
      );

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _photoUrl = data['photoUrl'] as String?;
          _uploadingPhoto = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo mise à jour ✓'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _uploadingPhoto = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur upload : ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _uploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'uploader la photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void logout() async {
    // ✅ Dialogue de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text(
              'Déconnexion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );

    // Si l'utilisateur a annulé, on ne fait rien
    if (confirmed != true) return;

    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
    );
  }

  void onNavTap(int index) {
    if (index == _currentIndex) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainPage(initialIndex: index)),
          (route) => false,
    );
  }

  void showChangePasswordDialog(bool darkMode) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool dialogLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
          title: Text(
            'Changer le mot de passe',
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: oldPasswordController,
                  label: 'Ancien mot de passe',
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: newPasswordController,
                  label: 'Nouveau mot de passe',
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) =>
                  v!.length < 6 ? '6 caractères minimum' : null,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: confirmPasswordController,
                  label: 'Confirmer',
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) => v != newPasswordController.text
                      ? 'Ne correspond pas'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
              const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            dialogLoading
                ? const CircularProgressIndicator(color: Color(0xFF4CD964))
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD964)),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => dialogLoading = true);
                try {
                  final token = await AuthStorage.getToken();
                  final response = await http.put(
                    Uri.parse(ApiConfig.changePassword),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'oldPassword': oldPasswordController.text,
                      'newPassword': newPasswordController.text,
                    }),
                  );
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        response.statusCode == 200
                            ? 'Mot de passe modifié ✓'
                            : 'Erreur : ${response.body}',
                      ),
                      backgroundColor: response.statusCode == 200
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                        Text('Impossible de joindre le serveur')),
                  );
                }
              },
              child: const Text('Confirmer',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar : priorité photo locale > photo serveur > initiale ──
  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_photoLocale != null) {
      imageProvider = FileImage(_photoLocale!);
    } else if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl!);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Text(
            userData!['name'][0].toUpperCase(),
            style: const TextStyle(
              fontSize: 40,
              color: Color(0xFF4CD964),
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        // ✅ Indicateur d'upload en cours
        if (_uploadingPhoto)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt,
                size: 16, color: Color(0xFF4CD964)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.darkMode;
    final textColor = darkMode ? Colors.white : Colors.black87;

    if (loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4CD964)),
              const SizedBox(height: 20),
              const Text('Chargement du profil...',
                  style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 8),
              Text(
                _retryCount > 0
                    ? 'Tentative $_retryCount...'
                    : 'Connexion au serveur...',
                style: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor:
        darkMode ? const Color(0xFF121212) : Colors.grey[100],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  error == 'session_expiree'
                      ? Icons.lock_outline
                      : Icons.wifi_off,
                  color: error == 'session_expiree'
                      ? Colors.orange
                      : Colors.grey,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  error == 'session_expiree'
                      ? 'Session expirée\nReconnectez-vous'
                      : 'Serveur en démarrage...\nVeuillez patienter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkMode ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                if (error == 'session_expiree')
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CD964),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text('Se reconnecter',
                        style: TextStyle(color: Colors.white)),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      _retryCount++;
                      fetchProfil();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CD964),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Réessayer',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  _AutoRetryWidget(onRetry: () {
                    _retryCount++;
                    fetchProfil();
                  }),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      darkMode ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CD964),
        title: const Text('Mon Profil',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              darkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: darkMode
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 14, 15, 14),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        onTap: onNavTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Historique'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 32, bottom: 24, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF4CD964),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _uploadingPhoto ? null : changerPhoto,
                    child: _buildAvatar(),
                  ),
                  const SizedBox(height: 12),
                  Text(userData!['name'],
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(userData!['profil'] ?? '',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  if (userData!['dateInscription'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Membre depuis ${userData!['dateInscription']}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Infos ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(Icons.email, 'Email',
                      userData!['email'] ?? '', textColor, darkMode),
                  const SizedBox(height: 12),
                  _infoCard(Icons.phone, 'Téléphone',
                      userData!['telephone'] ?? '', textColor, darkMode),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Paramètres ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: darkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _settingsTile(
                      icon: Icons.lock_reset,
                      label: 'Changer de mot de passe',
                      color: const Color(0xFF4CD964),
                      textColor: textColor,
                      onTap: () => showChangePasswordDialog(darkMode),
                    ),
                    _divider(darkMode),
                    _settingsTile(
                      icon: Icons.info_outline,
                      label: 'À propos',
                      color: const Color(0xFF4CD964),
                      textColor: textColor,
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Agriscan',
                        applicationVersion: '1.0.0',
                        children: const [
                          Text('Application de diagnostic agricole.')
                        ],
                      ),
                    ),
                    _divider(darkMode),
                    _settingsTile(
                      icon: Icons.logout,
                      label: 'Déconnexion',
                      color: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: logout,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value,
      Color textColor, bool darkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CD964).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4CD964), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing:
      Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: onTap,
    );
  }

  Widget _divider(bool darkMode) => Divider(
      height: 1,
      color: darkMode ? Colors.grey[800] : Colors.grey[200]);

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required bool darkMode,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: Color(0xFF4CD964), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5)),
      ),
    );
  }
}

// ── Widget retry automatique ──────────────────────────────────
class _AutoRetryWidget extends StatefulWidget {
  final VoidCallback onRetry;
  const _AutoRetryWidget({required this.onRetry});

  @override
  State<_AutoRetryWidget> createState() => _AutoRetryWidgetState();
}

class _AutoRetryWidgetState extends State<_AutoRetryWidget> {
  int _seconds = 10;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 10; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _seconds = i - 1);
    }
    if (mounted) widget.onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _seconds > 0
          ? 'Nouvelle tentative dans $_seconds s...'
          : 'Reconnexion en cours...',
      style: const TextStyle(color: Colors.grey, fontSize: 13),
    );
  }
}