# Module 00 — Architecture générale du projet Agriscan

## Vue d'ensemble

Agriscan est une application Flutter de diagnostic agricole : l'utilisateur prend ou importe une photo de plante, une IA l'analyse, et l'application affiche les maladies détectées et des solutions.

## Structure des dossiers

```
lib/
├── main.dart                  → Point d'entrée de l'app
├── models/
│   └── maladie.dart            → Modèle de données "Maladie"
├── pages/                      → Toutes les pages (écrans) de l'app
│   ├── onboarding_page.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── forgot_password_page.dart
│   ├── reset_password_page.dart
│   ├── main_page.dart          → Page conteneur avec la barre de navigation
│   ├── home_pages.dart
│   ├── chat_page.dart
│   ├── chat_detail_page.dart
│   ├── histor_page.dart
│   ├── profile.dart
│   ├── stock_maladie.dart
│   ├── detail_maladie.dart
│   └── preview_page.dart
└── services/                   → Logique technique réutilisable
    ├── api_config.dart         → Toutes les URLs du backend
    ├── auth_storage.dart       → Sauvegarde du token de connexion
    └── theme_provider.dart     → Gestion du thème clair/sombre
```

## Les 3 grandes familles de fichiers

### 1. `pages/` — ce que l'utilisateur voit

Chaque fichier dans `pages/` correspond à un **écran** de l'application. En Flutter, un écran est une classe qui hérite de `StatelessWidget` (statique, ne change jamais) ou `StatefulWidget` (peut changer, par exemple afficher un chargement puis un résultat).

### 2. `services/` — la logique technique

Ces fichiers ne dessinent rien à l'écran. Ils gèrent :
- les appels au serveur (`api_config.dart`)
- la mémorisation de la connexion (`auth_storage.dart`)
- les couleurs de l'app (`theme_provider.dart`)

### 3. `models/` — la forme des données

Un "modèle" décrit la structure d'une donnée. Par exemple `Maladie` décrit ce qu'est une maladie : un nom, une image, une description, une solution.

## Comment l'app démarre — le flux complet

```
main.dart
    │
    ▼
SplashRouter (écran de chargement avec le logo)
    │
    ├── Si c'est la 1ère fois → OnboardingPage (3 slides de présentation)
    │
    └── Sinon → MainPage (l'app principale avec la barre de navigation)
```

## Comment les pages communiquent avec le backend

Toutes les requêtes au serveur Spring Boot passent par le même schéma :

```dart
final response = await http.get(
  Uri.parse(ApiConfig.client(userId)),   // 1. quelle URL appeler (centralisée dans api_config.dart)
  headers: {
    'Authorization': 'Bearer $token',     // 2. le "ticket" qui prouve qu'on est connecté
  },
);

if (response.statusCode == 200) {
  // 3. si ça a marché, on lit les données reçues
  final data = jsonDecode(response.body);
} else {
  // 4. sinon on affiche une erreur
}
```

C'est le même schéma partout dans l'app : **construire l'URL → envoyer la requête → vérifier le code de réponse → traiter le résultat**.

## Lexique débutant

| Terme | Explication simple |
|---|---|
| **Widget** | Un bloc visuel ou logique de l'interface. Tout en Flutter est un widget (un bouton, un texte, une page entière). |
| **StatefulWidget** | Un widget qui peut changer d'apparence pendant qu'on l'utilise (ex: un formulaire qui passe de "vide" à "rempli") |
| **StatelessWidget** | Un widget figé, qui ne change jamais après sa création |
| **setState()** | La commande qui dit à Flutter "redessine cet écran, quelque chose a changé" |
| **async / await** | Permet d'attendre une réponse du serveur sans bloquer toute l'application pendant ce temps |
| **Provider** | Un système qui permet de partager une donnée (comme le thème clair/sombre) entre plusieurs pages sans la repasser à chaque fois en paramètre |
| **Token JWT** | Une sorte de "ticket" numérique prouvant qu'un utilisateur est bien connecté, envoyé à chaque requête au serveur |

## Prochains modules

Chaque page de l'app a son propre fichier de documentation détaillé :

1. `01-services-api-config.md`
2. `02-services-auth-storage.md`
3. `03-services-theme-provider.md`
4. `04-page-onboarding.md`
5. `05-page-login.md`
6. `06-page-register.md`
7. `07-page-forgot-reset-password.md`
8. `08-page-main-navigation.md`
9. `09-page-home.md`
10. `10-page-chat.md`
11. `11-page-chat-detail.md`
12. `12-page-historique.md`
13. `13-page-profil.md`
14. `14-page-stock-maladies.md`
