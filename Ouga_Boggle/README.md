# Ouga Boggle

Un jeu de lettres inédit, pour les moments d'ennui !

[![pipeline status](https://gaufre.informatique.univ-paris-diderot.fr/crisan/ouga-boggle/badges/main/pipeline.svg)](https://gaufre.informatique.univ-paris-diderot.fr/crisan/ouga-boggle/commits/main)

## Télécharger

Afin de télécharger un executable `jar`, rendez-vous sur la page des [releases](https://gaufre.informatique.univ-paris-diderot.fr/crisan/ouga-boggle/releases) et télécharger la dernière release.

Ensuite, vous pouvez exécuter le programme de la manière suivante : `java -jar ouga-boggle.jar ...` en remplaçant les `...` par les arguments (voir [documentation](https://gaufre.informatique.univ-paris-diderot.fr/crisan/ouga-boggle/blob/main/docs/options.md)).

## Description

Ce logiciel est un jeu de lettres, se déroulant sur une grille. Le but est de
trouver le plus de mots possibles dans la grille. Il peut être joué seul ou à
plusieurs, lentement ou contre la montre, en s'amusant ou en pleurant.

## Règles

Une liste complète des règles peut être trouvée [ici](https://www.boggle.fr/regles.php)

## Fonctionnalités

Voici une liste des fonctionnalités clefs de notre version :

- Un minuteur
- Validation des mots
- Validation des déplacements
- Entrée clavier + entrée souris
- Multijoueur illimité
- Modes de jeu
- Configuration avancé
- Belle interface graphique, utilisant le thème gtk

## Développement

Lancer un serveur :

```bash
./mvnw exec:java -Dexec.args="serveur"
```

Lancer un client :

```bash
./mvnw exec:java -Dexec.args="client -P mon_pseudo"
```

## Développeurs

- Claire Chenillet
- Emilie Lin
- Florian Gaie
- Phillipe Hinault
- Bogdan Crisan
