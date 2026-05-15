import 'package:agriscan/pages/home_pages.dart';
import 'package:flutter/material.dart';
import 'package:agriscan/pages/profile.dart';
import 'package:agriscan/services/auth_storage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _currentIndex = 1;

  void onNavTap(int index) async {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else if (index == 2) {
      final userId = await AuthStorage.getUserId();
      final token = await AuthStorage.getToken();

      if (!mounted) return;

      if (userId != null && token != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfilePage(userId: userId, token: token),
          ),
        ).then((_) => setState(() => _currentIndex = 1));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: const Color(0xFF4CD964),
        leading: GestureDetector(
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Historique",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

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

      body: const Center(
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
