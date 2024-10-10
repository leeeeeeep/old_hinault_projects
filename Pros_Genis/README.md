# Genis

Genis est un dactylo-jeu extensivement configurable.

## Lancement

Nous avons utilisé l'outil `gradle`. Afin de lancer le projet, il suffit de
faire `./gradlew run`.

Il est également possible de passer des arguments au programme de la manière
suivante : `./gradlew run --args="my args"`.

La ligne de commande fonctionne de manière similaire à `git`. Elle prends tout
d'abord une commande (`words`, `timed` ou `game`) qui représente des modes de
jeu, puis des options spécifiques à chaque mode de jeu. Ceci est expliqué plus
en détail en dessous.

Il n'y a malheureusement pas de tests, faute de temps.

## Fonctionnalités

### Modes de jeux

Le projet comporte quatres modes de jeux implémentés :

- Timed (un mode de jeu qui se finit après un certain temps)
- Words (un mode de jeu qui se finit après un certain nombre de mots tapés)
- Game (un mode de jeu qui se finit quand le joueur n'a plus de vies)
- Multi (un mode en multi)

### Configuration

Chaque mode de jeu est hautement configurable afin que chaque utilisateur
puisse expérimenter le jeu de la manière dont il préfère.

Une liste exhaustive des options est possible en faisant `./gradlew run
--args="--help"` (ou juste `./gradlew run`).

Celles-ci incluent notamment une option pour activer un thème sombre, régler le
nombre de mots en mode Words, régler la durée de la partie en mode Timed,
l'accélération de la difficulté en mode Game, etc…

## Décisions techniques

*En vue des nombreux projets et examens auquel nous faisons face, le facteur
temps fut grand dans nos décisions.*

Nous avons utilisé l'héritage dans les modes de jeu ainsi que dans les vues afin
de factoriser à maximum le code.

Nous avons aussi séparé le code de manière logique et atomique, afin de
faciliter les tests (que nous n'avons finalement pas eu le temps de faire) et
l'ajout de fonctionnalités.

Le mode multijoueur est legerement baclé à cause du facteur temps.

Nous avons choisi d'utiliser les websockets, afin de laisser la porte ouverte à
une implémentation dans un navigateur.

Nous utilisons un serveur très sympliste, qui se contente de relayer les
informations envoyés par les clients aux autres clients.

Pour lancer le serveur, nous avons un deuxième main dans `Server.java`. Pour le
lancer, faire: `./gradlew server --args="…"`.

## Exemples de ligne de commande

```bash
$ genis words # lance une partie en mode words
$ genis timed -t 10 # lance une partie en mode timed de 10 secondes
$ genis -d g -b 0.3 # lance une partie en mode game (g est un raccourci)
                    # avec 3 chances sur 10 de tomber sur un mot bonus
                    # en dark mode
$ server -P password # lance un serveur avec le mode de passe "password"
                     # sur le port par defaut (6942)
$ genis mgc -n XxDarkThibaultxX -P password # lance un client avec le
                                            # mot de passe "password",
                                            # le pseudo "XxDarkThibaultxX"
                                            # et le host et port par defaut
                                            # (localhost et 6942)
```

## Notes

À cause d'un bug venant de la librairie RichText, les caractères qui se tapent
avec des touches mortes (ê, ô, ï, ...) ne marchent pas sur Linux. Cependant, on
a décidé de les laisser car certaines dispositions de clavier tel que bépo ne
rencontrent pas ce problème grâce à la quasi absence de touches mortes.
