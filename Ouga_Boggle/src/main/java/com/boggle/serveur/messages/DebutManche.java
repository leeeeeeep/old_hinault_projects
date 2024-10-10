package com.boggle.serveur.messages;

import com.boggle.serveur.jeu.Joueur;
import com.boggle.serveur.plateau.Grille;
import java.util.HashSet;

public class DebutManche {
    private String[][] tableau;
    private int longueurManche;
    private HashSet<Joueur> joueurs;
    private int nMots;

    public DebutManche(Grille grille, int lm, HashSet<Joueur> joueurs) {
        tableau = new String[grille.getLignes()][grille.getColonnes()];
        for (int i = 0; i < grille.getLignes(); i++) {
            for (int j = 0; j < grille.getColonnes(); j++) {
                tableau[i][j] = grille.getGrille()[i][j].lettre;
            }
        }
        longueurManche = lm;
        this.joueurs = joueurs;
        nMots = grille.getNMots();
    }

    public DebutManche(String[][] grille, int lm) {
        tableau = grille;
        longueurManche = lm;
    }

    public String[][] getTableau() {
        return tableau;
    }

    public HashSet<Joueur> getJoueurs() {
        return joueurs;
    }

    public int getLongueurManche() {
        return longueurManche;
    }

    public int getNMots() {
        return nMots;
    }
}
