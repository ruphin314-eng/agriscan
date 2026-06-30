# Module 06 — `pages/register_page.dart`

## À quoi sert cette page ?

C'est la page d'inscription. L'utilisateur remplit un formulaire (nom, téléphone, profil, email, mot de passe) pour créer un compte.

## Les champs du formulaire

```dart
final TextEditingController nameController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController profilController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
```

Chaque champ de texte a son propre `TextEditingController`. C'est l'objet qui "garde en mémoire" ce que l'utilisateur tape dans chaque case. On y accède ensuite avec `.text` (ex: `nameController.text`).

## Les règles de validation

### Le nom

```dart
validator: (v) => v!.isEmpty ? "Nom obligatoire" : null,
```

- `validator` est une fonction appelée automatiquement quand on essaie de soumettre le formulaire.
- Elle reçoit la valeur tapée (`v`), et retourne soit un message d'erreur (texte), soit `null` si tout va bien.
- `v!` signifie "je suis sûr que `v` n'est pas vide" (le `!` retire l'incertitude `String?` → `String`).

### Le téléphone (avec une expression régulière)

```dart
validator: (v) {
  if (v!.isEmpty) return "Numéro obligatoire";
  if (!RegExp(r'^[0-9]{8,15}$').hasMatch(v)) {
    return "Numéro invalide";
  }
  return null;
},
```

- Une **expression régulière** (regex) est un motif qui décrit le format attendu d'un texte.
- `^[0-9]{8,15}$` veut dire : "uniquement des chiffres, entre 8 et 15 caractères, du début à la fin".
- Si le numéro ne respecte pas ce motif, on affiche "Numéro invalide".

### L'email (avec un package spécialisé)

```dart
validator: (v) => !EmailValidator.validate(v!)
    ? "Email invalide"
    : null,
```

Plutôt que d'écrire sa propre regex pour valider un email (ce qui est complexe et source d'erreurs), on utilise le package `email_validator` qui fait ce travail de façon fiable.

### Le mot de passe

```dart
validator: (v) => v!.length < 6 ? "6 caractères minimum" : null,
```

Règle simple : au moins 6 caractères.

## L'inscription elle-même

```dart
Future<void> register() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => loading = true);

  try {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text.trim(),
        'telephone': phoneController.text.trim(),
        'profil': profilController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );
```

Même logique que pour le login (module 05) : on vérifie d'abord que le formulaire est valide, puis on envoie toutes les informations au serveur en `POST`.

## Après une inscription réussie

```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  await AuthStorage.save(data['id'], data['token']);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainPage()),
  );
}
```

Contrairement au login, il n'y a pas de gestion de `redirectImagePath` ici — après une inscription, on va toujours directement à l'écran principal.

> 💡 **Amélioration possible** : si on veut garder la même expérience que le login (rediriger vers le chat si une photo était en attente), il faudrait ajouter le même paramètre `redirectImagePath` que dans `LoginPage`.

## Gestion des doublons (email déjà utilisé)

Si l'email existe déjà en base, le backend renvoie une erreur (pas un code 200), qui est affichée via :

```dart
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Erreur : ${response.body}")),
  );
}
```

## Lexique

| Terme | Explication |
|---|---|
| `TextEditingController` | Objet qui mémorise et permet de lire le contenu d'un champ de texte |
| Expression régulière (Regex) | Un motif texte utilisé pour valider un format (numéro, email, etc.) |
| `email_validator` | Package Flutter externe spécialisé dans la validation d'adresses email |
