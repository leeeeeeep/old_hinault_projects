package com.boggle.client;

import com.boggle.client.Client.Serveur;
import com.boggle.client.affichage.*;
import com.boggle.client.affichage.VueInfos.Status;
import com.boggle.serveur.messages.Continue;
import com.boggle.serveur.messages.DebutJeu;
import com.boggle.serveur.messages.DebutManche;
import com.boggle.serveur.messages.FinManche;
import com.boggle.serveur.messages.FinPartie;
import com.boggle.serveur.messages.MotTrouve;
import com.boggle.serveur.messages.MotVerifie;
import com.boggle.serveur.messages.PauseClient;
import com.boggle.serveur.plateau.*;
import java.awt.*;
import java.util.Arrays;
import java.util.function.Consumer;
import javax.swing.*;

/** Vue du jeu */
public class AffichageJeu extends JFrame {
    private Serveur serveur;
    private DebutJeu debutJeu;
    private int nbManchesEcoulees;
    private JPanel infoPanel = new JPanel(new GridLayout(1, 2));
    private boolean elimine = false;
    private Client client;

    private VueEntreeTexte entreeTexte;
    private VueGrille grille;
    private VueMinuteur minuteur = new VueMinuteur();
    private VueInfos infos;
    public VueChat chat = new VueChat();

    Consumer<Mot> action;
    private boolean jeuFini = false;

    /**
     * Constructeur.
     *
     * @param serveur le serveur avec lequel communiquer
     * @param debutJeu les informations de début de jeu
     */
    public AffichageJeu(Serveur serveur, DebutJeu debutJeu, Client client) {
        super();
        this.client = client;
        setDefaultCloseOperation(EXIT_ON_CLOSE);

        this.serveur = serveur;

        entreeTexte = new VueEntreeTexte(this, serveur);

        grille = new VueGrille(entreeTexte, mot -> serveur.envoyerMotSouris(mot));

        this.debutJeu = debutJeu;

        this.infos = new VueInfos(this.debutJeu.getNbManches());

        JPanel panel = new JPanel(new GridBagLayout());
        add(panel);

        GridBagConstraints gbc = new GridBagConstraints();

        gbc.fill = GridBagConstraints.NONE;
        gbc.insets = new Insets(10, 10, 10, 10);

        gbc.gridx = 0;
        gbc.gridy = 0;
        gbc.gridheight = 4;
        panel.add(grille, gbc);

        entreeTexte.addActionListener((a) -> entreeTexte.setText(""));

        gbc.gridy = 4;
        gbc.gridheight = 1;
        panel.add(entreeTexte, gbc);

        gbc.gridx = 1;
        gbc.gridy = 0;
        gbc.gridheight = 4;
        panel.add(chat, gbc);

        infoPanel.add(minuteur);
        infoPanel.add(infos);

        gbc.gridy = 4;
        gbc.gridheight = 1;
        panel.add(infoPanel, gbc);

        pack();
        setVisible(true);
    }

    /**
     * Constructeur pour une partie en cours.
     * @param serveur le serveur avec lequel communiquer
     * @param continuePartie les informations pour continuer la partie
     */
    public AffichageJeu(Serveur serveur, Continue continuePartie, Client client) {
        this(serveur, continuePartie.getDebutJeu(), client);

        SwingUtilities.invokeLater(() -> {
            infoPanel.remove(infos);
            infos = new VueInfos(continuePartie.getDebutJeu().getNbManches(), continuePartie.getNombreManchesJouees());
            infos.updateStatus(continuePartie.partieEstdemaree() ? Status.MANCHE_EN_COURS : Status.PAUSE, elimine);
            infos.ajouterPoints(continuePartie.getPoints());
            for (int i = 0; i <= continuePartie.getNombreManchesJouees(); i++) {
                infos.updateManches();
            }
            infoPanel.add(infos);
        });

        DebutManche dm = new DebutManche(continuePartie.getTableau(), continuePartie.getTempsRestant());
        initManche(dm);
        activerInterface(continuePartie.partieEstdemaree());
        nbManchesEcoulees = continuePartie.getNombreManchesJouees();
        infos.ajouterPoints(continuePartie.getPoints());
    }

    /**
     * Prépare l'interface pour une nouvelle manche.
     *
     * @param lettres nouvelles lettres
     */
    public void initManche(DebutManche dm) {
        grille.miseAJour(dm.getTableau());
        this.activerInterface(true);
        infos.updateStatus(Status.MANCHE_EN_COURS, elimine);
        infos.updateManches();
        entreeTexte.grabFocus();
        grille.updateUI();
        minuteur.start(dm.getLongueurManche());
        pack();
    }

    /**
     * Ajoute un ActionListener, active a chaque entree de mot
     *
     * @param a l'ActionListener a ajouter
     */
    public void setAction(Consumer<Mot> action) {
        this.action = action;
    }

    /**
     * Ajoute un mot a la liste des mots trouves
     *
     * @param mot le mot a ajouter
     */
    public void ajouterChat(String message) {
        chat.ajouterChat(message);
    }

    /**
     * Affiche les informations de la demande de pause.
     *
     * @param mot le mot trouvé
     */
    public void ajouterPause(PauseClient pc) {
        if (pc.isPause()) {
            chat.ajouterChat(String.format(
                    "%s a demandé la pause, il reste %d demandes avant que le serveur démare une pause.",
                    pc.getAuteur(), pc.getRestants()));
        } else {
            chat.ajouterChat(String.format(
                    "%s a annulé sa demande de pause, il reste %d demandes avant que le serveur démare une pause.",
                    pc.getAuteur(), pc.getRestants()));
        }
    }

    /**
     * Affiche les informations du mot vérifié.
     *
     * @param mot le mot vérifié
     */
    public void ajouterMotVerifie(MotVerifie mot) {
        if (mot.isAccepte()) {
            infos.ajouterPoints(mot.getPoints());
            infos.ajouterMotTrouve();
            chat.ajouterChat(String.format("Vous avez trouvé \"%s\" (+%dpts).", mot.getMot(), mot.getPoints()));
            jouerSonDeVictoire();
        } else {
            chat.ajouterChat(String.format("Le mot %s n'est pas valide.", mot.getMot()));
            jouerSonDeDefaite();
        }
    }

    /**
     * Affiche les informations du mot trouvé.
     *
     * @param mot le mot trouvé
     */
    public void ajouterMotTrouve(MotTrouve mot) {
        chat.ajouterChat(String.format("%s a trouvé un mot", mot.getPseudo()));
    }

    public void activerInterface(boolean activer) {
        if (!elimine) {
            grille.activer(activer);
            entreeTexte.activer(activer);
        }
    }

    /**
     * Affiche les informations de fin de manche.
     *
     * @param finManche les informations de fin de manche
     */
    public void finManche(FinManche finManche) {
        this.activerInterface(false);
        infos.updateStatus(Status.PAUSE, elimine);
        var joueurs = Arrays.asList(finManche.getJoueurs());
        joueurs.sort((j1, j2) -> j1.getPoints() - j2.getPoints());
        joueurs.forEach(j -> ajouterChat(String.format("%s a %d points.", j.getNom(), j.getPoints())));
        nbManchesEcoulees++;
        if (debutJeu.getNbManches() != 0) {
            if (!(nbManchesEcoulees == debutJeu.getNbManches())) {
                ajouterChat("Manche finie, la prochaine manche commence dans 10 secondes.");
            } else {
                ajouterChat("Manche finie.");
            }
        } else {
            if (!(joueurs.size() == 1)) {
                ajouterChat("Manche finie, la prochaine manche commence dans 10 secondes.");
            } else {
                ajouterChat("Manche finie.");
            }
        }
    }

    /*
     * FIXME: faire marcher le son.
     *
     * Temps passśe sur ce problème : 2h30.
     *
     * Vous êtes priées de mettre à jour le compteur de temps
     * lorsque vous perdez votre temps sur ce problème.
     */
    private void jouerSonDeDefaite() {
        // Util.playSound("defaite.mp3");
    }

    private void jouerSonDeVictoire() {
        // Util.playSound("victoire.mp3");
    }

    public void eliminer() {
        activerInterface(false);
        this.elimine = true;
    }

    public void finJeu(FinPartie finJeu) {
        String gagnants = "";
        for (var j : finJeu.getGagnants()) {
            gagnants += j.nom + ", ";
        }
        if (gagnants.equals("")) {
            gagnants = "personne";
        } else {
            gagnants = gagnants.substring(0, gagnants.length() - 2);
        }
        infos.updateStatus(Status.FIN, elimine);
        minuteur.fin();
        ajouterChat("Fin de la partie. Victoire de " + gagnants + ".");
        ajouterChat("Tapez \"/lobby\" pour revenir au lobby.");
        this.jeuFini = true;
        this.entreeTexte.activer(true);
    }

    public void envoyerMotClavier(String mot) {
        serveur.envoyerMotClavier(mot);
    }

    public void lobby() {
        if (this.jeuFini) {
            client.lobby();
        }
    }

    public boolean jeuEstFini() {
        return this.jeuFini;
    }

    public void setMotsATrouver(int nombreMots) {
        this.infos.setNombreMotsTotal(nombreMots);
    }

    public void setPoints(int points) {
        this.infos.setPoints(points);
    }

    public void setManche(int nombreManche) {
        this.infos.setManche(nombreManche);
    }
}
