package com.boggle.client.affichage;

import com.boggle.serveur.plateau.Lettre;
import java.awt.*;
import java.awt.event.*;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import javax.swing.*;
import javax.swing.event.MouseInputListener;

/** Vue pour une lettre */
public class VueCase extends JPanel implements MouseInputListener {
    private Lettre lettre;
    private JButton button;
    private boolean selectionnee = false;
    private static boolean mouseDown = false;
    private static List<VueCase> selection = new ArrayList<>();
    private static VueCase lastCase = null;
    private VueEntreeTexte vet;
    private EnvoyerMotSouris envoyeur;

    /**
     * Constructeur.
     *
     * @param l charactere a utiliser pour cette case
     */
    public VueCase(Lettre l, VueEntreeTexte vet, EnvoyerMotSouris envoyeur) {
        super();
        button = new JButton(l.toString().toUpperCase());
        setLayout(new GridLayout(1, 1));
        add(button);
        this.envoyeur = envoyeur;
        this.lettre = l;
        this.vet = vet;

        button.setFocusable(false);

        activer(true);
    }

    public void activer(boolean activer) {
        if (activer) {
            button.removeMouseListener(this);
            button.removeMouseMotionListener(this);
            button.addMouseListener(this);
            button.addMouseMotionListener(this);
        } else {
            button.removeMouseListener(this);
            button.removeMouseMotionListener(this);
            mouseDown = false;
            selection.forEach(c -> c.deselectionner());
            selection.clear();
            vet.setText("");
        }
    }

    public void selectionner() {
        selectionnee = true;
        if (!selection.contains(this)) {
            SwingUtilities.invokeLater(() -> {
                selection.add(this);
                setBackground(Color.YELLOW);
                vet.setText(selection.stream()
                        .map(VueCase::getLettre)
                        .map(Lettre::toString)
                        .collect(Collectors.joining()));
            });
        }
    }

    public void deselectionner() {
        selectionnee = false;
        SwingUtilities.invokeLater(() -> {
            selection.remove(this);
            vet.setText(selection.stream()
                    .map(VueCase::getLettre)
                    .map(Lettre::toString)
                    .collect(Collectors.joining()));
            setBackground(null);
        });
    }

    public Lettre getLettre() {
        return lettre;
    }

    @Override
    public void mouseClicked(MouseEvent arg0) {}

    @Override
    public void mouseEntered(MouseEvent arg0) {
        if (mouseDown) {
            if (selectionnee) {
                selection.subList(selection.indexOf(this), selection.size()).forEach(VueCase::deselectionner);
                selection = selection.subList(0, selection.indexOf(this));
            }
            selectionner();
            lastCase = this;
        }
    }

    @Override
    public void mouseExited(MouseEvent arg0) {}

    @Override
    public void mousePressed(MouseEvent arg0) {
        mouseDown = true;
        setBackground(Color.YELLOW);
        vet.setEnabled(false);
        selectionner();
        lastCase = this;
    }

    @Override
    public void mouseReleased(MouseEvent arg0) {
        mouseDown = false;

        envoyeur.envoyer(selection.stream().map(VueCase::getLettre).collect(Collectors.toList()));
        selection.forEach(c -> c.deselectionner());
        selection.clear();
        vet.setText("");
        vet.setEnabled(true);
        vet.requestFocus();
    }

    @Override
    public void mouseDragged(MouseEvent arg0) {}

    @Override
    public void mouseMoved(MouseEvent arg0) {}

    public interface EnvoyerMotSouris {
        void envoyer(List<Lettre> mot);
    }
}
