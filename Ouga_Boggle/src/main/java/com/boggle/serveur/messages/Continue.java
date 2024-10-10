package com.boggle.serveur.messages;

public class Continue {
    private String[][] tableau;
    private boolean partieDemmaree;
    private int tempsRestant;
    private DebutJeu debutJeu;
    private int manchesJouees;
    private int points;

    public Continue(
            String[][] tableau,
            boolean partieDemaree,
            int tempsRestant,
            DebutJeu debutJeu,
            int manchesJouees,
            int points) {
        this.tableau = tableau;
        this.partieDemmaree = partieDemaree;
        this.tempsRestant = tempsRestant;
        this.debutJeu = debutJeu;
        this.manchesJouees = manchesJouees;
        this.points = points;
    }

    public String[][] getTableau() {
        return tableau;
    }

    public boolean partieEstdemaree() {
        return partieDemmaree;
    }

    public int getTempsRestant() {
        return tempsRestant;
    }

    public DebutJeu getDebutJeu() {
        return debutJeu;
    }

    public int getNombreManchesJouees() {
        return manchesJouees;
    }

    public int getPoints() {
        return points;
    }
}
