import 'package:agriscan/pages/home_pages.dart';
import 'package:agriscan/pages/histor_page.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
// ignore: unused_import
import 'login_page.dart';

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
  File? _photoLocale;

  static const String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/clients/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          error = "Erreur de chargement du profil";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Impossible de joindre le serveur";
        loading = false;
      });
    }
  }

  Future<void> changerPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;
    setState(() => _photoLocale = File(image.path));
  }

  void logout() async {
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
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
            "Changer le mot de passe",
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
                  label: "Ancien mot de passe",
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) => v!.isEmpty ? "Champ obligatoire" : null,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: newPasswordController,
                  label: "Nouveau mot de passe",
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) =>
                      v!.length < 6 ? "6 caractères minimum" : null,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: confirmPasswordController,
                  label: "Confirmer",
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) => v != newPasswordController.text
                      ? "Ne correspond pas"
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            dialogLoading
                ? const CircularProgressIndicator(color: Color(0xFF4CD964))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CD964),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => dialogLoading = true);
                      try {
                        final response = await http.put(
                          Uri.parse('$baseUrl/api/auth/change-password'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${widget.token}',
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
                                  ? "Mot de passe modifié ✓"
                                  : "Erreur : ${response.body}",
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
                            content: Text("Impossible de joindre le serveur"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Confirmer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HistoryPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Thème global via Provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.darkMode;
    final textColor = darkMode ? Colors.white : Colors.black87;

    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CD964)),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: darkMode ? const Color(0xFF121212) : Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(
                  color: darkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loading = true;
                    error = null;
                  });
                  fetchProfil();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CD964),
                ),
                child: const Text(
                  "Réessayer",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CD964),
        title: const Text(
          "Mon Profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // ✅ Toggle thème global
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historique',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 32,
                bottom: 24,
                left: 16,
                right: 16,
              ),
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
                    onTap: changerPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _photoLocale != null
                              ? FileImage(_photoLocale!)
                              : null,
                          child: _photoLocale == null
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Color(0xFF4CD964),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userData!['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData!['profil'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (userData!['dateInscription'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Membre depuis ${userData!['dateInscription']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Infos ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _infoCard(
                    Icons.email,
                    "Email",
                    userData!['email'],
                    textColor,
                    darkMode,
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    Icons.phone,
                    "Téléphone",
                    userData!['telephone'],
                    textColor,
                    darkMode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Paramètres ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: darkMode ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _settingsTile(
                      icon: Icons.lock_reset,
                      label: "Changer de mot de passe",
                      color: const Color(0xFF4CD964),
                      textColor: textColor,
                      onTap: () => showChangePasswordDialog(darkMode),
                    ),
                    _divider(darkMode),
                    _settingsTile(
                      icon: Icons.info_outline,
                      label: "À propos",
                      color: const Color(0xFF4CD964),
                      textColor: textColor,
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: "Agriscan",
                        applicationVersion: "1.0.0",
                        children: const [
                          Text("Application de diagnostic agricole."),
                        ],
                      ),
                    ),
                    _divider(darkMode),
                    _settingsTile(
                      icon: Icons.logout,
                      label: "Déconnexion",
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

  Widget _infoCard(
    IconData icon,
    String label,
    String value,
    Color textColor,
    bool darkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: const Color(0xFF4CD964).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4CD964), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: onTap,
    );
  }

  Widget _divider(bool darkMode) =>
      Divider(height: 1, color: darkMode ? Colors.grey[800] : Colors.grey[200]);

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
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4CD964), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
