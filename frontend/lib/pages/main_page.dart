import 'package:agriscan/pages/home_pages.dart';
import 'package:agriscan/pages/histor_page.dart';
import 'package:agriscan/pages/login_page.dart';
import 'package:agriscan/pages/profile.dart';
import 'package:agriscan/pages/chat_page.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // ── Vérification connexion avant nouvelle analyse ────────
  Future<void> _handleNouvelleAnalyse() async {
    final isLoggedIn = await AuthStorage.isLoggedIn();
    if (!context.mounted) return;

    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatPage()),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      // Après connexion, recharge l'historique
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.darkMode;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeContent(),
          HistoryPage(darkMode: darkMode),
        ],
      ),

      // ── FAB nouvelle analyse sur historique ────────────────
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF4CD964),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Nouvelle analyse",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _handleNouvelleAnalyse, // ← corrigé
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: darkMode
            ? const Color(0xFF1E1E1E)
            : const Color.fromARGB(255, 14, 15, 14),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        onTap: (index) async {
          if (index == 2) {
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
              ).then((_) {
                if (mounted) setState(() => _currentIndex = 0);
              });
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ).then((_) {
                if (mounted) setState(() => _currentIndex = 0);
              });
            }
          } else {
            setState(() => _currentIndex = index);
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
    );
  }
}
