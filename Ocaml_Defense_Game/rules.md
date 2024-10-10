Jeu simultané à somme null.

Jeu à deux joueurs. (dont un est une IA)  
Support de jeu : un graphe (matrice)

### But ###
Un joueur (D) doit empécher l'autre joueur (A) d'atteindre un sommet (T) du graphe. 

### Victoire ###
- A gagne s'il arrive à atteindre T.
- D gagne A n'a pas atteind T au bout du temps impartie

### Etat initial ###
- Générer un graphe connexe (M).
- Chaque sommet a une valeur (type du terrain), connait les unitées de A et D présentes, et peut ne pas être vu par (D).

### Déroulement de la partie ###
- D controle ses unitées. Il peut les acheter, les deplacer.
- A ne controle pas ses unitées. Il peut placé ses unitées sur un sous graphe (SM) de M.
- Une fois placé, les unitées de A trouvent un chemin pour atteindre T et commence a se déplacé en le suivant.
- D peut construire des murs, un murs est infranchissable et bloque la vision de D

### NB ###
- Les unitées de A comme de D attaquent automatiquement l'unité adverse la plus proche de T. Les unitées de D ne peuvent que cibler les unitées visibles de A.
- Les caractéristiques d'une unité sont : sa vitesse de déplacement, sa jauge de vie, son attaque, sa vision, sa portée d'attaque, sa vitesse d'attaque
- D est sensibles au brouillard de guerre.