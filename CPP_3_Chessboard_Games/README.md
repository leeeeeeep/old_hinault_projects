# Projet Langage Objet Avancé 2023

Binôme n°88
HINAULT Philippe 22006949
LIN Emilie 22006658

## Introduction
Ce projet consiste à programmer 3 jeux qui sont similaires sur un damier.

Pour ce projet nous avons choisi les jeux suivants :
- Butin
- Les Dames
- Safari

## Compiler et lancer
Pour compiler :
```
make
```

Pour lancer
```
./main
```

## Comment utiliser l'interface de jeu:
L'utilisateur peut interagir avec l'interface graphique en cliquant sur les cases et il peut 
valider son tour en cliquant sur le bouton `Passer son tour`.

### Dames
Le joueur 1 commence: les blancs

cliquer sur une pièce puis sur une destination

indice sur le terminal: 
    -mouvement possible correspond au pieces qui peuvent jouer
    -mouvement obligatoire correspond au piece qui doivent obligatoirement jouer  

Le choix est bloquant, si on touche à une piece valide, on ne peut plus la changer
en cas de mouvement raté, recliquer sur la même piece puis la destination 

puis le bouton `Passer son tour` pour passer son tour et manger les pieces prises
le `Passer son tour` est impossible tant que la prise est possible ou si aucun action a été 
faite

la resélection de la piece est obligatoire lors d'une rafle


### Safari
Le joueur 0 commence

Les cases blanches sont des cases où l'on peut poser des animaux, 
les cases rouges les barrières
les cases avec du noir possèdent une barrière 

A l'initialisation, le joueur 0 pose 3 animaux, puis sa barrière
le second joueur aussi 
le troisième aussi 
Pas besoin de `Passer son tour` dans l'initialisation 

Après l'initialisation on passe directement au joueur 0 qui peut jouer 

On clique sur un animal du joueur, on déplace vers une case vide pour le déplacement
on pose sa barrière ensuite

Pas besoin de faire des angles droits avec les barrières pour encercler un animal

## Butin 
le joueur qui débute est aléatoire.
juste après l'initialisation, on peut jouer directement sans `Passer son tour`.

si on a fait une action, on peut `Passer son tour` pour passer son tour 
la resélection est obligatoire lors de mouvements successifs.