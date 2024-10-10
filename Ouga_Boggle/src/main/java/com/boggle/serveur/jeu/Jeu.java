package com.boggle.serveur.jeu;

import com.boggle.serveur.ServeurInterface;
import com.boggle.serveur.dictionnaire.Dictionnaire;
import com.boggle.serveur.plateau.Grille;
import com.boggle.serveur.plateau.Lettre;
import com.boggle.serveur.plateau.Mot;
import com.boggle.util.Defaults;
import com.google.gson.Gson;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Serializable;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;

/** Fonctions relatives à la partie. */
public abstract class Jeu implements Serializable {
    protected HashSet<Joueur> joueurs;
    protected ArrayList<Manche> manches;
    protected int nombreMancheTotal;
    protected int dureeManche;
    protected int tailleVerticale;
    protected int tailleHorizontale;
    protected Langue langue;
    protected ServeurInterface serveur;
    protected boolean mancheEnCours;
    private boolean estEnPause = true;

    public Jeu(
            int nombreManche,
            int dureeManche,
            int tailleVerticale,
            int tailleHorizontale,
            Langue langue,
            ServeurInterface serveur) {
        this.serveur = serveur;
        this.joueurs = new HashSet<>();
        this.manches = new ArrayList<>();
        this.nombreMancheTotal = nombreManche;
        this.dureeManche = dureeManche;
        this.tailleHorizontale = tailleHorizontale;
        this.tailleVerticale = tailleVerticale;
        this.langue = langue;
        if (dureeManche < 0) {
            throw new IllegalArgumentException("La durée de la manche doit être supérieure ou égal à 0.");
        } else {
            this.dureeManche = dureeManche;
        }
        if (tailleHorizontale < 1) {
            throw new IllegalArgumentException("La taille horizontale doit être supérieure ou égal à 1.");
        } else {
            this.tailleHorizontale = tailleHorizontale;
        }
        if (tailleVerticale < 1) {
            throw new IllegalArgumentException("La taille verticale doit être supérieure ou égal à 1.");
        } else {
            this.tailleVerticale = tailleVerticale;
        }
    }

    /**
     * Indique si le jeu est commencé.
     * @return true si le jeu est en cours, false sinon
     */
    public final boolean estCommence() {
        return !manches.isEmpty();
    }

    public final void removeServeur() {
        this.serveur = null;
    }

    public final void setServeur(ServeurInterface serveur) {
        this.serveur = serveur;
    }

    /**
     * Indique si le jeu est fini.
     * @return true si toutes les manches ont été jouées, false sinon
     */
    public boolean estFini() {
        return nombreMancheTotal == manches.size();
    }

    /**
     * Démarre le jeu et lance la première manche.
     */
    public void demarrerJeu() {
        this.estEnPause = false;
        serveur.annoncerDebutPartie();
        nouvelleManche();
    }

    /**
     * Fini le jeu.
     */
    protected void finirJeu() {
        this.sauvegarderHistorique();
        serveur.annoncerFinPartie();
        serveur.finirJeu();
    }

    /**
     * Commence la manche passée en parametre.
     * @param m la manche à commencer
     */
    protected final void demarrerManche(Manche m) {
        mancheEnCours = true;
        manches.add(m);
        serveur.annoncerDebutManche();
    }

    /**
     * Fini la dernière manche commencée.
     */
    protected final void finirManche() {
        mancheEnCours = false;
        serveur.annoncerFinManche();
    }

    /**
     * Démarre une nouvelle manche.
     */
    public abstract void nouvelleManche();

    /**
     * Fonction qui s'execute à la fin de la manche.
     */
    public void finDeManche() {}

    /**
     * Calcule les joueurs gagnants.
     * @return les joueurs qui ont le plus de points
     */
    public List<Joueur> getJoueurGagnant() {
        ArrayList<Joueur> joueursGagnants = new ArrayList<>();
        HashMap<Joueur, Integer> pointsParJoueur = this.getPoints();
        int max = 0;
        for (Joueur joueur : pointsParJoueur.keySet()) {
            if (pointsParJoueur.get(joueur) == max) {
                joueursGagnants.add(joueur);
            } else if (pointsParJoueur.get(joueur) > max) {
                max = pointsParJoueur.get(joueur);
                joueursGagnants.clear();
                joueursGagnants.add(joueur);
            }
        }
        return joueursGagnants;
    }

    /**
     * Ajoute un joueur à la partie.
     * @param joueur le joueur à ajouter
     */
    public final void ajouterJoueur(Joueur joueur) {
        joueurs.add(joueur);
    }

    /**
     * Enleve un joueur à de partie.
     * @param joueur le joueur à enlever
     */
    public final boolean enleverJoueur(Joueur joueur) {
        return joueurs.remove(joueur);
    }

    /**
     * Retourne tous les joueurs.
     * @return tous les joueurs
     */
    public final HashSet<Joueur> getJoueurs() {
        return joueurs;
    }

    /**
     * @return la manche courante
     */
    public final Manche getMancheCourante() {
        return manches.get(manches.size() - 1);
    }

    /**
     * Ajoute un mot entrée à la souris.
     * @param lettre les lettres trouvés
     * @param joueur joueur qui a trouvé les lettres
     * @return le score du mot trouvé, 0 si le mot n'est pas trouvé
     */
    public int ajouterMot(LinkedList<Lettre> lettres, Joueur joueur) {
        if (joueurs.contains(joueur)) {
            return getMancheCourante().ajouterMot(lettres, joueur);
        }
        return 0;
    }

    /**
     * Ajoute un mot entrée au clavier.
     * @param lettre les lettres trouvés
     * @param joueur joueur qui a trouvé les lettres
     * @return le score du mot trouvé, 0 si le mot n'est pas trouvé
     */
    public int ajouterMot(String mot, Joueur joueur) {
        if (joueurs.contains(joueur)) {
            return getMancheCourante().ajouterMot(mot, joueur);
        }
        return 0;
    }

    public HashMap<Joueur, Integer> getPoints() {
        HashMap<Joueur, Integer> pointsParJoueur = new HashMap<>();
        for (var manche : manches) {
            var points = manche.getPoints();
            for (var joueur : points.keySet()) {
                pointsParJoueur.put(joueur, pointsParJoueur.getOrDefault(joueur, 0) + points.get(joueur));
            }
        }
        return pointsParJoueur;
    }

    public final Grille getGrille() {
        return getMancheCourante().getGrille();
    }

    public final HashMap<Joueur, HashSet<Mot>> getListeMots() {
        return getMancheCourante().getListeMots();
    }

    /**
     * Indique si une manche est en cours.
     * @return true si une manche est en cours, false sinon
     */
    public final boolean mancheEnCours() {
        return mancheEnCours;
    }

    /**
     * Indique le nombre de manches qui ont été jouées.
     * La manche courante est prise en compte.
     * @return le nombre de manches jouées
     */
    public final int getNombreManche() {
        return manches.size();
    }

    public enum Modes {
        NORMAL,
        BATTLE_ROYALE,
    }

    public final void sauvegarderHistorique() {
        Historique h = new Historique(manches);
        Gson gson = new Gson();

        String json = gson.toJson(h);

        File file = new File(Defaults.getDossierHistorique());
        if (!file.exists()) {
            file.mkdirs();
        }

        try {
            FileWriter fw = new FileWriter(Defaults.getDossierHistorique() + "/" + Instant.now() + ".json");
            fw.write(json);
            fw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public final void mettreEnPause() {
        this.estEnPause = true;
        getMancheCourante().getMinuteur().mettreEnPause();
    }

    public final void reprendre() {
        this.estEnPause = false;
        Dictionnaire.generer(langue);
        getMancheCourante().getMinuteur().reprendre();
    }

    public final boolean estEnPause() {
        return this.estEnPause;
    }
}
