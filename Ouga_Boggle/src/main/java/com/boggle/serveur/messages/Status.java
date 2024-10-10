package com.boggle.serveur.messages;

public class Status {
    private boolean status;
    private String pseudo;

    public Status(boolean status, String pseudo) {
        this.status = status;
        this.pseudo = pseudo;
    }

    public boolean getStatus() {
        return status;
    }

    public String getPseudo() {
        return pseudo;
    }

    public void setPseudo(String pseudo) {
        this.pseudo = pseudo;
    }
}
