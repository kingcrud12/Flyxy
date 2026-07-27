# Cas d'Utilisation : Le Voyageur

Le diagramme ci-dessous liste les actions directes que le voyageur peut effectuer sur l'application.

```mermaid
flowchart LR
    %% Acteur principal
    Voyageur((Voyageur))

    %% Cas d'utilisation
    UC1([Rechercher un arrêt ou une station])
    UC2([Consulter les prochains départs])
    UC3([Rafraîchir les horaires en temps réel])

    %% Liens Acteur -> Cas d'utilisation
    Voyageur --> UC1
    Voyageur --> UC2
    Voyageur --> UC3

    %% Relations entre les cas d'utilisation (UML include)
    UC2 -.->|include| UC1
