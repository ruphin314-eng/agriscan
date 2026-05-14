import 'package:agriscan/pages/home_pages.dart';
import 'package:agriscan/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'profile.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController profilController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<void> register() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => loading = true);

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text.trim(),
        'telephone': phoneController.text.trim(),
        'profil': profilController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Sauvegarder la session
      await AuthStorage.save(data['id'], data['token']);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${response.body}")),
      );
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Impossible de joindre le serveur")),
    );
  } finally {
    if (mounted) setState(() => loading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CD964)),
      )
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Text('Sign up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 36),
                _label('Nom'),
                const SizedBox(height: 8),
                _inputField(
                  controller: nameController,
                  validator: (v) =>
                  v!.isEmpty ? "Nom obligatoire" : null,
                ),
                const SizedBox(height: 16),
                _label('Numero'),
                const SizedBox(height: 8),
                _inputField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v!.isEmpty) return "Numéro obligatoire";
                    if (!RegExp(r'^[0-9]{8,15}$').hasMatch(v)) {
                      return "Numéro invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _label('Profil'),
                const SizedBox(height: 8),
                _inputField(
                  controller: profilController,
                  validator: (v) =>
                  v!.isEmpty ? "Profil obligatoire" : null,
                ),
                const SizedBox(height: 16),
                _label('Address mail'),
                const SizedBox(height: 8),
                _inputField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !EmailValidator.validate(v!)
                      ? "Email invalide"
                      : null,
                ),
                const SizedBox(height: 16),
                _label('Mot de passe'),
                const SizedBox(height: 8),
                _inputField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (v) =>
                  v!.length < 6 ? "6 caractères minimum" : null,
                ),
                const SizedBox(height: 32),
                _greenButton('Sign up', onPressed: register),
                const SizedBox(height: 36),
                _orDivider(),
                const SizedBox(height: 20),
                const Center(
                  child: Text('Sign up with',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                _socialButtons(),
                const SizedBox(height: 60),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                                color: Color(0xFF4CD964),
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400));

  Widget _inputField({
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white54, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5)),
        errorStyle: const TextStyle(color: Colors.redAccent),
        filled: true,
        fillColor: Colors.transparent,
      ),
    );
  }

  Widget _greenButton(String label, {required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D8B3A), Color(0xFF4CD964)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(children: [
      Expanded(child: Container(height: 1, color: Colors.white24)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Or',
            style: TextStyle(color: Colors.white60, fontSize: 14)),
      ),
      Expanded(child: Container(height: 1, color: Colors.white24)),
    ]);
  }

  Widget _socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
        );
      }),
    );
  }
}