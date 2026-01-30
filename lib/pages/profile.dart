import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool darkMode = false;

  void toggleTheme() {
    setState(() {
      darkMode = !darkMode;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) {
      return;
    }
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> resetPassword(String email) async {
    final messenger = ScaffoldMessenger.of(context);

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text("Email de réinitialisation envoyé")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(title: const Text("Profil")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nom : ${userData['name']}"),
                Text("Email : ${userData['email']}"),
                Text("Téléphone : ${userData['phone']}"),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text("Mode sombre"),
                  value: darkMode,
                  onChanged: (_) => toggleTheme(),
                ),
                ListTile(
                  title: const Text("Changer de mot de passe"),
                  onTap: () async {
                    await resetPassword(userData['email']);
                  },
                ),
                ListTile(
                  title: const Text("À propos"),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Agriscan",
                      applicationVersion: "1.0.0",
                      children: const [
                        Text("Application de diagnostic agricole."),
                      ],
                    );
                  },
                ),
                ListTile(title: const Text("Déconnexion"), onTap: logout),
              ],
            ),
          ),
        );
      },
    );
  }
}
