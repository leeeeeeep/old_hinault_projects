package com.boggle.client.affichage;

import com.boggle.client.AffichageJeu;
import com.boggle.client.Client.Serveur;
import java.awt.*;
import javax.swing.*;

public class VueEntreeTexte extends JTextField {
    public VueEntreeTexte(AffichageJeu affichageJeu, Serveur serveur) {
        super();

        this.setPreferredSize(new Dimension(400, 100));

        addActionListener((ac) -> {
            String mot = ac.getActionCommand();

            if (mot.length() > 0) {
                if (mot.startsWith("/")) {
                    String commande = mot.substring(1);
                    switch (commande) {
                        case "pause":
                            serveur.pause(true);
                            break;
                        case "unpause":
                            serveur.pause(false);
                            break;
                        case "lobby":
                            affichageJeu.lobby();
                            break;
                    }
                } else {
                    serveur.envoyerMotClavier(mot);
                }
            }
        });
    }

    public void activer(boolean activer) {
        this.setEnabled(activer);
        this.setText("");
    }
}
