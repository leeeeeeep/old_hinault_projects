package com.boggle.serveur.jeu;

import java.io.Serializable;

/** Contient les informations relatives au joueur. */
public class Joueur implements Serializable {
    public final String nom;
    public boolean estPret = false;
    public boolean demandePause = false;

    public Joueur(String nom) {
        this.nom = nom;
    }

    public String toString() {
        return nom;
    }

    public int hashCode() {
        return nom.hashCode();
    }

    public boolean equals(Object o) {
        if (o instanceof Joueur) {
            return nom.equals(((Joueur) o).nom);
        }
        return false;
    }
}
