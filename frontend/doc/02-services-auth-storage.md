# Module 02 — `services/auth_storage.dart`

## À quoi sert ce fichier ?

Quand un utilisateur se connecte, le serveur lui donne un **token** (un ticket numérique prouvant qu'il est bien connecté) et son **ID**. Il faut mémoriser ces deux informations sur le téléphone, pour que l'utilisateur n'ait pas à se reconnecter à chaque fois qu'il rouvre l'application.

`AuthStorage` est une boîte à outils pour sauvegarder, lire et supprimer ces informations.

## Le code, expliqué

```dart
class AuthStorage {
  static const String _keyToken = 'token';
  static const String _keyUserId = 'userId';
```

- On définit deux "étiquettes" (clés) qui serviront à ranger les données : `'token'` et `'userId'`.
- Le `_` devant le nom (`_keyToken`) signifie que cette variable est **privée** : elle n'est utilisable que dans ce fichier.

### Sauvegarder la connexion

```dart
static Future<void> save(int userId, String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyUserId, userId);
  await prefs.setString(_keyToken, token);
}
```

- `SharedPreferences` est un outil Flutter qui permet de sauvegarder de petites données directement sur le téléphone (elles restent même si on ferme l'app).
- `await` veut dire "attends que cette opération soit terminée avant de continuer".
- On range l'ID utilisateur et le token sous leurs étiquettes respectives.

### Lire les informations sauvegardées

```dart
static Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyToken);
}

static Future<int?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_keyUserId);
}
```

- Ces fonctions vont chercher la valeur précédemment sauvegardée.
- Le `?` après `String` et `int` veut dire que le résultat peut être **null** (vide) si rien n'a encore été sauvegardé — par exemple si l'utilisateur ne s'est jamais connecté.

### Supprimer la connexion (déconnexion)

```dart
static Future<void> clear() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyToken);
  await prefs.remove(_keyUserId);
}
```

Utilisé quand l'utilisateur clique sur "Déconnexion" — on efface le token et l'ID, l'app "oublie" qu'il était connecté.

### Vérifier si l'utilisateur est connecté

```dart
static Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_keyToken);
  return token != null && token.isNotEmpty;
}
```

- Renvoie `true` si un token existe et n'est pas vide, `false` sinon.
- C'est cette fonction qui est appelée partout dans l'app pour décider : "est-ce que je montre la page de connexion ou directement le contenu réservé aux membres ?"

## Comment ce fichier est utilisé ailleurs

Exemple dans `home_pages.dart`, avant d'ouvrir le chat :

```dart
final isLoggedIn = await AuthStorage.isLoggedIn();

if (isLoggedIn) {
  // L'utilisateur peut accéder directement au chat
} else {
  // On l'envoie d'abord sur la page de connexion
}
```

Exemple dans `login_page.dart`, après une connexion réussie :

```dart
await AuthStorage.save(data['id'], data['token']);
```

## Lexique

| Terme | Explication |
|---|---|
| `SharedPreferences` | Stockage simple type "clé → valeur" qui persiste sur l'appareil |
| `Future<T>` | Représente une valeur de type `T` qui sera disponible plus tard (après une opération asynchrone) |
| `null` | Signifie "aucune valeur" / "vide" |
| Token | Identifiant numérique temporaire prouvant qu'un utilisateur est authentifié |
