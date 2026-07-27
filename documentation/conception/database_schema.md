# Schéma de Base de Données (SQLite)

Pour gérer les comptes utilisateurs et leurs favoris (lieux et itinéraires), nous utilisons une base de données relationnelle **SQLite**.

Voici la structure des tables (MCD - Modèle Conceptuel de Données).

```mermaid
erDiagram
    USERS ||--o{ FAVORITE_PLACES : "possède"
    USERS ||--o{ FAVORITE_ROUTES : "possède"

    USERS {
        int id PK "Identifiant unique"
        string email "Adresse email (Unique)"
        string password_hash "Mot de passe hashé (bcrypt)"
        datetime created_at "Date de création"
    }

    FAVORITE_PLACES {
        int id PK
        int user_id FK "Référence à l'utilisateur"
        string name "Nom personnalisé (ex: 'Maison')"
        string stop_area_id "ID de la station PRIM (ex: stop_area:IDFM:...)"
        datetime created_at
    }

    FAVORITE_ROUTES {
        int id PK
        int user_id FK "Référence à l'utilisateur"
        string name "Nom de l'itinéraire (ex: 'Maison -> Travail')"
        string from_stop_id "ID station de départ"
        string to_stop_id "ID station d'arrivée"
        datetime created_at
    }
```

## Détails de l'implémentation
*   **Technologie :** `SQLite3` (Fichier local `.db` dans le backend Go).
*   **Sécurité :** Les mots de passe seront obligatoirement hashés (avec `bcrypt`) avant insertion dans la table `users`.
*   **ORM :** L'interaction avec la base se fera via GORM (l'ORM le plus populaire en Go) ou directement en SQL via `database/sql`.
