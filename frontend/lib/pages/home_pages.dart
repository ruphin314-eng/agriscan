import 'package:agriscan/pages/chat_page.dart';
import 'package:agriscan/pages/histor_page.dart';
import 'package:agriscan/pages/login_page.dart';
import 'package:agriscan/pages/profile.dart';
import 'package:agriscan/pages/stock_maladie.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.darkMode;

    return Scaffold(
      // ── Navbar ───────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: darkMode
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 14, 15, 14),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        onTap: (index) async {
          if (index == 1) {
            // ── Historique ──────────────────────────────────
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
          } else if (index == 2) {
            // ── Compte ──────────────────────────────────────
            final isLoggedIn = await AuthStorage.isLoggedIn();
            if (!context.mounted) return;

            if (isLoggedIn) {
              final userId = await AuthStorage.getUserId();
              final token = await AuthStorage.getToken();
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(userId: userId!, token: token!),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historique',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),

      // ── Contenu ──────────────────────────────────────────────
      body: _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  Future<void> _handleImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;
    if (!context.mounted) return;

    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!context.mounted) return;

    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(imagePath: image.path)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(redirectImagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Détection Intelligentes\nDes Maladies Des Cultures",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Analyser Et Diagnostiquez Vos Plantes\nA Partir D'une Photo",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _actionButton(
                context: context,
                icon: Icons.camera_alt_outlined,
                text: "Prendre Une Photo",
                color: Colors.white70,
                onTap: () => _handleImage(context, ImageSource.camera),
              ),
              const SizedBox(height: 15),
              _actionButton(
                context: context,
                icon: Icons.file_upload_outlined,
                text: "Ou Importer Une Image",
                color: Colors.white70,
                onTap: () => _handleImage(context, ImageSource.gallery),
              ),
              const SizedBox(height: 15),
              _actionButton(
                context: context,
                icon: Icons.storage_rounded,
                text:
                    "Consulter Nos Stocks Des Plantes,\nMaladies Et Solutions Possibles",
                color: Colors.white60,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StockPlante()),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    IconData? icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.black),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
