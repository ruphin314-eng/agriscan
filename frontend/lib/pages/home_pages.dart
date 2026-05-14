import 'package:agriscan/pages/chat_page.dart';
import 'package:agriscan/pages/login_page.dart';
import 'package:agriscan/pages/profile.dart';
import 'package:agriscan/pages/stock_maladie.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // ── Gérer la photo/galerie avec vérif connexion ────────────
  Future<void> handleImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;
    if (!mounted) return;

    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      // ✅ Connecté → aller direct sur ChatPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(imagePath: image.path)),
      );
    } else {
      // ❌ Pas connecté → LoginPage puis ChatPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(redirectImagePath: image.path),
        ),
      );
    }
  }

  // ── Navbar ─────────────────────────────────────────────────
  void onNavTap(int index) async {
    if (index == _currentIndex) return;

    if (index == 0) {
      setState(() => _currentIndex = 0);
    } else if (index == 1) {
      setState(() => _currentIndex = 1);
    } else if (index == 2) {
      // Compte → vérifier si connecté
      final isLoggedIn = await AuthStorage.isLoggedIn();
      if (!mounted) return;

      if (isLoggedIn) {
        final userId = await AuthStorage.getUserId();
        final token = await AuthStorage.getToken();
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(userId: userId!, token: token!),
          ),
        ).then((_) => setState(() => _currentIndex = 0));
      } else {
        // Pas connecté → LoginPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        ).then((_) => setState(() => _currentIndex = 0));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 1 ? const HistoryContent() : _buildHomeContent(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 14, 15, 14),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
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
    );
  }

  Widget _buildHomeContent() {
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
                icon: Icons.camera_alt_outlined,
                text: "Prendre Une Photo",
                color: Colors.white70,
                onTap: () => handleImage(ImageSource.camera),
              ),
              const SizedBox(height: 15),
              _actionButton(
                icon: Icons.file_upload_outlined,
                text: "Ou Importer Une Image",
                color: Colors.white70,
                onTap: () => handleImage(ImageSource.gallery),
              ),
              const SizedBox(height: 15),
              _actionButton(
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

// ── Contenu Historique intégré ─────────────────────────────────
class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              "Aucun historique pour l'instant",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Vos analyses apparaîtront ici",
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
