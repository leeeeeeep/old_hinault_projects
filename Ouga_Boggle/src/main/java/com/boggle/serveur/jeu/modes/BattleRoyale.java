package com.boggle.serveur.jeu.modes;

import com.boggle.serveur.ServeurInterface;
import com.boggle.serveur.jeu.Joueur;
import com.boggle.serveur.jeu.Langue;
import com.boggle.serveur.jeu.Manche;
import java.util.ArrayList;

public class BattleRoyale extends Normal {

    public BattleRoyale(
            int dureeManche, int tailleVerticale, int tailleHorizontale, Langue langue, ServeurInterface serveur) {
        super(0, dureeManche, tailleVerticale, tailleHorizontale, langue, serveur);
    }

    public void nouvelleManche() {
        demarrerManche(new Manche(this.tailleVerticale, this.tailleHorizontale, this.dureeManche, this.langue, this));
    }

    public void finDeManche() {
        eliminerDerniers();
    }

    private void eliminerDerniers() {
        ArrayList<Joueur> perdants = new ArrayList<>();
        int pointsPerdant = 0;
        for (var entry : getPoints().entrySet()) {
            var joueur = entry.getKey();
            if (getJoueurs().contains(joueur)) {
                var points = entry.getValue();
                if (perdants.isEmpty()) {
                    perdants.add(joueur);
                    pointsPerdant = points;
                } else if (points < pointsPerdant) {
                    perdants.clear();
                    pointsPerdant = points;
                    perdants.add(joueur);
                } else if (points <= pointsPerdant) {
                    perdants.add(joueur);
                }
            }
        }
        ;
        if (perdants.size() < getJoueurs().size()) {
            for (var perdant : perdants) {
                serveur.annoncerElimination(perdant.nom);
                enleverJoueur(perdant);
            }
        }
    }

    public boolean estFini() {
        return getJoueurs().size() == 1;
    }
}
