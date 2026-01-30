import 'package:flutter/material.dart';
import 'login_page.dart';

class UtilisateurPage extends StatelessWidget {
  const UtilisateurPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: const Color.fromARGB(50, 0, 0, 0),
        child: LoginPage(), // ← plus de const ici
      ),
    );
  }
}
