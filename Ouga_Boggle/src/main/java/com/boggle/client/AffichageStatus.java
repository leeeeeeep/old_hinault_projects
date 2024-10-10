package com.boggle.client;

import com.boggle.serveur.jeu.Jeu.Modes;
import com.boggle.serveur.jeu.Langue;
import com.boggle.serveur.messages.ConfigurationJeu;
import com.boggle.util.Defaults;
import java.awt.*;
import java.io.File;
import javax.swing.*;
import javax.swing.text.AttributeSet;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;

public class AffichageStatus extends JFrame {
    private boolean pret = false;
    private JButton bouton;
    private JButton choixFichier = new JButton("Choisir un fichier");
    private JLabel nPrets = new JLabel();
    private JLabel nJoueurs = new JLabel();
    private JLabel configValidee = new JLabel();
    private JTextPane joueurs = new JTextPane();
    private Client client;
    private boolean configValideeState = false;
    private JFileChooser fc = new JFileChooser();
    private String sauvegarde;

    public AffichageStatus(Client c) {
        client = c;

        setSize(800, 600);
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        String[][] labels = {
            {"Nombre de manches", "3"},
            {"Durée du timer en secondes: ", "60"},
            {"Largeur de la grille: ", "4"},
            {"Hauteur de la grille: ", "4"},
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

        JPanel langueGroupe = new JPanel();
        JLabel langueLabel = new JLabel("Langue :");
        JComboBox<String> langueComboBox = new JComboBox<String>();
        langueLabel.setLabelFor(langueComboBox);
        langueComboBox.addItem("français");
        langueComboBox.addItem("anglais");
        langueComboBox.addItem("allemand");
        langueComboBox.addItem("espagnol");
        langueGroupe.add(langueLabel);
        langueGroupe.add(langueComboBox);

        config.add(langueGroupe);

        JPanel modeGroupe = new JPanel();
        JLabel modeLabel = new JLabel("Mode de jeu :");
        JComboBox<String> modeComboBox = new JComboBox<String>();
        modeLabel.setLabelFor(modeComboBox);
        modeComboBox.addItem("Normal");
        modeComboBox.addItem("Battle Royale");
        modeGroupe.add(modeLabel);
        modeGroupe.add(modeComboBox);

        config.add(modeGroupe);

        fc.setCurrentDirectory(new File(Defaults.getDossierSauvegardes()));
        choixFichier.addActionListener(e -> {
            if (e.getSource() == choixFichier) {
                int returnVal = fc.showOpenDialog(this);
                if (returnVal == JFileChooser.APPROVE_OPTION) {
                    sauvegarde = fc.getSelectedFile().getAbsolutePath();
                }
            }
        });
        config.add(choixFichier);

        JButton buttonSettings = new JButton("Valider");
        buttonSettings.addActionListener(a -> {
            var langue =
                    switch (langueComboBox.getSelectedItem().toString()) {
                        case "français" -> Langue.FR;
                        case "anglais" -> Langue.EN;
                        case "allemand" -> Langue.DE;
                        default -> Langue.ES;
                    };
            Modes modeDeJeu =
                    switch (modeComboBox.getSelectedItem().toString()) {
                        case "Battle Royale" -> Modes.BATTLE_ROYALE;
                        default -> Modes.NORMAL;
                    };
            try {

                ConfigurationJeu configuration = new ConfigurationJeu(
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(0)).getComponent(1)).getText()),
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(1)).getComponent(1)).getText()),
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(2)).getComponent(1)).getText()),
                        Integer.parseInt(((JTextField) ((JPanel) config.getComponent(3)).getComponent(1)).getText()),
                        langue,
                        modeDeJeu,
                        sauvegarde);
                c.envoyerConfiguration(configuration);
                sauvegarde = "";
                configValideeState = true;
            } catch (Exception ex) {
                System.out.println("invalide");
            }
            update();
        });
        var configContainer = new JPanel();
        configContainer.setLayout(new BorderLayout());
        configContainer.add(config, BorderLayout.CENTER);
        configContainer.add(buttonSettings, BorderLayout.SOUTH);
        configContainer.add(configValidee, BorderLayout.NORTH);

        bouton = new JButton("PRET");

        bouton.addActionListener(a -> {
            pret = !pret;
            bouton.setText(pret ? "PAS PRET" : "PRET");
            c.envoyerStatus(pret);
        });

        JPanel infoPanel = new JPanel(new FlowLayout());
        infoPanel.add(nJoueurs);
        infoPanel.add(nPrets);

        JScrollPane scroll = new JScrollPane(this.joueurs);
        scroll = new JScrollPane(this.joueurs);
        scroll.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        scroll.setBorder(null);

        JPanel center = new JPanel(new GridLayout(1, 2));
        if (client.getJoueurs().size() == 1) {
            center.add(configContainer);
        }
        center.add(scroll);
        add(infoPanel, BorderLayout.NORTH);
        add(center, BorderLayout.CENTER);
        add(bouton, BorderLayout.SOUTH);
        update();
    }

    public void update() {
        nPrets.setText(String.format(
                "Prêts: %d", client.getJoueurs().stream().filter(c -> c.estPret).count()));
        nJoueurs.setText(String.format("Connectés: %d", client.getJoueurs().size()));
        configValidee.setText(String.format("Configuration: %s", configValideeState ? "validée" : "non validée"));
        joueurs.setText("");
        client.getJoueurs().forEach(j -> {
            appendToPane(joueurs, j.nom + "\n", j.estPret ? Color.GREEN : Color.RED);
        });
    }

    public void unpret() {
        pret = false;
        bouton.setText("PRET");
    }

    private void appendToPane(JTextPane tp, String msg, Color c) {
        StyleContext sc = StyleContext.getDefaultStyleContext();
        AttributeSet aset = sc.addAttribute(SimpleAttributeSet.EMPTY, StyleConstants.Foreground, c);

        aset = sc.addAttribute(aset, StyleConstants.FontFamily, "Lucida Console");
        aset = sc.addAttribute(aset, StyleConstants.Alignment, StyleConstants.ALIGN_JUSTIFIED);

        int len = tp.getDocument().getLength();
        tp.setCaretPosition(len);
        tp.setCharacterAttributes(aset, false);
        tp.replaceSelection(msg);
    }
}
