package com.boggle.serveur.jeu;

import com.boggle.serveur.plateau.Grille;
import com.boggle.serveur.plateau.Lettre;
import com.boggle.serveur.plateau.Mot;
import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;

/** utiliser pour la sauvegarde des manches */
public class Manche implements Serializable {
    private Grille grille;
    private HashMap<Joueur, HashSet<Mot>> listeMots;
    private Minuteur minuteur;

    public Manche(int tailleVerticale, int tailleHorizontale, int dureeTimer, Langue langue, Jeu jeu) {
        this.grille = new Grille(tailleVerticale, tailleHorizontale, langue);
        this.listeMots = new HashMap<Joueur, HashSet<Mot>>();
        this.minuteur = new Minuteur(dureeTimer, jeu);
    }

    public Grille getGrille() {
        return grille;
    }

    public HashMap<Joueur, HashSet<Mot>> getListeMots() {
        return listeMots;
    }

    public Minuteur getMinuteur() {
        return minuteur;
    }

    /**
     * Retourne les points de tous les joueurs.
     * @return une map des points de tous les joueurs
     */
    public Map<Joueur, Integer> getPoints() {
        Map<Joueur, Integer> points = new HashMap<>();
        for (Joueur joueur : listeMots.keySet()) {
            int acc = 0;
            for (Mot mot : listeMots.get(joueur)) {
                acc += mot.getPoints();
            }
            points.put(joueur, acc);
        }
        return points;
    }

    /**
     * @return true si le timer a atteint 0 sinon false
     */
    public boolean mancheFinie() {
        return minuteur.tempsEcoule();
    }

    /**
     * Ajoute un mot valide dans la liste de mots trouvés par
     * le joueur.
     * @param lettre mot qui a été trouvé
     * @param joueur joueur qui a trouvé le mot
     */
    public int ajouterMot(LinkedList<Lettre> lettre, Joueur joueur) {
        if (mancheFinie()) return 0;
        Mot mot = grille.ajouterMot(lettre);
        if (mot != null) {
            if (!listeMots.containsKey(joueur)) {
                listeMots.put(joueur, new HashSet<>());
            }
            if (listeMots.get(joueur).add(mot)) {
                return mot.getPoints();
            } else {
                return 0;
            }
        }
        return 0;
    }

    /**
     * Ajoute un mot valide dans la liste de mots trouvés par
     * le joueur.
     * @param lettre mot qui a été trouvé
     * @param joueur joueur qui a trouvé le mot
     */
    public int ajouterMot(String lettre, Joueur joueur) {
        if (mancheFinie()) return 0;
        Mot mot = grille.ajouterMot(lettre);
        if (mot != null) {
            if (!listeMots.containsKey(joueur)) {
                listeMots.put(joueur, new HashSet<>());
            }
            if (listeMots.get(joueur).add(mot)) {
                return mot.getPoints();
            } else {
                return 0;
            }
        }
        return 0;
    }

    public HashMap<Joueur, HashSet<Mot>> getMots() {
        return listeMots;
    }
}
