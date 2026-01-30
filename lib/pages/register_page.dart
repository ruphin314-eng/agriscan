import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'profile.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // Création utilisateur Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Stockage info utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
          });

      // Envoi de mail de notification (Firebase Auth envoie un mail de confirmation)
      await userCredential.user!.sendEmailVerification();

      // Navigation vers profil
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfilePage(userId: userCredential.user!.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.message}")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("S'enregistrer")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Nom"),
                      validator: (value) =>
                          value!.isEmpty ? "Nom obligatoire" : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Numéro de téléphone",
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) return "Numéro obligatoire";
                        if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
                          return "Numéro invalide";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Adresse email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => !EmailValidator.validate(value!)
                          ? "Email invalide"
                          : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.length < 6 ? "6 caractères minimum" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: register,
                      child: const Text("S'enregistrer"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
