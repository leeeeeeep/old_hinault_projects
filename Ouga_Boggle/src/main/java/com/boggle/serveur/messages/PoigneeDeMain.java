package com.boggle.serveur.messages;

import com.boggle.serveur.Serveur.Client;
import com.boggle.serveur.jeu.Joueur;
import java.util.ArrayList;

public class PoigneeDeMain {
    private ArrayList<Joueur> joueurs;
    private boolean partieDejaCommencee;
    private Continue continuePartie;

    public PoigneeDeMain(ArrayList<Client> joueurs, boolean commnecee, Continue cont) {
        this.joueurs = new ArrayList<Joueur>();
        this.partieDejaCommencee = commnecee;
        this.continuePartie = cont;

        for (Client c : joueurs) {
            this.joueurs.add(c.joueur);
        }
    }

    public ArrayList<Joueur> getJoueurs() {
        return joueurs;
    }

    public boolean partieDejaCommencee() {
        return partieDejaCommencee;
    }

    public Continue getContinuePartie() {
        return continuePartie;
    }
}
