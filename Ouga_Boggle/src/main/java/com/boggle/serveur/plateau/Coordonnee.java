package com.boggle.serveur.plateau;

import java.io.Serializable;

public class Coordonnee implements Serializable {
    public final int x;
    public final int y;

    /**
     * Constructeur.
     *
     * @param x l'emplacement dans les colonnes.
     * @param y l'emplacement dans les lignes.
     */
    public Coordonnee(int x, int y) {
        this.x = x;
        this.y = y;
    }

    /**
     * Vérifie si deux coordonnées sont adjacentes.
     *
     * @param coord coordonnées d'un emplacement
     * @return boolean true si les deux coordonnées sont adjacentes.
     */
    public boolean estACoteDe(Coordonnee coord) {
        return Math.abs(this.x - coord.x) < 2 && Math.abs(this.y - coord.y) < 2;
    }

    public boolean estSur(Coordonnee coord) {
        return this.x == coord.x && this.y == coord.y;
    }

    public String toString() {
        return String.format("(%d, %d)", this.x, this.y);
    }
}
