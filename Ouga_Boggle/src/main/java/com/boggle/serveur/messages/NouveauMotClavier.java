package com.boggle.serveur.messages;

public class NouveauMotClavier {
    private String mot;
    private String id;
    private String pseudo;

    public NouveauMotClavier(String mot, String id) {
        this.mot = mot;
        this.id = id;
    }

    public void setPseudo(String pseudo) {
        this.pseudo = pseudo;
    }

    public String getId() {
        return id;
    }

    public String getMot() {
        return mot;
    }

    public String getPseudo() {
        return pseudo;
    }
}
