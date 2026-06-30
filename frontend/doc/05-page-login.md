# Module 05 — `pages/login_page.dart`

## À quoi sert cette page ?

C'est la page de connexion. L'utilisateur entre son email et son mot de passe, et l'app vérifie ces informations auprès du backend.

## Particularité : la redirection après une photo

```dart
class LoginPage extends StatefulWidget {
  final String? redirectImagePath;
  const LoginPage({super.key, this.redirectImagePath});
```

- `redirectImagePath` est un paramètre **optionnel** (le `?` après `String`).
- Cas d'usage : un visiteur non connecté prend une photo de plante → l'app lui demande de se connecter d'abord → une fois connecté, on veut le renvoyer directement vers l'analyse de SA photo, pas vers l'accueil.

## La validation du formulaire

```dart
final _formKey = GlobalKey<FormState>();
```

- C'est une "télécommande" qui permet de contrôler tout le formulaire (`Form`) : vérifier si tous les champs sont valides, ou les vider.

```dart
Future<void> login() async {
  if (!_formKey.currentState!.validate()) return;
```

- Avant d'envoyer quoi que ce soit au serveur, on vérifie que le formulaire est valide (champs non vides, etc.).
- Si ce n'est pas le cas, on arrête tout (`return`) — les messages d'erreur s'affichent automatiquement sous les champs concernés.

## L'appel au serveur

```dart
final response = await http.post(
  Uri.parse(ApiConfig.login),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': emailController.text.trim(),
    'password': passwordController.text.trim(),
  }),
);
```

- On envoie une requête `POST` (on "pousse" des données vers le serveur) à l'URL de connexion.
- `jsonEncode` transforme notre objet Dart `{...}` en texte JSON, le format que le serveur comprend.
- `.trim()` retire les espaces accidentels au début/fin (utile si l'utilisateur a appuyé sur espace par erreur).

## Traiter la réponse

```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  await AuthStorage.save(data['id'], data['token']);
```

- Le code `200` signifie "tout s'est bien passé".
- `jsonDecode` fait l'inverse de `jsonEncode` : transforme le texte JSON reçu en objet Dart utilisable.
- On sauvegarde immédiatement l'ID et le token via `AuthStorage` (voir module 02).

```dart
  if (widget.redirectImagePath != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(imagePath: widget.redirectImagePath!),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }
```

C'est ici que se joue la redirection intelligente expliquée plus haut : si une photo était en attente, on va directement au chat avec cette photo ; sinon, on va à l'écran principal.

## Gestion des erreurs

```dart
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Erreur : ${response.body}")),
  );
}
```

Si le serveur répond autre chose que 200 (par exemple mot de passe incorrect), on affiche un petit message en bas de l'écran (`SnackBar`) avec le détail de l'erreur.

```dart
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Impossible de joindre le serveur")),
  );
}
```

Le `catch` intercepte les erreurs **techniques** (pas de connexion internet, serveur injoignable...), différentes des erreurs métier (mauvais mot de passe) traitées juste au-dessus.

## L'indicateur de chargement

```dart
bool loading = false;
...
setState(() => loading = true);
// ... appel réseau ...
finally {
  if (mounted) setState(() => loading = false);
}
```

- `loading` est mis à `true` juste avant l'appel réseau, et remis à `false` une fois terminé (que ça ait marché ou non, grâce au bloc `finally`).
- Tant que `loading` est `true`, l'écran affiche une roue de chargement au lieu du formulaire :

```dart
body: loading
    ? const Center(child: CircularProgressIndicator(...))
    : SafeArea(...)
```

## Lexique

| Terme | Explication |
|---|---|
| `GlobalKey<FormState>` | Une référence permettant de piloter un formulaire depuis le code (validation, reset) |
| `POST` | Type de requête HTTP utilisé pour envoyer des données au serveur (créer/modifier quelque chose) |
| `statusCode` | Le code numérique que renvoie le serveur pour indiquer le résultat (200 = succès, 400 = erreur, etc.) |
| `jsonEncode` / `jsonDecode` | Convertir un objet Dart en texte JSON, et inversement |
| `try / catch / finally` | Structure permettant d'exécuter du code risqué, de réagir si ça échoue, et de toujours exécuter une dernière partie quoi qu'il arrive |
