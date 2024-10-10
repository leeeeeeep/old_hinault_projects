package com.boggle.serveur.plateau;

public class GenerateurLettreFR implements GenerateurLettre {
    public final String occurence = "e".repeat(115)
            + "a".repeat(67)
            + "i".repeat(62)
            + "s".repeat(61)
            + "n".repeat(60)
            + "r".repeat(57)
            + "t".repeat(56)
            + "o".repeat(47)
            + "l".repeat(47)
            + "u".repeat(42)
            + "d".repeat(34)
            + "c".repeat(30)
            + "m".repeat(24)
            + "p".repeat(23)
            + "g".repeat(11)
            + "b".repeat(10)
            + "v".repeat(10)
            + "h".repeat(10)
            + "f".repeat(10)
            + "q".repeat(6)
            + "y".repeat(4)
            + "x".repeat(3)
            + "j".repeat(3)
            + "k".repeat(2)
            + "w".repeat(1)
            + "z".repeat(1);

    /**
     * Donne une lettre aléatoire selon les occurences de la langue française
     *
     * @return String
     */
    public String prendreLettreAleatoire() {
        return "" + occurence.charAt((int) (Math.random() * occurence.length()));
    }
}
