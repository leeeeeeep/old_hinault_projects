package com.boggle.serveur.plateau;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

// L'erreur est due au fait que la classe Jeu essaye
// d'utiliser Serveur mais on ne crée pas de Serveur.
public class LettreTest {
    @Test
    public void creation() {
        Lettre l = new Lettre(new Coordonnee(0, 0), "a");
        assertEquals("a", l.lettre);
        assertEquals(0, l.coord.x);
        assertEquals(0, l.coord.y);
    }

    @Test
    public void estACoteDe() {
        Lettre l1 = new Lettre(new Coordonnee(0, 0), "a");
        Lettre l2 = new Lettre(new Coordonnee(0, 1), "a");
        assertTrue(l1.estACoteDe(l2));

        Lettre l3 = new Lettre(new Coordonnee(0, 0), "a");
        Lettre l4 = new Lettre(new Coordonnee(3, 2), "a");
        assertFalse(l3.estACoteDe(l4));
    }

    @Test
    public void estSur() {
        Lettre l1 = new Lettre(new Coordonnee(0, 0), "a");
        Lettre l2 = new Lettre(new Coordonnee(0, 0), "a");
        assertTrue(l1.estSur(l2));

        Lettre l3 = new Lettre(new Coordonnee(0, 0), "a");
        Lettre l4 = new Lettre(new Coordonnee(3, 2), "a");
        assertFalse(l3.estSur(l4));
    }

    @Test
    public void fonctionToString() {
        Lettre l = new Lettre(new Coordonnee(0, 0), "a");
        assertEquals("a", l.toString());
    }
}
