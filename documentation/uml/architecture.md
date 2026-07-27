graph TD
    subgraph Frontend ["Frontend (React Client)"]
        UI["UI / Views (Composants React)"]
        State["State Manager (TanStack Query)"]
        UI --> State
    end

    subgraph Backend ["Backend (API Service Go)"]
        Handler["HTTP Handler (Router Go)"]
        Service["Transport Service (Logique Métier)"]
        Client["OpenData Client (Client HTTP)"]
        
        Handler --> Service
        Service --> Client
    end

    subgraph External ["Externe"]
        API["API Open Data Transport"]
    end

    State -->|HTTP GET /api/departures| Handler
    Client -->|HTTP GET /donnees-brutes| API
