# Module 07 — `pages/forgot_password_page.dart` & `pages/reset_password_page.dart`

Ces deux pages fonctionnent ensemble pour le processus "mot de passe oublié" : d'abord on demande un code par email, puis on utilise ce code pour définir un nouveau mot de passe.

---

## Partie 1 — `forgot_password_page.dart`

### À quoi sert cette page ?

L'utilisateur saisit son email. Le backend génère un code à 6 chiffres et l'envoie par email (voir la doc backend sur Brevo). On passe ensuite à la page suivante.

### La validation de l'email

```dart
validator: (v) {
  if (v == null || v.isEmpty) {
    return 'Email obligatoire';
  }
  if (!EmailValidator.validate(v)) {
    return 'Email invalide';
  }
  return null;
},
```

⚠️ **Point d'attention pédagogique** : ce `validator` doit impérativement être placé **à l'intérieur** des paramètres du `TextFormField`, pas en dehors comme du code flottant dans la classe — sinon Dart ne sait pas à quoi il se rapporte et l'application ne compile pas.

### Demander le code

```dart
Future<void> envoyerCode() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => loading = true);

  try {
    final response = await http.post(
      Uri.parse(ApiConfig.forgotPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text.trim()}),
    );
```

On envoie uniquement l'email au backend. C'est lui qui se charge de générer le code et de l'envoyer par email.

### Passer à la page suivante avec l'email

```dart
if (response.statusCode == 200) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ResetPasswordPage(email: emailController.text.trim()),
    ),
  );
}
```

On transmet l'email saisi à la page suivante, pour pouvoir l'afficher ("Code envoyé à xxx@email.com") et le réutiliser si besoin.

---

## Partie 2 — `reset_password_page.dart`

### À quoi sert cette page ?

L'utilisateur entre le code reçu par email, choisit un nouveau mot de passe, et le confirme.

### Recevoir l'email depuis la page précédente

```dart
class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});
```

- `required this.email` signifie que cette page **ne peut pas** être ouverte sans qu'on lui fournisse un email — c'est obligatoire.
- On l'utilise ensuite uniquement pour l'affichage : `Text("Code envoyé à ${widget.email}")`.

### Valider que les deux mots de passe correspondent

```dart
_inputField(
  controller: confirmPasswordController,
  obscureText: true,
  validator: (v) => v != newPasswordController.text
      ? "Les mots de passe ne correspondent pas"
      : null,
),
```

On compare la valeur du champ "confirmer" avec celle du champ "nouveau mot de passe". S'ils sont différents, on bloque la validation.

### Envoyer le code + le nouveau mot de passe

```dart
Future<void> reinitialiser() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => loading = true);

  try {
    final response = await http.post(
      Uri.parse(ApiConfig.resetPassword),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': codeController.text.trim(),
        'newPassword': newPasswordController.text.trim(),
      }),
    );
```

Remarque : le champ s'appelle `token` côté backend, mais à l'écran on l'appelle "code" — c'est le même code à 6 chiffres reçu par email.

### Retour automatique vers le login

```dart
if (response.statusCode == 200) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Mot de passe réinitialisé avec succès ✓")),
  );
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}
```

- `pushAndRemoveUntil` avec `(route) => false` veut dire : "va à la page de login et **supprime tout l'historique de navigation derrière**".
- Concrètement, l'utilisateur ne peut plus appuyer sur "retour" pour revenir aux pages de réinitialisation — c'est voulu, le processus est terminé.

---

## Le flux complet, résumé

```
ForgotPasswordPage (saisie email)
        │ POST /forgot-password
        ▼
   Backend génère un code à 6 chiffres
   et l'envoie par email (Brevo)
        │
        ▼
ResetPasswordPage (saisie code + nouveau mdp)
        │ POST /reset-password
        ▼
   Backend vérifie le code et change le mot de passe
        │
        ▼
   Retour automatique vers LoginPage
```

## Lexique

| Terme | Explication |
|---|---|
| `required` | Mot-clé indiquant qu'un paramètre est obligatoire |
| `pushAndRemoveUntil` | Navigue vers une page en effaçant tout ou partie de l'historique de navigation |
| Code de réinitialisation (token) | Code temporaire à usage unique, généré côté serveur, prouvant que la demande de réinitialisation vient bien du propriétaire de l'email |
