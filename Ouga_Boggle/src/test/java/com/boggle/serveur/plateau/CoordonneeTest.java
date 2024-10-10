package com.boggle.serveur.plateau;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

// L'erreur est due au fait que la classe Jeu essaye
// d'utiliser Serveur mais on ne crée pas de Serveur.
public class CoordonneeTest {
    @Test
    public void creation() {
        Coordonnee c = new Coordonnee(1, 2);
        assertEquals(1, c.x);
        assertEquals(2, c.y);
    }

    @Test
    public void estACoteDe() {
        Coordonnee c1 = new Coordonnee(1, 2);
        Coordonnee c2 = new Coordonnee(2, 2);
        assertTrue(c1.estACoteDe(c2));

        Coordonnee c3 = new Coordonnee(1, 2);
        Coordonnee c4 = new Coordonnee(3, 0);
        assertFalse(c3.estACoteDe(c4));
    }

    @Test
    public void estSur() {
        Coordonnee c1 = new Coordonnee(1, 2);
        Coordonnee c2 = new Coordonnee(1, 2);
        assertTrue(c1.estSur(c2));

        Coordonnee c3 = new Coordonnee(1, 2);
        Coordonnee c4 = new Coordonnee(2, 2);
        assertFalse(c3.estSur(c4));
    }
}
