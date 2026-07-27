# Sources Open Data (Information Voyageur)

Pour notre application Flutter et notre backend Go, nous avons besoin de sources de données fiables pour récupérer les informations de transport. Le format standard mondial est le **GTFS** (théorique) et **GTFS-RT** (temps réel).

Voici les principales sources Open Data disponibles, particulièrement pour la France et l'Île-de-France :

## 1. API PRIM (Île-de-France Mobilités)
C'est la source officielle et incontournable si l'application cible Paris et l'Île-de-France (RATP, SNCF Transilien, Optile).
*   **Données :** Prochains passages en temps réel, calcul d'itinéraires, infos trafic, autocomplétion des arrêts.
*   **Format :** JSON (via API REST), SIRI Lite (pour le temps réel).
*   **Accès :** Gratuit, nécessite la création d'un compte sur le portail PRIM pour obtenir une clé d'API (Token).
*   **Lien :** [prim.iledefrance-mobilites.fr](https://prim.iledefrance-mobilites.fr/)

## 2. Navitia.io (Recommandé pour la facilité)
Navitia est une API open source développée par Kisio (Keolis). Elle agrège déjà les données de nombreux réseaux de transport (dont la SNCF et la RATP) et expose une API REST très bien pensée pour les développeurs.
*   **Données :** Horaires, prochains départs, calcul d'itinéraires multicritères, isochrones.
*   **Format :** JSON structuré.
*   **Avantage :** Évite d'avoir à parser soi-même des fichiers GTFS complexes. Notre backend Go pourra facilement interroger Navitia et renvoyer la donnée à l'application Flutter.
*   **Lien :** [navitia.io](https://navitia.io/)

## 3. transport.data.gouv.fr (Point d'Accès National)
C'est le répertoire national de toutes les données de mobilité en France. 
*   **Données :** Regroupe les flux GTFS de la quasi-totalité des agglomérations françaises (bus, tram, etc.).
*   **Avantage :** Idéal si l'application a vocation à s'étendre à d'autres villes de France (Lyon, Marseille, Bordeaux, etc.).
*   **Lien :** [transport.data.gouv.fr](https://transport.data.gouv.fr/)

## 4. SNCF Open Data
Si l'application doit couvrir les trains nationaux.
*   **Données :** TGV, TER, Intercités (Gares, horaires, retards).
*   **Lien :** [data.sncf.com](https://data.sncf.com/)

---

## Et Google Maps (API) ?
On pourrait penser à utiliser Google Maps (via la Google Maps Platform) pour récupérer les horaires. Cependant, il y a plusieurs choses à savoir :
*   **Ce n'est pas de l'Open Data :** Google Maps est un service privé et payant (au-delà du quota gratuit).
*   **Limitation sur l'information voyageur :** L'API `Directions` de Google permet de calculer un itinéraire en transport en commun (point A au point B). En revanche, Google **ne propose pas** d'API publique pour afficher le "Tableau des départs" d'une station spécifique (les prochains passages).
*   **Google est un "consommateur" :** Les données de transport que vous voyez dans l'application Google Maps proviennent en réalité... des agences locales (comme Île-de-France Mobilités) qui fournissent leurs fichiers **GTFS** à Google ! 

**Verdict pour Google Maps :** 
À utiliser uniquement côté **Flutter (Frontend)** pour afficher une jolie carte (Google Maps Flutter plugin) et placer des marqueurs (vos stations). Mais pour la donnée (les horaires), il faut impérativement se brancher "à la source" (PRIM ou Navitia).

---

### Recommandation pour l'Architecture Go -> Flutter
Pour un MVP rapide et efficace, il est fortement conseillé de s'appuyer sur l'**API PRIM** (si focus Île-de-France) ou **Navitia** (si focus plus large). 
Notre backend Go jouera le rôle de **BFF (Backend For Frontend)** : il appellera ces API complexes, filtrera les données inutiles, et exposera une API REST propre (ou gRPC) que notre application Flutter consommera très facilement.
