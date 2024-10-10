package com.boggle.serveur.jeu;

/** Paramètre de la partie i.e nombre de joueur, le timer, etc... */
public class ConfigurationServeur {

    public final int port;
    public final int nombreJoueurs;
    public final String mdp;

    public ConfigurationServeur(int port, String mdp, int nombreJoueurs) {
        this.nombreJoueurs = nombreJoueurs;
        this.port = port;
        this.mdp = mdp;
    }
}
