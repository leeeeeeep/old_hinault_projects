package com.boggle.serveur.messages;

public class Chat {
    private String message;
    private String pseudo;

    public Chat() {}

    public String getMessage() {
        return message;
    }

    public String getPseudo() {
        return pseudo;
    }

    public void setPseudo(String pseudo) {
        this.pseudo = pseudo;
    }

    public String toString() {
        return String.format("%s : %s", pseudo, message);
    }
}
