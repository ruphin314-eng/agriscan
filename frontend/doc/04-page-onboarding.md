# Module 04 — `pages/onboarding_page.dart`

## À quoi sert cette page ?

C'est la toute première chose qu'un nouvel utilisateur voit : 3 slides expliquant comment fonctionne l'application (prendre une photo → l'IA analyse → recevoir des solutions). Elle ne s'affiche **qu'une seule fois**, au tout premier lancement.

## Les outils Flutter utilisés

```dart
final PageController _pageController = PageController();
int _currentPage = 0;
```

- `PageController` permet de contrôler un carrousel de pages glissantes (comme les stories Instagram).
- `_currentPage` mémorise sur quel slide on se trouve actuellement (0, 1 ou 2).

## La structure des données des slides

```dart
class _OnboardingData {
  final IconData icon;
  final Color color;
  final String titre;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.titre,
    required this.description,
  });
}
```

On crée notre propre "modèle" pour décrire un slide : une icône, une couleur, un titre, une description. Ça évite de répéter 4 variables séparées pour chaque slide.

```dart
final List<_OnboardingData> _slides = [
  _OnboardingData(
    icon: Icons.camera_alt_outlined,
    color: const Color(0xFF4CD964),
    titre: 'Photographiez votre plante',
    description: '...',
  ),
  // ... 2 autres slides
];
```

Une simple liste contenant les 3 slides, dans l'ordre d'affichage.

## Comment on passe au slide suivant

```dart
void _suivant() {
  if (_currentPage < _slides.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  } else {
    _terminer();
  }
}
```

- Si on n'est pas encore sur le dernier slide, on demande au `PageController` d'animer vers le slide suivant.
- Si on est déjà sur le dernier slide, le bouton devient "Commencer" et appelle `_terminer()`.

## Comment on termine l'onboarding définitivement

```dart
Future<void> _terminer() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);
  if (!mounted) return;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainPage()),
  );
}
```

- On sauvegarde dans la mémoire du téléphone : `onboarding_done = true`.
- C'est cette information que `main.dart` vérifie à chaque démarrage de l'app pour savoir s'il faut remontrer l'onboarding ou non.
- `Navigator.pushReplacement` envoie vers `MainPage` en **remplaçant** l'écran actuel (impossible de revenir en arrière avec le bouton retour).
- Le `if (!mounted) return;` est une sécurité : si la page a été fermée pendant qu'on attendait `SharedPreferences`, on arrête tout pour éviter un crash.

## Les éléments visuels

### Le bouton "Passer"

```dart
_currentPage < _slides.length - 1
    ? TextButton(
        onPressed: _terminer,
        child: const Text('Passer', ...),
      )
    : const SizedBox(height: 40),
```

Visible uniquement si on n'est pas sur le dernier slide (sinon il n'a plus d'utilité, le bouton principal devient déjà "Commencer").

### Les indicateurs de progression (petits points en bas)

```dart
Row(
  children: List.generate(
    _slides.length,
    (i) => AnimatedContainer(
      width: _currentPage == i ? 24 : 8,   // le point actif est plus large
      decoration: BoxDecoration(
        color: _currentPage == i
            ? const Color(0xFF4CD964)
            : Colors.white24,
      ),
    ),
  ),
),
```

- `List.generate` crée automatiquement un point pour chaque slide.
- Le point correspondant au slide actuel est plus large et vert ; les autres sont petits et gris transparent.
- `AnimatedContainer` anime automatiquement la transition de taille/couleur.

## Lexique

| Terme | Explication |
|---|---|
| `PageView` | Un widget qui affiche des pages que l'on peut faire glisser horizontalement |
| `PageController` | L'outil qui permet de contrôler ce glissement par code (avancer, reculer) |
| `mounted` | Indique si le widget est toujours "vivant" à l'écran (évite des erreurs si l'utilisateur a déjà quitté la page) |
| `List.generate` | Crée une liste en répétant une opération un certain nombre de fois |
