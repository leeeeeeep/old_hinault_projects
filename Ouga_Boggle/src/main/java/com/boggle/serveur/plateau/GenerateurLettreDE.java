package com.boggle.serveur.plateau;

public class GenerateurLettreDE implements GenerateurLettre {
    public final String occurence = "e".repeat(169)
            + "a".repeat(63)
            + "i".repeat(74)
            + "s".repeat(66)
            + "n".repeat(102)
            + "r".repeat(74)
            + "t".repeat(59)
            + "o".repeat(29)
            + "l".repeat(36)
            + "u".repeat(44)
            + "d".repeat(50)
            + "c".repeat(30)
            + "m".repeat(25)
            + "p".repeat(8)
            + "g".repeat(31)
            + "b".repeat(20)
            + "v".repeat(11)
            + "h".repeat(45)
            + "f".repeat(16)
            + "q".repeat(1)
            + "y".repeat(1)
            + "x".repeat(1)
            + "j".repeat(3)
            + "k".repeat(15)
            + "w".repeat(15)
            + "z".repeat(12);

    /**
     * Donne une lettre aléatoire selon les occurences de l'allemand
     *
     * @return String
     */
    public String prendreLettreAleatoire() {
        return "" + occurence.charAt((int) (Math.random() * occurence.length()));
    }
}
