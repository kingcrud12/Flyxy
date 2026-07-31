# 🚌 Flyxy — La mobilité pour tous

Flyxy est une application mobile d'avant-garde (iOS & Android) accompagnée de son backend dédié ultra-performant. Elle permet de consulter les horaires de transports en commun en temps réel (via l'API PRIM / Navitia d'Île-de-France Mobilités) de manière sociale, interactive et extrêmement fluide.

L'application se distingue par son design premium immersif (effet *Liquid Glass*, fonds d'écran animés des monuments de Paris) et sa fluidité native (60 FPS).

## ✨ Fonctionnalités Premium

* 🎙️ **Recherche Vocale Intelligente :** Plus besoin de taper, cherchez instantanément votre itinéraire ou votre destination simplement en parlant !
* 🗺️ **Cartographie Interactive :** Intégration native et fluide de la carte (Apple Maps) pour visualiser les arrêts autour de vous en temps réel.
* 💬 **Réseau Social & Communauté :** Un fil d'actualité intégré permettant aux utilisateurs de publier des alertes, commenter et "liker" les posts liés au trafic.
* ⭐ **Favoris Rapides :** Sauvegardez vos lieux et arrêts fréquents pour un accès en un tap.
* 👤 **Système de Comptes Avancé :** Profils utilisateurs complets, gestion des avatars (upload d'images), authentification sécurisée par JWT.

## 🏗 Architecture du Projet

Le projet est divisé en deux parties principales, déployées automatiquement via notre pipeline CI/CD moderne :

1. **Backend (`/api`) :**
   * **Langage :** Go (Golang)
   * **Framework :** Gin (Routeur HTTP ultra-rapide)
   * **Base de données :** SQLite (gérée via l'ORM GORM) avec des identifiants UUID
   * **Sécurité & Authentification :** JWT stockés dans des cookies sécurisés (`HttpOnly`), mots de passe hachés (bcrypt).
   * **Rôle :** Gérer les données sociales (posts, commentaires, likes), les comptes utilisateurs, et agir comme proxy rapide pour formatter les données depuis l'API externe PRIM (Navitia).

2. **Frontend Mobile (`/client_mobile`) :**
   * **Technologie :** Flutter (Multiplateforme)
   * **Architecture d'état :** `Provider` (avec `ChangeNotifier` pour les ViewModels)
   * **Navigation :** `GoRouter` avec `StatefulShellRoute` pour une navigation par onglets instantanée sans perte d'état.
   * **Réseau :** `Dio` avec gestion automatique des cookies (`dio_cookie_manager`)
   * **UI/UX :** Thème sombre élégant, effets de flou natifs (Glassmorphism), icônes personnalisées.

## 🚀 CI/CD & Déploiement Production

Le projet inclut une infrastructure de production complète :
* **GitHub Actions** automatise le déploiement sur VPS au moindre `git push` sur la branche `main`.
* **Nginx** agit comme Reverse Proxy (anti-XSS, anti-DDoS, CSP stricte) et sert l'API en HTTPS via **Let's Encrypt (Certbot)**.
* **PM2** maintient le serveur Go actif en arrière-plan (auto-restart en cas de crash).

## 🛠 Comment lancer le projet en local

### 1. Lancer l'API (Go)

Assurez-vous d'avoir Go installé sur votre machine.
```bash
cd api
go mod tidy
go run main.go
```
*Le serveur démarrera localement sur `http://localhost:8081`.*

### 2. Lancer l'Application Mobile (Flutter)
Assurez-vous d'avoir Flutter installé et un émulateur / simulateur lancé (ou un appareil physique branché).
```bash
cd client_mobile
flutter pub get
# Pour utiliser l'API locale :
flutter run 
# Ou pour tester directement sur l'API de production VPS :
flutter run --dart-define=API_URL=https://api-flyxy.neo-tech-softwares.com/api/v1/
```

## 📚 Documentation Technique

Des détails approfondis sur la conception sont disponibles dans le dossier `documentation/conception/` :
* [Architecture Globale](documentation/conception/global_architecture.md)
* [Schéma de la Base de Données](documentation/conception/database_schema.md)
* [Contrat API (Swagger / OpenAPI)](documentation/conception/api_contract.md)
* [Sources Open Data](documentation/conception/open_data_sources.md)
