package com.boggle.serveur.messages;

public class ReprendrePause {
    private int points;
    private int nombreManche;

    public ReprendrePause(int points, int nombreManche) {
        this.points = points;
        this.nombreManche = nombreManche;
    }

    public int getPoints() {
        return points;
    }

    public int getNombreManche() {
        return nombreManche;
    }
}
