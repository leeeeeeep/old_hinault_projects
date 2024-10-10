package com.boggle.serveur.messages;

public class DebutJeu {
    private int nombreManches;

    public DebutJeu(int nombreManches) {
        this.nombreManches = nombreManches;
    }

    public int getNbManches() {
        return nombreManches;
    }
}
