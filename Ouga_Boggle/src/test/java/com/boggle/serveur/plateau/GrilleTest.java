package com.boggle.serveur.plateau;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import com.boggle.serveur.jeu.Langue;
import java.util.LinkedList;
import org.junit.Before;
import org.junit.Test;

public class GrilleTest {
    Grille grille;

    @Before
    public void setUp() {
        grille = new Grille(4, 4, Langue.FR);

        var g = grille.getGrille();

        g[0][0] = new Lettre(new Coordonnee(0, 0), "p");
        g[0][1] = new Lettre(new Coordonnee(0, 1), "r");
        g[0][2] = new Lettre(new Coordonnee(0, 2), "e");
        g[0][3] = new Lettre(new Coordonnee(0, 3), "t");
        g[1][0] = new Lettre(new Coordonnee(1, 0), "p");
        g[1][1] = new Lettre(new Coordonnee(1, 1), "r");
        g[1][2] = new Lettre(new Coordonnee(1, 2), "r");
        g[1][3] = new Lettre(new Coordonnee(1, 3), "t");
        g[2][0] = new Lettre(new Coordonnee(2, 0), "p");
        g[2][1] = new Lettre(new Coordonnee(2, 1), "r");
        g[2][2] = new Lettre(new Coordonnee(2, 2), "e");
        g[2][3] = new Lettre(new Coordonnee(2, 3), "t");
        g[3][0] = new Lettre(new Coordonnee(3, 0), "p");
        g[3][1] = new Lettre(new Coordonnee(3, 1), "p");
        g[3][2] = new Lettre(new Coordonnee(3, 2), "s");
        g[3][3] = new Lettre(new Coordonnee(3, 3), "p");
    }

    @Test
    public void creationGrilleInvalide() {
        var erreur = false;
        try {
            new Grille(-1, -1, Langue.FR);
        } catch (IllegalArgumentException e) {
            erreur = true;
        }
        assertTrue(erreur);
    }

    @Test
    public void creationGrille() {
        assertEquals(4, grille.getLignes());
        assertEquals(4, grille.getColonnes());
        assertEquals(Langue.FR, grille.getLangue());
    }

    @Test
    public void ajoutMotsClavier() {
        Mot pret = grille.ajouterMot("pret");
        assertNotNull(pret);
        assertEquals("pret", pret.toString());
        Mot tres = grille.ajouterMot("tres");
        assertNotNull(tres);
        assertEquals("tres", tres.toString());
    }

    @Test
    public void ajoutMotsClavierInvalide() {
        assertNull(grille.ajouterMot("constitution"));
        assertNull(grille.ajouterMot(""));
    }

    @Test
    public void ajoutMotsSouris() {
        LinkedList<Lettre> lettresPret = new LinkedList<>();
        lettresPret.add(grille.getGrille()[0][0]);
        lettresPret.add(grille.getGrille()[0][1]);
        lettresPret.add(grille.getGrille()[0][2]);
        lettresPret.add(grille.getGrille()[0][3]);

        Mot pret = grille.ajouterMot(lettresPret);
        assertNotNull(pret);
        assertEquals("pret", pret.toString());

        LinkedList<Lettre> lettresTres = new LinkedList<>();
        lettresTres.add(grille.getGrille()[0][3]);
        lettresTres.add(grille.getGrille()[1][2]);
        lettresTres.add(grille.getGrille()[2][2]);
        lettresTres.add(grille.getGrille()[3][2]);
        Mot tres = grille.ajouterMot(lettresTres);
        assertNotNull(tres);
        assertEquals("tres", tres.toString());
    }

    @Test
    public void ajoutMotsSourisInvalide() {
        LinkedList<Lettre> lettresTrep = new LinkedList<>();
        lettresTrep.add(grille.getGrille()[0][3]);
        lettresTrep.add(grille.getGrille()[1][2]);
        lettresTrep.add(grille.getGrille()[2][2]);
        lettresTrep.add(grille.getGrille()[3][3]);
        Mot trep = grille.ajouterMot(lettresTrep);
        assertNull(trep);

        LinkedList<Lettre> lettresTret = new LinkedList<>();
        lettresTret.add(grille.getGrille()[0][3]);
        lettresTret.add(grille.getGrille()[1][2]);
        lettresTret.add(grille.getGrille()[2][2]);
        lettresTret.add(grille.getGrille()[0][0]);
        Mot tret = grille.ajouterMot(lettresTret);
        assertNull(tret);

        LinkedList<Lettre> lettresTete = new LinkedList<>();
        lettresTete.add(grille.getGrille()[0][3]);
        lettresTete.add(grille.getGrille()[0][2]);
        lettresTete.add(grille.getGrille()[0][3]);
        lettresTete.add(grille.getGrille()[0][2]);
        Mot tete = grille.ajouterMot(lettresTete);
        assertNull(tete);

        LinkedList<Lettre> lettresTest = new LinkedList<>();
        lettresTete.add(new Lettre(new Coordonnee(0, 0), "t"));
        lettresTete.add(new Lettre(new Coordonnee(0, 1), "e"));
        lettresTete.add(new Lettre(new Coordonnee(0, 2), "s"));
        lettresTete.add(new Lettre(new Coordonnee(0, 3), "t"));
        Mot test = grille.ajouterMot(lettresTest);
        assertNull(test);
    }
}
