package com.boggle.serveur.messages;

import com.boggle.serveur.plateau.Lettre;

public class NouveauMotSouris {
    private String id;
    private String pseudo;
    private Lettre[] lettres;

    public NouveauMotSouris(Lettre[] lettres, String uuid) {
        this.lettres = lettres;
        this.id = uuid;
    }

    public String getId() {
        return id;
    }

    public Lettre[] getLettres() {
        return lettres;
    }

    public void setPseudo(String pseudo) {
        this.pseudo = pseudo;
    }

    public String getPseudo() {
        return pseudo;
    }
}
