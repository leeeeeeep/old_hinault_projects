package com.boggle.serveur.plateau;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import com.boggle.serveur.dictionnaire.Dictionnaire;
import com.boggle.serveur.jeu.Langue;
import java.util.LinkedList;
import org.junit.Test;

public class MotTest {
    @Test
    public void creationMotExistant() {
        Dictionnaire.generer(Langue.FR);
        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(new Lettre(new Coordonnee(0, 0), "t"));
        lettres.add(new Lettre(new Coordonnee(0, 1), "e"));
        lettres.add(new Lettre(new Coordonnee(0, 2), "s"));
        lettres.add(new Lettre(new Coordonnee(0, 3), "t"));

        var erreur = false;
        try {
            new Mot(lettres);
        } catch (Exception e) {
            erreur = true;
        }
        assertFalse(erreur);
    }

    @Test
    public void creationMotNonExistant() {
        Dictionnaire.generer(Langue.FR);
        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(new Lettre(new Coordonnee(0, 0), "t"));
        lettres.add(new Lettre(new Coordonnee(0, 1), "e"));
        lettres.add(new Lettre(new Coordonnee(0, 2), "s"));
        lettres.add(new Lettre(new Coordonnee(0, 3), "t"));
        lettres.add(new Lettre(new Coordonnee(0, 4), "t"));

        var erreur = false;
        try {
            new Mot(lettres);
        } catch (Exception e) {
            erreur = true;
        }
        assertTrue(erreur);
    }

    @Test
    public void fonctionToString() {
        Dictionnaire.generer(Langue.FR);
        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(new Lettre(new Coordonnee(0, 0), "t"));
        lettres.add(new Lettre(new Coordonnee(0, 1), "e"));
        lettres.add(new Lettre(new Coordonnee(0, 2), "s"));
        lettres.add(new Lettre(new Coordonnee(0, 3), "t"));

        Mot mot = new Mot(lettres);

        assertEquals("test", mot.toString());
    }

    @Test
    public void fonctionGetLettres() {
        Dictionnaire.generer(Langue.FR);
        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(new Lettre(new Coordonnee(0, 0), "t"));
        lettres.add(new Lettre(new Coordonnee(0, 1), "e"));
        lettres.add(new Lettre(new Coordonnee(0, 2), "s"));
        lettres.add(new Lettre(new Coordonnee(0, 3), "t"));

        Mot mot = new Mot(lettres);

        assertEquals("t", mot.getLettres().get(0).lettre);
        assertEquals("e", mot.getLettres().get(1).lettre);
        assertEquals("s", mot.getLettres().get(2).lettre);
        assertEquals("t", mot.getLettres().get(3).lettre);
    }

    @Test
    public void fonctionGetPoints() {
        Dictionnaire.generer(Langue.FR);
        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(new Lettre(new Coordonnee(0, 0), "t"));
        lettres.add(new Lettre(new Coordonnee(0, 1), "e"));
        lettres.add(new Lettre(new Coordonnee(0, 2), "s"));
        lettres.add(new Lettre(new Coordonnee(0, 3), "t"));

        Mot mot = new Mot(lettres);

        LinkedList<Lettre> lettres2 = new LinkedList<>();
        lettres2.add(new Lettre(new Coordonnee(0, 0), "m"));
        lettres2.add(new Lettre(new Coordonnee(0, 1), "a"));
        lettres2.add(new Lettre(new Coordonnee(0, 2), "i"));
        lettres2.add(new Lettre(new Coordonnee(0, 3), "s"));
        lettres2.add(new Lettre(new Coordonnee(0, 4), "o"));
        lettres2.add(new Lettre(new Coordonnee(0, 5), "n"));

        Mot mot2 = new Mot(lettres2);

        assertEquals(1, mot.getPoints());
        assertEquals(3, mot2.getPoints());
    }
}
