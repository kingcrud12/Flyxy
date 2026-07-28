# Architecture des Composants

Ce diagramme illustre les différentes couches logicielles du projet et la manière dont les composants communiquent entre eux (Frontend, Backend et API externe).

```mermaid
graph TD
    subgraph FRONTEND ["Frontend (Mobile App Flutter iOS/Android)"]
        UI_VIEWS["UI Components<br/>• HomeView (Liquid Glass)<br/>• DepartureCard<br/>• MainWrapper (Carousel)"]
        STATE_MGR["State Manager (Provider)<br/>• ViewModels (ChangeNotifier)<br/>• Appels Dio<br/>• Injection de dépendances"]
        
        UI_VIEWS -->|"Invoque les hooks"| STATE_MGR
    end

    subgraph BACKEND ["Backend (API Go)"]
        HTTP_ROUTER["Router HTTP<br/>• Endpoints REST<br/>• Validation & CORS"]
        TRANSIT_SERVICE["Transit Service<br/>• Parsing des données brutes<br/>• Calcul du délai d'attente<br/>• Formattage du JSON final"]
        OPENDATA_CLIENT["OpenData Client<br/>• Client HTTP natif<br/>• Gestion du Timeout<br/>• Headers & API Keys"]

        HTTP_ROUTER -->|"Appelle la logique métier"| TRANSIT_SERVICE
        TRANSIT_SERVICE -->|"Requête les données"| OPENDATA_CLIENT
    end

    subgraph EXTERNAL ["Externe (Open Data Transport)"]
        PROVIDER_API["API Provider Externe<br/>• Base REST Open Data<br/>• Horaires & Temps Réel"]
    end

    STATE_MGR -->|"Requête HTTP GET (REST / JSON)"| HTTP_ROUTER
    OPENDATA_CLIENT -->|"Requête HTTP GET (Brut)"| PROVIDER_API
