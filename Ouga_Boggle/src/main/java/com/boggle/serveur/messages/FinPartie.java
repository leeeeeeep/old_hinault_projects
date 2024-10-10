package com.boggle.serveur.messages;

import com.boggle.serveur.jeu.Joueur;
import java.util.List;

public class FinPartie {
    private List<Joueur> gagnants;

    public FinPartie(List<Joueur> gagnants) {
        this.gagnants = gagnants;
    }

    public List<Joueur> getGagnants() {
        return gagnants;
    }
}
