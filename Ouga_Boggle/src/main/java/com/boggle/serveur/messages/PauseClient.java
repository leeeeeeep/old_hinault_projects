package com.boggle.serveur.messages;

public class PauseClient {
    private String auteur;
    private boolean pause;
    private int restants;

    public PauseClient(String auteur, boolean pause, int restants) {
        this.auteur = auteur;
        this.pause = pause;
        this.restants = restants;
    }

    public String getAuteur() {
        return auteur;
    }

    public int getRestants() {
        return restants;
    }

    public boolean isPause() {
        return pause;
    }
}
