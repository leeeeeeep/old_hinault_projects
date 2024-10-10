package com.boggle.serveur.plateau;

public class GenerateurLettreEN implements GenerateurLettre {
    public final String occurence = "e".repeat(126)
            + "a".repeat(81)
            + "i".repeat(72)
            + "s".repeat(66)
            + "n".repeat(74)
            + "r".repeat(64)
            + "t".repeat(91)
            + "o".repeat(75)
            + "l".repeat(40)
            + "u".repeat(28)
            + "d".repeat(40)
            + "c".repeat(32)
            + "m".repeat(26)
            + "p".repeat(19)
            + "g".repeat(18)
            + "b".repeat(17)
            + "v".repeat(10)
            + "h".repeat(53)
            + "f".repeat(22)
            + "q".repeat(1)
            + "y".repeat(17)
            + "x".repeat(3)
            + "j".repeat(1)
            + "k".repeat(6)
            + "w".repeat(19)
            + "z".repeat(1);

    /**
     * Donne une lettre aléatoire selon les occurences de l'anglais
     *
     * @return String
     */
    public String prendreLettreAleatoire() {
        return "" + occurence.charAt((int) (Math.random() * occurence.length()));
    }
}
