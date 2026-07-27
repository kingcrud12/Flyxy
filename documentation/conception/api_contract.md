# Contrat d'API (Backend Go -> Frontend Flutter)

Ce document définit le format exact du JSON que le backend Go renverra à l'application Flutter. Ce "contrat" permet aux développeurs Front et Back de travailler en parallèle : 
*   Le Front peut utiliser des fausses données (mocks) basées sur ce JSON.
*   Le Back doit garantir que la sortie de son API respecte toujours ce format, peu importe la complexité de l'API externe (PRIM).

## Endpoint : Prochains Départs
**Route:** `GET /api/v1/stations/{station_id}/departures`

### Modèle de Réponse JSON

```json
{
  "station": {
    "id": "stop_area:IDFM:71556",
    "name": "Châtelet - Les Halles"
  },
  "departures": [
    {
      "id": "dep_12345",
      "transport_mode": "RER",          // "RER", "Metro", "Bus", "Tram"
      "line_code": "A",                 // "A", "1", "72"
      "line_color": "E3051C",           // Couleur officielle de la ligne (Hex) très utile pour le Flutter UI
      "direction": "Marne-la-Vallée - Chessy",
      "platform": "Voie 2",             // Nullable si non connu
      "expected_time": "2026-07-27T17:15:00+02:00", // Heure réelle prévue au format ISO 8601
      "waiting_minutes": 5,             // Calculé par Go pour faciliter l'affichage
      "status": "on_time"               // "on_time", "delayed", "canceled"
    },
    {
      "id": "dep_12346",
      "transport_mode": "Metro",
      "line_code": "1",
      "line_color": "FFCE00",
      "direction": "La Défense",
      "platform": null,
      "expected_time": "2026-07-27T17:18:00+02:00",
      "waiting_minutes": 8,
      "status": "on_time"
    }
  ]
}
```

### Explications des champs (Pourquoi ce choix ?)
*   **`line_color`** : L'API PRIM fournit la couleur officielle des lignes. L'envoyer directement évite au frontend Flutter de devoir stocker en dur un dictionnaire de toutes les couleurs des lignes de Paris.
*   **`waiting_minutes`** : L'API PRIM donne une date absolue. C'est le backend Go (qui est très rapide) qui se chargera de faire le calcul `Heure de départ - Heure actuelle` pour envoyer un chiffre simple (ex: 5) à Flutter.
*   **`status`** : Permettra à Flutter d'afficher le temps en rouge si le train est en retard ou supprimé.
