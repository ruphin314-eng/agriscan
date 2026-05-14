import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProfilePage(
              userId: data['id'],
              token: data['token'],
            ),
          ),
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

  Future<void> resetPassword() async {
    final messenger = ScaffoldMessenger.of(context);

    if (emailController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Entrez votre email pour réinitialiser")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Email de réinitialisation envoyé")),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text("Erreur lors de la réinitialisation")),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Impossible de joindre le serveur")),
      );
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
                    const Text('Sign in',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                _label('Enter email'),
                const SizedBox(height: 8),
                _inputField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                  (v == null || v.isEmpty) ? "Email obligatoire" : null,
                ),
                const SizedBox(height: 20),
                _label('Enter Password'),
                const SizedBox(height: 8),
                _inputField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty)
                      ? "Mot de passe obligatoire"
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resetPassword,
                    child: const Text('Mot de passe oublié ?',
                        style: TextStyle(
                            color: Color(0xFF4CD964), fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 16),
                _greenButton('Sign in', onPressed: login),
                const SizedBox(height: 36),
                _orDivider(),
                const SizedBox(height: 20),
                const Center(
                  child: Text('Sign in with',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                _socialButtons(),
                const SizedBox(height: 80),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterPage()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Sign up',
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
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4CD964),
          textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        child: Text(label),
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