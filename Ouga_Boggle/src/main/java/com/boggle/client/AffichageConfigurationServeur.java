package com.boggle.client;

import com.boggle.serveur.Serveur;
import com.boggle.serveur.jeu.ConfigurationServeur;
import java.awt.*;
import javax.swing.*;

/**
 * Affichage d'une fenêtre où se passe la sélection
 * des paramètres et initialisation de la configuration.
 */
public class AffichageConfigurationServeur extends JFrame {
    public AffichageConfigurationServeur() {

        setTitle("OuGa-BoGgLe - Configuration de la partie");
        setLayout(new BorderLayout());
        setSize(500, 500);
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        String[][] labels = {
            {"Port: ", "8080"},
            {"Mot de passe: ", ""},
            {"Nombre de joueurs: ", "10"},
        };
        int paires = labels.length;

        JPanel config = new JPanel(new GridLayout(3, 1));
        for (int i = 0; i < paires; i++) {
            JPanel groupe = new JPanel();
            JLabel label = new JLabel(labels[i][0], JLabel.TRAILING);
            JTextField textField = new JTextField(labels[i][1], 5);
            label.setLabelFor(textField);
            groupe.add(label);
            groupe.add(textField);
            config.add(groupe);
        }

        add(config);

        JButton go = new JButton("Lancer serveur");
        add(go, BorderLayout.SOUTH);

        go.addActionListener(e -> {
            try {
                ConfigurationServeur c = new ConfigurationServeur(
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(0)).getComponent(1)).getText()),
                        ((JTextField) ((JPanel) config.getComponent(1)).getComponent(1)).getText(),
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(2)).getComponent(1)).getText()));
                setVisible(false);
                dispose();
                try {
                    new Serveur(c);
                } catch (Exception exe) {
                    exe.printStackTrace();
                }
            } catch (Exception ex) {
                System.out.println("invalide");
            }
        });
    }

    public static void main(String args[]) {
        AffichageConfigurationServeur acs = new AffichageConfigurationServeur();
        acs.setVisible(true);
    }
}
