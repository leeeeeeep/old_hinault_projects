package com.boggle.serveur;

import java.io.Serializable;

public interface ServeurInterface extends Serializable {
    public void annoncerDebutPartie();

    public void annoncerFinPartie();

    public void annoncerDebutManche();

    public void annoncerFinManche();

    public void annoncerMotTrouve(String nom);

    public void annoncerElimination(String nom);

    public void finirJeu();
}
