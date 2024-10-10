package com.boggle.client.affichage;

import java.awt.*;
import javax.swing.*;
import javax.swing.text.DefaultCaret;

/** Vue pour les mots trouves */
public class VueChat extends JPanel {
    private JTextArea textArea;
    private JScrollPane scrollPane;

    /** Constructeur. */
    public VueChat() {
        super();
        this.setLayout(new BorderLayout());
        this.setPreferredSize(new Dimension(400, 400));
        var border = BorderFactory.createTitledBorder("Chat");
        this.setBorder(border);

        this.textArea = new JTextArea();
        this.textArea.setLineWrap(true);
        this.textArea.setWrapStyleWord(true);
        this.textArea.setFont(new Font("Noto Sans", Font.PLAIN, 14));
        this.textArea.setEditable(false);
        this.textArea.setBorder(null);
        DefaultCaret caret = (DefaultCaret) this.textArea.getCaret();
        caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);

        this.scrollPane = new JScrollPane(this.textArea);
        this.scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        this.scrollPane.setBorder(null);
        this.add(this.scrollPane, BorderLayout.CENTER);
    }

    /**
     * Ajoute un mot a la liste de mots
     *
     * @param mot le mot a ajouter
     */
    public void ajouterChat(String message) {
        // On ne peut pas utiliser .contains avec des String
        this.textArea.append(message + "\n");
        updateUI();
    }
}
