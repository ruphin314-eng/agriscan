import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:agriscan/pages/main_page.dart';
import 'package:agriscan/pages/onboarding_page.dart';
import 'package:agriscan/services/theme_provider.dart';
import 'package:agriscan/services/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const AgriscanApp(),
    ),
  );
}

class AgriscanApp extends StatelessWidget {
  const AgriscanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Agriscan',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.theme,
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _wakeUpBackend();
    _redirect();
  }

  // ── Réveiller Render avant que l'utilisateur agisse ───────
  Future<void> _wakeUpBackend() async {
    try {
      await http
          .get(Uri.parse(ApiConfig.health))
          .timeout(const Duration(seconds: 60));
      debugPrint('✅ Backend réveillé');
    } catch (e) {
      debugPrint('⚠️ Wake-up: $e');
    }
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ──────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✅ withValues à la place de withOpacity
                color: const Color(0xFF4CD964).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFF4CD964).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: Color(0xFF4CD964),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Agriscan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Diagnostic agricole intelligent',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(color: Color(0xFF4CD964)),
          ],
        ),
      ),
    );
  }
}