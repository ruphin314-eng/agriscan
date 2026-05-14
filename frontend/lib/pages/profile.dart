import 'package:agriscan/pages/home_pages.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'package:agriscan/pages/histor_page.dart';


class ProfilePage extends StatefulWidget {
  final int userId;
  final String token;

  const ProfilePage({super.key, required this.userId, required this.token});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool darkMode = false;
  Map<String, dynamic>? userData;
  bool loading = true;
  String? error;
  int _currentIndex = 2; // Profil = index 2

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
  
void logout() async {
  await AuthStorage.clear();
  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomePage()), 
    (route) => false,
  );
}

  // ── Dialog changement de mot de passe ─────────────────────
  void showChangePasswordDialog() {
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
                  validator: (v) =>
                      v!.isEmpty ? "Champ obligatoire" : null,
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
                  label: "Confirmer le mot de passe",
                  obscure: true,
                  darkMode: darkMode,
                  validator: (v) => v != newPasswordController.text
                      ? "Les mots de passe ne correspondent pas"
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler",
                  style: TextStyle(color: Colors.grey)),
            ),
            dialogLoading
                ? const CircularProgressIndicator(
                    color: Color(0xFF4CD964))
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
                              content:
                                  Text("Impossible de joindre le serveur")),
                        );
                      }
                    },
                    child: const Text("Confirmer",
                        style: TextStyle(color: Colors.white)),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Navigation navbar ──────────────────────────────────────
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
    // index == 2 → on est déjà sur ProfilePage
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF4CD964))),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child:
                Text(error!, style: const TextStyle(color: Colors.redAccent))),
      );
    }

    return Scaffold(
      backgroundColor: darkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CD964),
        title: const Text("Profil",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),

      // ── Navbar ─────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 14, 15, 14),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        onTap: onNavTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Historique'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + nom ─────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF4CD964),
                    child: Text(
                      userData!['name'][0].toUpperCase(),
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(userData!['name'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkMode ? Colors.white : Colors.black)),
                  Text(userData!['profil'],
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Infos ─────────────────────────────────────────
            _infoTile(Icons.email, "Email", userData!['email']),
            _infoTile(Icons.phone, "Téléphone", userData!['telephone']),

            const SizedBox(height: 24),
            const Divider(),

            // ── Paramètres ────────────────────────────────────
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text("Mode sombre",
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black)),
              value: darkMode,
              activeColor: const Color(0xFF4CD964),
              onChanged: (_) => setState(() => darkMode = !darkMode),
            ),

            ListTile(
              leading: const Icon(Icons.lock_reset,
                  color: Color(0xFF4CD964)),
              title: Text("Changer de mot de passe",
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black)),
              onTap: showChangePasswordDialog, // ← dialog
            ),

            ListTile(
              leading: const Icon(Icons.info_outline,
                  color: Color(0xFF4CD964)),
              title: Text("À propos",
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black)),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: "Agriscan",
                applicationVersion: "1.0.0",
                children: const [
                  Text("Application de diagnostic agricole.")
                ],
              ),
            ),

            ListTile(
              leading:
                  const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Déconnexion",
                  style: TextStyle(color: Colors.redAccent)),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }

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
      style:
          TextStyle(color: darkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Colors.grey, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: Color(0xFF4CD964), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Colors.redAccent, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: Colors.redAccent, width: 1.5)),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CD964), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}