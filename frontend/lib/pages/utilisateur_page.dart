import 'package:flutter/material.dart';
import 'login_page.dart';

class UtilisateurPage extends StatelessWidget {
  const UtilisateurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      },
    );
  }
}
