# Module 03 — `services/theme_provider.dart`

## À quoi sert ce fichier ?

Ce fichier gère le **mode clair / mode sombre** de l'application. Il décide quelles couleurs utiliser partout dans l'app, et mémorise le choix de l'utilisateur même après avoir fermé l'app.

## Le concept clé : `ChangeNotifier`

```dart
class ThemeProvider extends ChangeNotifier {
```

- `ChangeNotifier` est un système Flutter qui permet à un objet de "prévenir" tous les écrans qui l'utilisent quand quelque chose change.
- C'est comme une sirène : quand on l'active, tous les écrans qui l'écoutent se redessinent automatiquement.

## Le code, expliqué

### La variable d'état

```dart
bool _darkMode = false;
bool get darkMode => _darkMode;
ThemeData get theme => _darkMode ? _darkTheme : _lightTheme;
```

- `_darkMode` est une variable privée qui dit si on est en mode sombre (`true`) ou clair (`false`).
- `darkMode` (sans le `_`) est un "getter" : une façon publique de lire la valeur de `_darkMode` depuis l'extérieur.
- `theme` renvoie directement le bon thème complet selon le mode actuel, grâce à l'opérateur ternaire `condition ? siVrai : siFaux`.

### Charger le thème sauvegardé au démarrage

```dart
Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  _darkMode = prefs.getBool('dark_mode') ?? false;
  notifyListeners();
}
```

- On va lire dans la mémoire du téléphone si l'utilisateur avait choisi le mode sombre la dernière fois.
- `?? false` veut dire : "si rien n'est trouvé, utilise `false` par défaut" (mode clair).
- `notifyListeners()` est l'appel magique qui dit à tous les écrans connectés : "redessine-toi, le thème a changé".

### Changer de thème

```dart
Future<void> toggleTheme() async {
  _darkMode = !_darkMode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('dark_mode', _darkMode);
  notifyListeners();
}
```

- `!_darkMode` inverse la valeur actuelle (`true` devient `false` et inversement).
- On sauvegarde ce nouveau choix pour la prochaine fois.
- On prévient tous les écrans du changement.

### Les deux thèmes (clair et sombre)

```dart
static final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF4CD964),  // vert Agriscan
  scaffoldBackgroundColor: Colors.grey[100],
  ...
);

static final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF4CD964),
  scaffoldBackgroundColor: const Color(0xFF121212),
  ...
);
```

Chaque thème définit un ensemble cohérent de couleurs : fond, barre du bas, cartes, interrupteurs (switch), etc. Le vert `0xFF4CD964` reste la couleur de marque dans les deux modes.

## Comment ce fichier est connecté à toute l'app

### 1. Le `Provider` est créé une seule fois, au démarrage (`main.dart`)

```dart
final themeProvider = ThemeProvider();
await themeProvider.loadTheme();

runApp(
  ChangeNotifierProvider(
    create: (_) => themeProvider,
    child: const AgriscanApp(),
  ),
);
```

- On crée un seul `ThemeProvider`, partagé par toute l'application.
- `ChangeNotifierProvider` "injecte" cet objet pour qu'il soit accessible depuis n'importe quelle page, sans avoir à le repasser en paramètre partout.

### 2. N'importe quelle page peut lire le thème actuel

```dart
final darkMode = Provider.of<ThemeProvider>(context).darkMode;
```

### 3. N'importe quelle page peut changer le thème (ex: bouton dans le profil)

```dart
onPressed: () => themeProvider.toggleTheme(),
```

## Lexique

| Terme | Explication |
|---|---|
| `ChangeNotifier` | Un objet capable de prévenir l'interface quand ses données changent |
| `notifyListeners()` | La méthode qui déclenche le rafraîchissement de l'écran |
| `Provider` | Le système qui rend un objet accessible depuis toute l'application |
| Getter (`get xxx`) | Une façon de lire une valeur calculée, comme si c'était une simple propriété |
| Opérateur ternaire (`? :`) | Raccourci pour écrire un `if / else` en une seule ligne |
