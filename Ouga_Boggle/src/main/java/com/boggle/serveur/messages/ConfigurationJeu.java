package com.boggle.serveur.messages;

import com.boggle.serveur.jeu.Jeu.Modes;
import com.boggle.serveur.jeu.Langue;

/** Configuration d'un jeu */
public class ConfigurationJeu {
    public final int nbManches;
    public final int timer;
    public final int tailleGrilleH;
    public final int tailleGrilleV;
    public final Langue langue;
    public final Modes modeDeJeu;
    public final String sauvegarde;

    /**
     *
     * @param nbManches nombre manche
     * @param timer temps de jeu
     * @param tailleGrilleH hauteur de la grille
     * @param tailleGrilleV largeur de la grille
     * @param langue langue du la grille
     */
    public ConfigurationJeu(
            int nbManches,
            int timer,
            int tailleGrilleH,
            int tailleGrilleV,
            Langue langue,
            Modes modeDeJeu,
            String sauvegarde) {
        this.modeDeJeu = modeDeJeu;
        if (modeDeJeu == Modes.BATTLE_ROYALE) {
            this.nbManches = 0;
        } else {
            this.nbManches = nbManches;
        }
        this.timer = timer;
        this.tailleGrilleH = tailleGrilleH;
        this.tailleGrilleV = tailleGrilleV;
        this.langue = langue;
        this.sauvegarde = sauvegarde;
    }
}
