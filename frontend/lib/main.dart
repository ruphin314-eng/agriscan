import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agriscan/pages/home_pages.dart';
import 'package:agriscan/services/theme_provider.dart';

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
      home: const HomePage(), // ✅ direct HomePage, pas de redirection
    );
  }
}
