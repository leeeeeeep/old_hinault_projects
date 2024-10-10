package com.boggle.serveur.plateau;

import com.boggle.serveur.dictionnaire.Dictionnaire;
import com.boggle.serveur.jeu.Langue;
import java.io.Serializable;
import java.util.HashSet;
import java.util.LinkedList;

/** Plateau du jeu contenant les lettres. */
public class Grille implements Serializable {
    private Lettre[][] grille;
    private final GenerateurLettre langue;
    private final int colonnes;
    private final int lignes;
    private final Langue langueChoisi;
    private int nMots;

    /**
     * Constructeur.
     *
     * @param colonnes nombre de colonnes de la grille
     * @param lignes nombre de lignes de la grille
     * @param langue la langue choisie
     */
    public Grille(int lignes, int colonnes, Langue langue) {
        if (colonnes < 1 || lignes < 1) throw new IllegalArgumentException();
        this.colonnes = colonnes;
        this.lignes = lignes;
        this.langueChoisi = langue;
        grille = new Lettre[lignes][colonnes];
        this.langue = switch (langue) {
            case FR -> new GenerateurLettreFR();
            case EN -> new GenerateurLettreEN();
            case ES -> new GenerateurLettreES();
            case DE -> new GenerateurLettreDE();};
        Dictionnaire.generer(langue);
        genGrille();

        this.nMots = compterMots();
    }

    /**
     * Génère la grille aléatoirement.
     */
    private void genGrille() {
        for (int i = 0; i < grille.length; i++) {
            for (int j = 0; j < grille[0].length; j++) {
                grille[i][j] = new Lettre(new Coordonnee(i, j), langue.prendreLettreAleatoire());
            }
        }
    }

    private int compterMots() {
        return (int) Dictionnaire.getMots().stream()
                .filter(mot -> this.trouverMot(mot) != null)
                .count();
    }

    public int getColonnes() {
        return colonnes;
    }

    public int getLignes() {
        return lignes;
    }

    public Langue getLangue() {
        return langueChoisi;
    }

    /**
     * cherche toutes les occurences de la première lettre du mot dans la grille et teste si elle permet de construire le reste du mot
     * @param mot mot entré par le joueur
     * @return le mot sous forme de LinkedList<Lettre> si le mot est valide, null sinon
     */
    public LinkedList<Lettre> trouverMot(String mot) {
        for (int i = 0; i < this.lignes; i++) {
            for (int j = 0; j < this.colonnes; j++) {
                if (this.grille[i][j].lettre.charAt(0) == mot.charAt(0)) {
                    var liste = new LinkedList<Lettre>();
                    liste.add(this.grille[i][j]);
                    var trouve = checkVoisin(mot.substring(1), i, j, liste);
                    if (trouve != null) return trouve;
                }
            }
        }
        return null;
    }

    /**
     * regarde chaque lettre autour de la première lettre du mot pour trouver la lettre suivante,
     * jusqu'à ce qu'on ai trouvé toutes les lettres du mot
     * @param mot mot recherché dans la grille
     * @param x coordonnées de la première lettre
     * @param y coordonnées de la première lettre
     * @param liste liste du mot a renvoyer à la fin
     * @return le mot sous forme de LinkedList<Lettre> si on a trouvé un chemin qui le représente, null sinon
     */
    private LinkedList<Lettre> checkVoisin(String mot, int x, int y, LinkedList<Lettre> liste) {
        if (mot.length() < 1) {
            return liste;
        }
        int[][] coords = {
            {x, y - 1},
            {x, y + 1},
            {x - 1, y - 1},
            {x - 1, y},
            {x - 1, y + 1},
            {x + 1, y - 1},
            {x + 1, y},
            {x + 1, y + 1},
        };
        for (var coord : coords) {
            int a = coord[0];
            int b = coord[1];

            if (a < 0 || b < 0 || a >= grille.length || b >= grille[0].length) continue;
            if (liste.contains(grille[a][b])) continue;

            if (this.grille[a][b].lettre.charAt(0) == mot.charAt(0)) {
                liste.add(grille[a][b]);
                if (checkVoisin(mot.substring(1), a, b, liste) != null) {
                    return liste;
                }
                liste.remove(grille[a][b]);
            }
        }
        return null;
    }

    /**
     * ajoute un mot entré au clavier
     * @param lettres le mot entré au clavier
     * @return le mot sous forme de LinkedList<Lettre> si le mot est valide, null sinon
     */
    public Mot ajouterMot(String lettres) {
        if (lettres.equals("")) return null;
        LinkedList<Lettre> liste = trouverMot(lettres);
        if (liste != null) {
            try {
                return new Mot(liste);
            } catch (Exception e) {
                return null;
            }
        }
        return null;
    }

    /**
     * ajoute un mot entré à la souris
     * @param lettres mot entré à la souris
     * @return le mot sous forme de LinkedList<Lettre> si le mot est valide, null sinon
     */
    public Mot ajouterMot(LinkedList<Lettre> lettres) {
        HashSet<Lettre> set = new HashSet<>(lettres);

        for (int i = 0; i < lettres.size() - 1; i++) {
            set.add(lettres.get(i));
            if (!lettres.get(i).estACoteDe(lettres.get(i + 1)) || lettres.get(i).estSur(lettres.get(i + 1))) {
                return null;
            }
        }

        // Si le set n'a pas la même taille que le LinkedList, c'est qu'il y a des doublons
        if (set.size() != lettres.size()) return null;

        for (int i = 0; i < this.lignes; i++) {
            for (int j = 0; j < this.colonnes; j++) {
                set.remove(this.grille[i][j]);
            }
        }
        // Si le set n'est pas vide, c'est qu'il y a des lettres qui ne sont pas dans la grille
        if (set.size() != 0) return null;

        try {
            return new Mot(lettres);
        } catch (Exception e) {
            return null;
        }
    }

    public Lettre[][] getGrille() {
        return grille;
    }

    public int getNMots() {
        return nMots;
    }
}
