import 'package:agriscan/pages/histor_page.dart';
import 'package:agriscan/pages/preview_page.dart';
import 'package:agriscan/pages/stock_maladie.dart';
import 'package:agriscan/pages/utilisateur_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Liste des pages correspondant aux onglets
  final List<Widget> _pages = const [
    HomeContentPage(), // Page d'accueil avec boutons
    HistoryPage(), // Page historique
    UtilisateurPage(), // Page profil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page active

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color.fromARGB(255, 14, 15, 14),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historique',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Widget séparé pour le contenu de la page d'accueil
class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

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

              // TITRE
              const Text(
                "Détection Intelligentes\nDes Maladies Des Cultures",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              // SOUS-TITRE
              const Text(
                "Analyser Et Diagnostiquez Vos Plantes\nA Partir D’une Photo",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600 , color: Colors.black87),
              ),

              const Spacer(),

              // BOUTONS
              _actionButton(
                icon: Icons.camera_alt_outlined,
                text: "Prendre Une Photo",
                color: Colors.white70,
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (image == null) return;

                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewPage(imagePath: image.path),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              _actionButton(
                icon: Icons.file_upload_outlined,
                text: "Ou Importer Une Image",
                color: Colors.white70,
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image == null) return;

                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewPage(imagePath: image.path),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              _actionButton(
                icon: Icons.storage_rounded,
                text:
                    "Consulter Nos Stocks Des Plantes,\nMaladies Et Solutions Possibles",
                color: Colors.white60,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockPlante()),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BOUTON
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
