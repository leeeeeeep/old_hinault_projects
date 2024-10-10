# Spécification de la communication serveur - client

## Messages client ⇒ serveur

| Mot clef     | Description                           | Structure                                                                        |
|--------------|---------------------------------------|----------------------------------------------------------------------------------|
| `status`     | Indique que le joueur est pret ou pad | `{ status: boolean }`                                                            |
| `motSouris`  | Envoie un mot entré à la souris.[^1]  | `{ id: string, lettres: { lettre: string, coord: { x: number, y: number } }[] }` |
| `motClavier` | Envoie un mot entré au clavier.[^1]   | `{ id: string, mot: string }`                                                    |
| `message`    | Envoie un message de chat.            | `{ message: string }`                                                            |

## Messages serveur ⇒ client

### Objets JSON

```typescript
type Configuration = {
    nombreManches: number,
    dureeManche: number, // En secondes.
}

/**
 * Décrit une manche qui s'est finie.
 * Sert à communiquer les informations relatives
 * aux autres joueurs à tous les joueurs.
 */
type MancheFinie = {
    joueurs : {
        pseudo: string,     // Nom du joueur.
        points: number,     // Nombres de points.
        mots: {             // Les mots trouvés par le joueur.
            mot: string,    // Le mot.
            points: number  // Le nombre de points que vaut le mot.
            coordonees: {   // Les coordonées ou a été trouvé le mot.
                x: number,
                y: number
            }[]
        },
    }[]
};
```

| Mot clef      | Description                                                              | Structure                                       |
|---------------|--------------------------------------------------------------------------|-------------------------------------------------|
| `connexion`   | Indique qu'un joueur a rejoint ou quitté la partie.                      | `{ nom: string, estConnected: boolean }`        |
| `status`      | Indique qu'un joueur est prêt ou pas.                                    | `{ nom: string, status: boolean }`              |
| `debutJeu`    | Indique que la partie commence.                                          | `{ nombreManches: int }`                        |
| `finJeu`      | Indique que la partie est finie.                                         | `{ gagnants: { nom: string }[] }`               |
| `debutManche` | Indique que qu'une manche commence.                                      | `{ tableau: string[][] }`                       |
| `finManche`   | Indique qu'une manche s'est finie.                                       | `MancheFinie`                                   |
| `motTrouve`   | Indique qu'un joueur a trouvé un mot.                                    | `{ nom: string }`                               |
| `motVerifie`  | Indique que le mot envoyé par l'utilisateur a été accepté ou refusé.[^1] | `{ id: string, accepte: boolean, points: int }` |
| `message`     | Indique qu'un joueur a envoyé un message                                 | `{ nom: string, message: string }`              |
| `elimination` | Indique qu'un joueur a été éliminé.                                      | `nom: string`                                   |

[^1]: Un `id` est utilisé afin de savoir quel mot a été vérifié.

## Notions

Un joueur est identifié par son nom unique.

Les informations relatives à la configuration sont transmises au début du jeu
(`debutJeu`) et ne changent pas avant la fin du jeu (`finJeu`). Elles peuvent
cependant changer entre deux parties différentes.

Au début de chaque manche, le tableau de lettres est transmis aux joueurs. Ce
dernier ne change pas au cours de la manche. À la fin de la manche, les mots
trouvés par les autres joueurs ainsi que leur score est transmis.

Les joueurs peuvent rejoindre la partie si le jeu n'a pas encore commencé. Les
joueurs peuvent quitter le jeu à tout moment, et se reconnecter.

