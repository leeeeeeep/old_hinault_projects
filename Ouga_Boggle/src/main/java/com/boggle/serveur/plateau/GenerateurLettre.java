package com.boggle.serveur.plateau;

import java.io.Serializable;

public interface GenerateurLettre extends Serializable {
    public String prendreLettreAleatoire();
}
