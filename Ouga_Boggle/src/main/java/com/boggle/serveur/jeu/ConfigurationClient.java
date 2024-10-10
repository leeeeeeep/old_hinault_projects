package com.boggle.serveur.jeu;

public class ConfigurationClient {

    public final int port;
    public final String pseudo;
    public final String ip;
    public final String mdp;

    public ConfigurationClient(String ip, int port, String pseudo, String mdp) {
        this.port = port;
        this.pseudo = pseudo;
        this.ip = ip;
        this.mdp = mdp;
    }
}
