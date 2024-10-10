package com.boggle.serveur.messages;

public class Connexion {
    private String pseudo;
    private boolean estConnected;

    public Connexion(String pseudo, boolean isConnected) {
        this.pseudo = pseudo;
        this.estConnected = isConnected;
    }

    public String getPseudo() {
        return pseudo;
    }

    public boolean estConnected() {
        return estConnected;
    }
}
