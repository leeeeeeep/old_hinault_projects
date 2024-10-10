package com.boggle.serveur.jeu;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import com.boggle.serveur.plateau.Coordonnee;
import com.boggle.serveur.plateau.Lettre;
import java.util.LinkedList;
import org.junit.Before;
import org.junit.Test;

public class MancheTest {
    Manche manche;

    @Before
    public void setUp() {
        manche = new Manche(4, 4, 60, Langue.FR, null);

        var g = manche.getGrille().getGrille();

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
    public void creationManche() {
        assertEquals(4, manche.getGrille().getLignes());
        assertEquals(4, manche.getGrille().getColonnes());
        assertEquals(60, manche.getMinuteur().getSec());
    }

    @Test
    public void ajoutMotSouris() {
        Joueur joueur = new Joueur("Bogdan");

        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(manche.getGrille().getGrille()[0][0]);
        lettres.add(manche.getGrille().getGrille()[0][1]);
        lettres.add(manche.getGrille().getGrille()[0][2]);
        lettres.add(manche.getGrille().getGrille()[0][3]);

        manche.ajouterMot(lettres, joueur);

        assertTrue(manche.getListeMots().get(joueur).stream()
                .filter(m -> m.toString().equals("pret"))
                .findFirst()
                .isPresent());
    }

    @Test
    public void ajoutMotClavier() {
        Joueur joueur = new Joueur("Bogdan");

        manche.ajouterMot("pret", joueur);

        assertTrue(manche.getListeMots().get(joueur).stream()
                .filter(m -> m.toString().equals("pret"))
                .findFirst()
                .isPresent());
    }

    @Test
    public void calculPoints() {
        Joueur bogdan = new Joueur("Bogdan");
        Joueur claire = new Joueur("Claire");

        manche.ajouterMot("pret", bogdan);

        manche.ajouterMot("pret", bogdan);

        manche.ajouterMot("tres", claire);

        manche.ajouterMot("pret", claire);

        assertEquals(1, (int) manche.getPoints().get(bogdan));
        assertEquals(2, (int) manche.getPoints().get(claire));
    }
}
