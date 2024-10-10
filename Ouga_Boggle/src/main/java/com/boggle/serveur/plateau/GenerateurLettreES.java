package com.boggle.serveur.plateau;

public class GenerateurLettreES implements GenerateurLettre {
    public final String occurence = "e".repeat(137)
            + "a".repeat(123)
            + "i".repeat(78)
            + "s".repeat(70)
            + "n".repeat(74)
            + "r".repeat(64)
            + "t".repeat(48)
            + "o".repeat(87)
            + "l".repeat(58)
            + "u".repeat(40)
            + "d".repeat(50)
            + "c".repeat(45)
            + "m".repeat(28)
            + "p".repeat(26)
            + "g".repeat(10)
            + "b".repeat(10)
            + "v".repeat(10)
            + "h".repeat(6)
            + "f".repeat(8)
            + "q".repeat(10)
            + "y".repeat(7)
            + "x".repeat(2)
            + "j".repeat(3)
            + "k".repeat(1)
            + "w".repeat(1)
            + "z".repeat(3);

    /**
     * Donne une lettre aléatoire selon les occurences de l'espagnol
     *
     * @return String
     */
    public String prendreLettreAleatoire() {
        return "" + occurence.charAt((int) (Math.random() * occurence.length()));
    }
}
