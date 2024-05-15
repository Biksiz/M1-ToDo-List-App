# Projet Flutter: Application ToDo List

L'objectif de ce projet est de réaliser une application Flutter qui permet la gestion d’une liste de tâches.

## Prerequis

- Avoir Flutter sur sa machine
- Avoir une Android Virtual Device ou un émulateur iOS

## API & Librairies utilisées

- path: ^1.9.0
- uuid: ^4.4.0
- provider: ^6.1.2
- flutter_map: ^6.0.0
- latlong2: ^0.9.0
- http: ^1.0.0
- geocoding: ^2.1.0

## Fonctionnalités implementées

* Ajout d'une tâhce par la saisie simple d’une phrase

* Modification d'une tache possible

* Affichage du lieu de la tâche sur une carte

* Affichage de la météo du lieu de la tâche

* Indication de la date d'écheance d'une tâche

* Indication de l'état d'importance d'une tâche

* Suppression d'une tâche par glissement

* Tri de l'ordre des tâches par importance ou par date d'écheance 

* Complétion d'une tâche

* Affichage separé des tâches encore actives et des tâches terminées

## Limitations de l'applications

Toutes les fonctionnalités demandées ont été réalisées. Nous avons également choisi d'utiliser Provider pour la gestion d'état dans notre application.