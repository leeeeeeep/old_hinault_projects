## 10/11/2023

- first meeting to to spur discussion about agenda and definitions for game

- TODO
- agenda / jalons
- add details about the components of the videogame in the README.md
- definitions of types to reason on the state of a match

## 1/12/2023, DEGORRE

À propos des jalons : Commencer par développer des modules non intégrés et seulement vérifiés par des tests unitaires est très risqué car cela ne permet pas de tester la pertinence et la cohérente de chaque module avant la fin du projet. Il faut donc avoir très tôt un jeu qui fonctionne (en faisant très peu de choses) et ajouter les différentes fonctionnalités du jeu une à une par la suite.

Pour le sujet en lui-même : un Tower Defense avec des unités qui bougent, pour moi c'est un RTS. Les RTS permettent des développements riches et intéressants. Je pense que c'est une bonne idée. (@gio, est-ce que tu crains toujours le plagiat avec le modifications proposées?). Il faut cependant être clair : qu'est-ce qui fait que votre projet reste malgré tout un Tower Defense ? Spécifiez plus le game play.

Il faut aussi expliciter la stratégie de test.

Expliciter quels algorithmes seront probablement utilisés (pour la génération, la planification des déplacements des unités, etc.).

## 13/3/2024, DEGORRE

### Fait

fenêtre, menu principal, écran de jeu avec zoom et affichage de pions multiple, bouton move mais sans effet sur le plateau

(2 à 3 mois de retard sur le planning)

### À faire

- réajuster le planning
- ajouter critères de réussite/testabilité
- continuer ce qui est prévu (qui semble raisonnable... mais il faut vraiment s'y mettre)
- reprendre rendez-vous d'ici 3 semaines

## 6/5/2024

### Fait

- multi-thread (gestion UI dans thread séparé)
- calculs de chemins
- unités ennemies aléatoires
- achats d'unités
- (en cours, pas intégré) calcul de vision

### À faire

- merger ce qui est en cours
- génération aléatoire (tester correction et quantité effective de hasard/entropie)
- IA (tester sur un certains nombre de scenarii)
