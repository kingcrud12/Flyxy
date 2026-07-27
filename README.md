# 🚌 Mini-Transit — API & Interface Tps Réel

> Application légère d'Information Voyageur (IV) construite pour afficher les prochains passages de transport en temps réel avec une expérience mobile-first.

---

## 🎯 Objectif du Projet

**Mini-Transit** est un projet bac à sable conçu pour pratiquer la conception orientée domaine et l'ingénierie logicielle fullstack avec **Go** et **React**. 

L'application agit comme une passerelle (API Gateway) entre les données ouvertes de transport (Open Data) et une interface utilisateur réactive. Elle abstrait la complexité des API externes, calcule les délais d'attente en temps réel et livre un contrat de données optimisé au client.

---

## 🏗️ Architecture & Conception

Le projet suit les principes de la **Clean Architecture** côté backend pour garantir un découplage total entre la logique métier, la couche de distribution HTTP et les clients d'API externes
