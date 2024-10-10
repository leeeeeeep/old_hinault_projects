package com.boggle.serveur.messages;

public class MotVerifie {
    private String id;
    private boolean accepte;
    private int points;
    private String mot;

    public MotVerifie(String id, boolean accepte, int score) {
        this.id = id;
        this.accepte = accepte;
        this.points = score;
    }

    public String getId() {
        return id;
    }

    public boolean isAccepte() {
        return accepte;
    }

    public int getPoints() {
        return points;
    }

    public void setMot(String mot) {
        this.mot = mot;
    }

    public String getMot() {
        return mot;
    }
}
