# Rapport

## Identifiants

Philippe Hinault 22006949
Bogdan Crisan 22008291

## Fonctionnalités

Tous les modes de jeux ont été implémentés. On peut chercher une solution pour
une graine ou bien vérifier que le fichier passé en parametre est bien une
solution pour cette graine.

## Compilation et exécution

Afin de compiler et exécuter le projet, on peut utiliser le script `./run`.

Le programme prends en paramètre un string qui représente la graine et le mode de jeu.

Ensuite, il prends un deuxième paramètre:
    -check <filename>, vérifie la solution contenue dans le fichier filename
    -search <filename>, écrit la solution dans le fichier filename

Exemples:

```
$ ./run fc.123 -search fc123out.sol # écris la solution dans fc123out.sol
$ ./run fc.123 -check fc123out.sol # vérifie que fc123out.sol est solution de fc.123
```

| Mode de jeu | Nom | Exemple |
| --- | --- | --- |
| Free Cell | `fc` | `fc.123` |
| Baker's Dozen | `bd` | `bd.321` |
| Midnight Oil | `mo` | `mo.1337` |
| Seahaven | `st` | `st.420` |

## Découpage modulaire

Nous n'avons pas vraiment découpé notre code en modules.

Nous avons cependant créé un module pour l'état, qui contient deux fonctions :

- `hash` qui retourne un hash de l'état
- `score` qui retourne le score de l'état

Nous aurions pu ajouter plus de fonctions dans ce module, mais ayant commencé
sans module d'état, nous n'avons pas vu l'utilité de déplacer toutes nos
fonctions alors que nous les avions déjà écrites.

## Organisation du travail

Nous avons travaillé en pair-programming tout au long du projet. Sur un projet
petit de cette taille, cela permet d'avancer beaucoup plus vite. En effet, vu
que le projet est petit, si on le sépare en taches, cela donnerai des taches
bloquantes (i.e. l'autre ne peut pas avancer sur ça tache tant que le premier
n'a pas fini la sienne). C'est pour cela qu'on à privilégié la collaboration en
temps réelle.

Nous avons commencé le jalon 1 dès l'apparition du sujet. Nous avons ensuite
commencé le jalon 2 durant les vacances de Noël et fini un peu avant le nouvel
an.

Sauf erreur de notre part, il n'y a pas eu de confinement.
