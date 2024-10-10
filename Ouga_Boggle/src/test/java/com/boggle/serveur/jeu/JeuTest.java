package com.boggle.serveur.jeu;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import com.boggle.serveur.ServeurInterface;
import com.boggle.serveur.jeu.modes.Normal;
import com.boggle.serveur.plateau.Coordonnee;
import com.boggle.serveur.plateau.Lettre;
import java.util.LinkedList;
import org.junit.Before;
import org.junit.Test;

// L'erreur est due au fait que la classe Jeu essaye
// d'utiliser Serveur mais on ne crée pas de Serveur.
public class JeuTest {
    ServeurInterface serveur = null;

    @Before
    public void setUp() {
        serveur = new ServeurInterface() {
            public void annoncerDebutPartie() {}

            public void annoncerFinPartie() {}

            public void annoncerDebutManche() {}

            public void annoncerFinManche() {}

            public void annoncerMotTrouve(String nom) {}

            public void annoncerElimination(String nom) {}

            public void finirJeu() {}
            ;
        };
    }

    @Test
    public void creationDeJeu() {
        var jeu = new Normal(3, 60, 4, 4, Langue.FR, serveur);

        jeu.demarrerJeu();

        assertEquals(4, jeu.getGrille().getColonnes());
        assertEquals(4, jeu.getGrille().getLignes());

        var erreur = false;
        try {
            new Normal(-1, -1, -1, -1, Langue.FR, serveur);
        } catch (IllegalArgumentException e) {
            erreur = true;
        }
        assertTrue(erreur);
    }

    @Test
    public void ajouterJoueur() {
        Jeu jeu = new Normal(3, 60, 4, 4, Langue.FR, serveur);

        jeu.ajouterJoueur(new Joueur("Bogdan"));
        assertTrue(jeu.getJoueurs().size() == 1);

        jeu.ajouterJoueur(new Joueur("Claire"));
        assertEquals(2, jeu.getJoueurs().size());
    }

    @Test
    public void ajouterMotTrouve() {
        Jeu jeu = new Normal(3, 60, 4, 4, Langue.FR, serveur);
        Joueur joueur = new Joueur("Bogdan");
        jeu.ajouterJoueur(joueur);

        jeu.demarrerJeu();

        var grille = jeu.getMancheCourante().getGrille().getGrille();

        grille[0][0] = new Lettre(new Coordonnee(0, 0), "p");
        grille[0][1] = new Lettre(new Coordonnee(0, 1), "r");
        grille[0][2] = new Lettre(new Coordonnee(0, 2), "e");
        grille[0][3] = new Lettre(new Coordonnee(0, 3), "t");

        LinkedList<Lettre> lettres = new LinkedList<>();
        lettres.add(jeu.getMancheCourante().getGrille().getGrille()[0][0]);
        lettres.add(jeu.getMancheCourante().getGrille().getGrille()[0][1]);
        lettres.add(jeu.getMancheCourante().getGrille().getGrille()[0][2]);
        lettres.add(jeu.getMancheCourante().getGrille().getGrille()[0][3]);
        jeu.ajouterMot(lettres, joueur);

        assertEquals(1, (int) (jeu.getPoints().get(joueur)));
        assertEquals(1, jeu.getListeMots().get(joueur).size());
    }

    @Test
    public void joueurGagnants() {
        Jeu jeu = new Normal(3, 60, 4, 4, Langue.FR, serveur);
        Joueur joueur1 = new Joueur("Bogdan");
        Joueur joueur2 = new Joueur("Claire");
        jeu.ajouterJoueur(joueur1);
        jeu.ajouterJoueur(joueur2);

        jeu.demarrerJeu();

        assertEquals(0, jeu.getJoueurGagnant().size());

        var grille = jeu.getMancheCourante().getGrille().getGrille();

        grille[0][0] = new Lettre(new Coordonnee(0, 0), "p");
        grille[0][1] = new Lettre(new Coordonnee(0, 1), "r");
        grille[0][2] = new Lettre(new Coordonnee(0, 2), "e");
        grille[0][3] = new Lettre(new Coordonnee(0, 3), "t");

        jeu.ajouterMot("pret", joueur1);
        assertEquals(joueur1, jeu.getJoueurGagnant().get(0));
    }
}
