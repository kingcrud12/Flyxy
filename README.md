# 🚌 Flyxy (Mini-Transit) — API & Interface Temps Réel

Flyxy est une application mobile moderne (iOS & Android) accompagnée de son backend dédié, permettant de consulter les horaires de transports en commun en temps réel (via l'API PRIM / Navitia d'Île-de-France Mobilités).

L'application se distingue par son design premium immersif (effet *Liquid Glass*, fonds d'écran animés des monuments de Paris) et sa fluidité native.

## 🏗 Architecture du Projet

Le projet est divisé en deux parties principales :

1. **Backend (`/api`) :**
   * **Langage :** Go (Golang)
   * **Framework :** Gin (Routeur HTTP ultra-rapide)
   * **Base de données :** SQLite (gérée via l'ORM GORM) avec des identifiants UUID
   * **Authentification :** JWT (JSON Web Tokens) stockés dans des cookies sécurisés (`HttpOnly`)
   * **Rôle :** Gérer les comptes utilisateurs (inscription, connexion, favoris) et agir comme proxy pour récupérer et formatter les données en temps réel depuis l'API externe PRIM (Navitia).

2. **Frontend Mobile (`/client_mobile`) :**
   * **Technologie :** Flutter
   * **Architecture d'état :** `Provider` (avec `ChangeNotifier` pour les ViewModels)
   * **Navigation :** `GoRouter` avec implémentation de `StatefulShellRoute` pour une navigation par onglets instantanée sans rechargement
   * **Réseau :** `Dio` avec gestion automatique des cookies (`dio_cookie_manager`)
   * **UI/UX :** Thème sombre élégant, effets de flou natifs (Glassmorphism), couleurs officielles RATP (Ligne 1, RER A), et carrousel d'images de fond.

## 🚀 Fonctionnalités Actuelles

* **Système de Comptes :** Inscription et connexion sécurisées avec hachage des mots de passe (bcrypt) et sessions persistantes.
* **Navigation Fluide :** Barre de navigation persistante avec un effet visuel continu en arrière-plan.
* **Interface Premium :** Affichage stylisé des prochains passages (Ligne, Direction, Temps d'attente).
* **Profil Utilisateur :** Récupération dynamique des données de l'utilisateur connecté via l'API locale.

## 🛠 Comment lancer le projet en local

### 1. Lancer l'API (Go)
Assurez-vous d'avoir Go installé sur votre machine.
```bash
cd api
go mod tidy
go run main.go
```
*Le serveur démarrera sur `http://localhost:8081`.*

### 2. Lancer l'Application Mobile (Flutter)
Assurez-vous d'avoir Flutter installé et un émulateur / simulateur lancé (ou un appareil physique branché).
```bash
cd client_mobile
flutter pub get
flutter run
```
*L'application pointera automatiquement vers l'API locale (assurez-vous que l'IP configurée dans `auth_service.dart` correspond bien à celle de votre machine si vous utilisez un iPhone physique).*

## 📚 Documentation Technique

Des détails approfondis sur la conception sont disponibles dans le dossier `documentation/conception/` :
* [Architecture Globale](documentation/conception/global_architecture.md)
* [Schéma de la Base de Données](documentation/conception/database_schema.md)
* [Contrat API (Swagger / OpenAPI)](documentation/conception/api_contract.md)
* [Sources Open Data](documentation/conception/open_data_sources.md)
