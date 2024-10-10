package com.boggle.client;

import com.boggle.serveur.jeu.ConfigurationClient;
import java.awt.*;
import javax.swing.*;

public class AffichageConfigurationClient extends JFrame {

    public AffichageConfigurationClient() {

        setTitle("OuGa-BoGgLe - Configuration de la partie");
        setSize(500, 500);
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        String[][] labels = {
            {"IP: ", "127.0.0.1"},
            {"Port: ", "8080"},
            {"Pseudo: ", ""},
            {"Mot de passe: ", ""},
        };
        int paires = labels.length;

        JPanel config = new JPanel(new GridLayout(8, 1));
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

        JButton go = new JButton("Rejoindre serveur");
        add(go, BorderLayout.SOUTH);

        go.addActionListener(e -> {
            try {
                if (((JTextField) ((JPanel) config.getComponent(0)).getComponent(1))
                                        .getText()
                                        .length()
                                == 0
                        || ((JTextField) ((JPanel) config.getComponent(2)).getComponent(1))
                                        .getText()
                                        .length()
                                == 0) {
                    throw new Exception();
                }
                ConfigurationClient c = new ConfigurationClient(
                        ((JTextField) ((JPanel) config.getComponent(0)).getComponent(1)).getText(),
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(1)).getComponent(1)).getText()),
                        ((JTextField) ((JPanel) config.getComponent(2)).getComponent(1)).getText(),
                        ((JTextField) ((JPanel) config.getComponent(3)).getComponent(1)).getText());
                setVisible(false);
                dispose();
                try {
                    new Client(c);
                } catch (Exception exe) {
                    exe.printStackTrace();
                }
            } catch (Exception ex) {
                System.out.println("invalide");
            }
        });
    }
}
