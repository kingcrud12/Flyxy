graph LR
    subgraph System ["Système Mini-Transit"]
        UC1["UC1: Consulter les prochains départs"]
        UC2["UC2: Sélectionner un arrêt"]
        UC3["UC3: Formater & Calculer le temps restant"]
    end

    User(("Voyageur"))
    OpenData(("API Open Data"))

    User --> UC1
    UC1 -. "includes" .-> UC2
    UC1 -. "includes" .-> UC3
    UC3 --> OpenData
