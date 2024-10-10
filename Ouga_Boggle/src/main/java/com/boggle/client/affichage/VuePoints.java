package com.boggle.client.affichage;

import java.awt.*;
import javax.swing.*;

public class VuePoints extends JPanel {
    private JLabel label;
    private int points = 0;

    public VuePoints() {
        super();
        this.setPreferredSize(new Dimension(200, 100));
        this.setLayout(new BorderLayout());
        this.setBorder(BorderFactory.createTitledBorder("Points"));
        this.label = new JLabel(Integer.toString(this.points));
        this.add(this.label, BorderLayout.CENTER);
    }

    public void ajouterPoints(int points) {
        this.points += points;
        this.label.setText(Integer.toString(this.points));
    }
}
