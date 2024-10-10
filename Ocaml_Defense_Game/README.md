Projet Long
===============

### Sujet ###
Jeu de plateau.  
Détail des règles dans rules.md

### Objectifs / Difficultées ###
principaux :
- génération aléatoire d'un terrain (sous forme de matrice)
- implementation d'un BFS pour le déplacement des unitées
- implémentation d'une IA qui peut défendre et attaquer 
- - difficulter car le jeu n'est pas en tour par tour.
- développement de l'interface graphique

suplémentaire :
- le terrain peut étre un graphe plannaire quelconque
- le graphe planaire est généré aléatoirement
- disponible sur Androide

### Critères de réussite/testabilité ###
Reussite :
- L'interface graphique est-elle fonctionnelle ?
- Les unitées peuvent-elles se déplacer / se battre / être posées sur le plateau ?
- Le terrain peut-il être généré aléatoirement ?
- Le jeu est-il fluide ? (moins de deux secondes entre chaque unité de temps)
- Le jeu peut-il terminer ?
- Un joueur peut-il affronter une IA ?

### Langage ###
Ocaml 

### Agenda ###
Voir fichier planning.svg
apres une prise de retard un nouveau planning a été proposé dans rapport/planning.svg

### Différences ###
- Par rapport au projet : https://www.jiahaoz.com/caml-defense
  - le défenceur n'utilise pas de tour mais des unitées, elles peuvent donc se déplacer et mourir.
  - les joueurs sont sensibles au brouillard de guerre (vision incomplète de la carte).
  - le terrain est généré aléatoirement.
- Par rapport aux idées de : https://stackoverflow.com/questions/35893287/avoiding-object
  - nous n'utilisons pas de modules pour représenter les unitées

  (De facon tout a fait franche, ces differences ne sont peut etre pas vrai ou exhaustive. Pour les connaitre plus précisement il faudrait se pencher sur ces projets, mais l'energie nous manque. Nous vous assurons en revanche que nous ne nous sommes pas inspirer ni n'avons plagier ces projets.)

### Librairie externe ###  
- yojson
- lwt
- raylib

### Diagramme module ###
Voir fichier : diagramme.png

### Origine de code réutiliser ###
Pour le Bruit de Perlin :
https://rosettacode.org/wiki/Perlin_noise

Pour le zoom de la camera :
https://github.com/raysan5/raylib/blob/master/examples/core/core_2d_camera_mouse_zoom.c

### Commande ###
Executable dans le dossier game :
- exec le main :- $ dune exec game
- run test perlin :- $ dune run test_perlin/
- test des constructeurs :- $ dune run test/