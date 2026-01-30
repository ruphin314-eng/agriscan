import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (!mounted) {
        return;
      }

      // Navigation sécurisée
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfilePage(userId: userCredential.user!.uid),
        ),
      );

      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.message}")));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final messenger = ScaffoldMessenger.of(context);

    if (emailController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Entrez votre email pour réinitialiser")),
      );
      return;
    }

    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text("Email de réinitialisation envoyé")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email obligatoire";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mot de passe obligatoire";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: login,
                      child: const Text("Se connecter"),
                    ),
                    TextButton(
                      onPressed: resetPassword,
                      child: const Text("Mot de passe oublié ?"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text("Créer un compte"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
