# Documentation — Email & Sécurité (Agriscan Backend)

## 1. Service d'envoi d'email — Brevo API

### Pourquoi Brevo et pas SMTP ?

Render (free tier) **bloque les ports SMTP sortants** (587 et 465). Toute tentative de connexion à `smtp.gmail.com` échoue avec un timeout, peu importe le port ou le protocole (STARTTLS ou SSL).

La solution est d'utiliser un service d'envoi d'email via **API HTTPS** (port 443, jamais bloqué). Nous utilisons **Brevo** (ex-Sendinblue), qui offre 300 emails/jour gratuits.

### Architecture

```
Backend Spring Boot
        │
        │  HTTPS POST
        ▼
api.brevo.com/v3/smtp/email
        │
        ▼
   Email envoyé
```

Le fichier `EmailService.java` utilise `java.net.http.HttpClient` (natif Java, pas de dépendance supplémentaire) pour appeler l'API Brevo directement, sans passer par `JavaMailSender`/SMTP.

### Configuration requise

#### a) Variables d'environnement (Render → Environment)

| Variable | Valeur | Description |
|---|---|---|
| `BREVO_API_KEY` | `xkeysib-...` | Clé API générée sur Brevo |

⚠️ Ne jamais committer cette clé dans le code source ou `application.properties` en valeur brute.

#### b) `application.properties`

```properties
brevo.api.key=${BREVO_API_KEY}
brevo.sender.email=agriscantech@gmail.com
brevo.sender.name=Agriscan
```

#### c) Expéditeur vérifié sur Brevo

Avant de pouvoir envoyer des emails, l'adresse expéditrice doit être **vérifiée** sur Brevo :

1. Brevo → Settings → **Expéditeurs, domaine, IP** → onglet **Expéditeurs**
2. Ajouter `agriscantech@gmail.com` comme expéditeur
3. Confirmer via le lien reçu dans la boîte mail
4. Le statut doit passer à **Vérifié** (point vert)

Sans cette étape, l'API Brevo refuse d'envoyer les emails au nom de cette adresse.

### Limites connues

- **Adresse Gmail comme expéditeur** : Brevo avertit que les adresses de fournisseurs gratuits (Gmail, Yahoo, etc.) ont une moins bonne délivrabilité (risque accru de spam) que les domaines authentifiés (DKIM/DMARC). Acceptable en développement, à améliorer en production avec un nom de domaine propre.
- **Quota gratuit** : 300 emails/jour. Si dépassé, les envois échouent jusqu'au lendemain (UTC).

### Pour passer à un domaine personnalisé (futur, optionnel)

1. Acheter un nom de domaine (ex. `agriscan.com`)
2. Brevo → Domaines → Ajouter le domaine
3. Configurer les enregistrements DNS fournis (DKIM, DMARC, SPF) chez le registrar
4. Créer un expéditeur type `noreply@agriscan.com`
5. Mettre à jour `brevo.sender.email` en conséquence

---

## 2. Sécurité — bonnes pratiques appliquées et points de vigilance

### a) Secrets et credentials

| Élément | Risque | Mitigation |
|---|---|---|
| Clé API Brevo | Si exposée, un tiers peut envoyer des emails en votre nom et épuiser le quota | Stockée uniquement en variable d'environnement Render, jamais en dur dans le code |
| Mot de passe MySQL Aiven | Accès direct à toute la base de données | Stocké en variable d'environnement, à régénérer si une capture d'écran ou un commit l'a exposé |
| Ancien mot de passe Gmail (App Password) | Permettait l'envoi SMTP au nom du compte Gmail | **Révoqué** suite à l'exposition dans `application.properties` ; remplacé par Brevo |

**Règle générale** : toute clé/mot de passe apparaissant dans une capture d'écran, un message de chat, ou un commit Git doit être considéré comme compromis et régénéré immédiatement.

### b) Authentification applicative

- Les mots de passe utilisateurs sont hashés avec **BCrypt** (`BCryptPasswordEncoder`), jamais stockés en clair.
- L'authentification utilise des **JWT** (JSON Web Tokens) avec une durée de validité limitée.
- Le endpoint `change-password` exige l'ancien mot de passe avant d'autoriser le changement.

### c) Réinitialisation de mot de passe

- Un code à 6 chiffres est généré aléatoirement et stocké en base avec une expiration (15 minutes).
- Le code est supprimé après usage ou expiration (`tokenRepository.delete(resetToken)`).
- Aucune information sur l'existence ou non d'un compte n'est révélée de façon exploitable autrement que via le message d'erreur standard ("Aucun compte avec cet email").

### d) Upload de fichiers (photos de profil)

Le endpoint `POST /api/clients/{id}/photo` applique :
- Vérification du `Content-Type` (doit commencer par `image/`)
- Limite de taille : 5 Mo maximum
- Nom de fichier généré aléatoirement (`UUID`) pour éviter les collisions et l'écrasement de fichiers d'autres utilisateurs
- Pas d'exécution de code possible (fichiers servis en lecture seule via `ResourceHandlerRegistry`)

⚠️ **Limite connue** : Render (free tier) a un système de fichiers **éphémère** — les fichiers uploadés sont perdus à chaque redéploiement. Pour la production, prévoir une migration vers un stockage persistant (Cloudinary, AWS S3, ou équivalent).

### e) CORS

Actuellement configuré en `@CrossOrigin(origins = "*")` sur les controllers — accepte les requêtes de n'importe quelle origine. Acceptable en développement, mais **à restreindre en production** à l'origine exacte de l'application Flutter Web ou au domaine officiel, pour éviter les abus depuis des sites tiers.

### f) Base de données

- Connexion chiffrée obligatoire vers Aiven MySQL (`ssl-mode=REQUIRED`).
- Les credentials de connexion sont en variables d'environnement, pas en dur dans le code.

---

## 3. Checklist de sécurité avant mise en production

- [ ] Révoquer toute clé/mot de passe ayant été exposé(e) dans des captures d'écran ou commits
- [ ] Restreindre `@CrossOrigin` aux origines de confiance uniquement
- [ ] Migrer le stockage des photos vers un service persistant (S3/Cloudinary)
- [ ] Authentifier le domaine d'envoi d'email (DKIM/DMARC) pour réduire le risque de spam
- [ ] Définir une durée d'expiration courte et appropriée pour les JWT, avec mécanisme de refresh
- [ ] Auditer régulièrement les dépendances (`pom.xml`, `pubspec.yaml`) pour les vulnérabilités connues
- [ ] Activer la rotation périodique des clés API (Brevo, etc.)
