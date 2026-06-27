import 'package:agriscan/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _slides = [
    _OnboardingData(
      icon: Icons.camera_alt_outlined,
      color: const Color(0xFF4CD964),
      titre: 'Photographiez votre plante',
      description:
          'Prenez une photo ou importez une image de votre culture.\n'
          'Agriscan accepte toutes les plantes : maïs, manioc, banane et bien plus.',
    ),
    _OnboardingData(
      icon: Icons.biotech_outlined,
      color: const Color(0xFF2D8B3A),
      titre: 'L\'IA analyse en quelques secondes',
      description:
          'Notre intelligence artificielle détecte les maladies, '
          'les carences et les parasites avec précision.',
    ),
    _OnboardingData(
      icon: Icons.eco_outlined,
      color: const Color(0xFF4CD964),
      titre: 'Recevez les solutions adaptées',
      description:
          'Obtenez des recommandations concrètes : traitements, '
          'bonnes pratiques et conseils de prévention pour protéger vos récoltes.',
    ),
  ];

  Future<void> _terminer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  void _suivant() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _terminer();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bouton passer ──────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: _currentPage < _slides.length - 1
                    ? TextButton(
                        onPressed: _terminer,
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox(height: 40),
              ),
            ),

            // ── Slides ─────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (ctx, i) => _buildSlide(_slides[i]),
              ),
            ),

            // ── Indicateurs ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF4CD964)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Bouton suivant / commencer ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2D8B3A), Color(0xFF4CD964)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: _suivant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _slides.length - 1
                              ? 'Suivant'
                              : 'Commencer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage < _slides.length - 1
                              ? Icons.arrow_forward
                              : Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icône animée ──────────────────────────────────
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.color.withValues(alpha: 0.1),
              border: Border.all(
                color: slide.color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              slide.icon,
              size: 72,
              color: slide.color,
            ),
          ),

          const SizedBox(height: 48),

          // ── Titre ─────────────────────────────────────────
          Text(
            slide.titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 20),

          // ── Description ───────────────────────────────────
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modèle de données d'un slide ─────────────────────────────
class _OnboardingData {
  final IconData icon;
  final Color color;
  final String titre;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.titre,
    required this.description,
  });
}
