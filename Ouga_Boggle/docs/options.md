# Paramètres

Sur cette page sont présentés les différents paramètres de Ouga Boggle, et comment les configurer.

## Catégories

Il y a 4 catégories de paramètres :

- les paramètres spécifiques au serveur
- les paramètres spécifiques au client
- les paramètres spécifiques à l'affichage de l'historique
- les paramètres communs

Afin de lancer le programme en ligne de commande, il faut utiliser la syntaxe suivante : `ouga-boggle [paramètres communs] <serveur/client/historique> [paramètres spécifiques]`

Afin de lancer le programme et de le configurer avec une interface graphique, il faut utiliser la syntaxe suivante : `ouga-boggle --gui <serveur/client>`

### Les paramètres spécifiques au serveur

| Nom         | Description                                                      | Ligne de commande     | Interface | Valeur par défaut |
|-------------|------------------------------------------------------------------|-----------------------|-----------|-------------------|
| Joueurs max | le nombre maximal de joueurs qui peuvent se connecter au serveur | `-j`, `--joueurs-max` | oui       | `10`              |

### Les paramètres spécifiques au client

| Nom        | Description                                 | Ligne de commande | Interface | Valeur par défaut |
|------------|---------------------------------------------|-------------------|-----------|-------------------|
| Hôte       | l'adresse (nom de domaine ou IP) du serveur | `-h`, `--host`    | oui       | `127.0.0.1`       |
| Pseudonyme | le pseudonyme du joueur                     | `-P`, `--pseudo`  | oui       | non               |

### Les paramètres spécifiques à l'historique

| Nom     | Description                      | Ligne de commande           | Valeur par défaut |
|---------|----------------------------------|-----------------------------|-------------------|
| Mots    | afficher ou non les mots trouvés | `-m`, `--afficher-mots`     | non               |
| Joueurs | nombre de joueurs a afficher     | `-j`, `--nombre-de-joueurs` | 10                |
| Parties | nombre de parties a afficher     | `-n`, `--nombre-de-parties` | 10                |

### Les paramètres communs

| Nom                 | Description                                               | Ligne de commande      | Interface | Valeur par défaut         |
|---------------------|-----------------------------------------------------------|------------------------|-----------|---------------------------|
| Port                | permet de définir le port du serveur                      | `-p`, `--port`         | oui       | `8080`                    |
| Mot de passe        | permet de définir le mot de passe de connexion au serveur | `-w`, `--mot-de-passe` | oui       | vide                      |
| Interface graphique | définit s'il faut utiliser une interface graphique ou non | `-g`, `--gui`          | non       | pas d'interface graphique |

## Exemples

Lancer un serveur et le configurer en interface graphique :

`ouga-boggle --gui serveur`

Lancer un client et le configurer en interface graphique :

`ouga-boggle --gui client`

Lancer un serveur avec un maximum de 10 joueurs, sur le port 5678 avec le mot de passe "ciel" :

`ouga-boggle -p 5678 -w ciel serveur -j 10`

Lancer un client qui se connecte au serveur example.com sur le port 5678 avec le mot de passe "ciel" avec le pseudonyme "CRBl_" :

`ouga-boggle -p 5678 -w ciel client -h example.com -P CRBl_`

Affiche l'historique des 10 dernières parties, affichant les 10 premiers joueurs de chaque partie :

`ouga-boggle historique`

Affiche l'historique des 3 dernières parties, affichant les 4 premiers joueurs de chaque partie et les mots qu'ils ont trouvé :

`ouga-boggle historique -n 3 -j 4 -m`

## La configuration du jeu

Tout ce qui est relatif aux règles est configuré par le chef du lobby (le premier joueur qui s'est connecté au serveur) dans lobby.

Les différentes options sont :

| Nom                 | Description                                      | Valeur par défaut |
|---------------------|--------------------------------------------------|-------------------|
| Nombre de manches   | le nombre de manches dans un jeu                 | 3                 |
| Minuteur            | le temps que dure une manche en secondes         | 60                |
| Taille de la grille | la taille de la grille en horizontal et vertical | 4x4               |
| Langue              | la langue utilisé dans le jeu                    | Français          |
| Mode de jeu         | le mode de jeu                                   | Normal            |
