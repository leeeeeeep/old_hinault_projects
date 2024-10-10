package com.boggle.client.affichage;

import com.boggle.client.affichage.VueCase.EnvoyerMotSouris;
import com.boggle.serveur.plateau.Coordonnee;
import com.boggle.serveur.plateau.Lettre;
import java.awt.*;
import javax.swing.*;

/** Vue pour la grille de lettres */
public class VueGrille extends JPanel {
    VueCase[][] contenu;
    private EnvoyerMotSouris envoyeur;
    private VueEntreeTexte vet;

    public VueGrille(VueEntreeTexte vet, EnvoyerMotSouris envoyeur) {
        super();
        this.envoyeur = envoyeur;
        this.vet = vet;
        this.setPreferredSize(new Dimension(400, 400));
    }

    /**
     * Active/desactive la grille
     *
     * @param activer si true, active la grille, sinon, desactive la grille
     */
    public void activer(boolean activer) {
        for (var ligne : contenu) {
            for (var vcase : ligne) {
                vcase.activer(activer);
            }
        }
    }

    /**
     * Mets à jour la grille avec les nouvelles lettres.
     *
     * @param lettres nouvelles lettres
     */
    public void miseAJour(String[][] lettres) {
        var gridLayout = new GridLayout(lettres.length, lettres[0].length);
        gridLayout.setHgap(25);
        gridLayout.setVgap(25);
        setLayout(gridLayout);
        removeAll();
        contenu = new VueCase[lettres.length][lettres[0].length];
        for (int i = 0; i < lettres.length; i++) {
            for (int j = 0; j < lettres[0].length; j++) {
                VueCase c = new VueCase(new Lettre(new Coordonnee(i, j), lettres[i][j]), vet, envoyeur);
                contenu[i][j] = c;
                add(c);
            }
        }
    }
}
