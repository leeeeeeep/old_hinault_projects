package com.boggle.serveur.dictionnaire;

import com.boggle.serveur.jeu.Langue;
import com.boggle.util.Logger;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashSet;
import java.util.Set;

/** Classe de vérification des mots. */
public class Dictionnaire {
    private static Logger logger = Logger.getLogger("DICO");
    private static Set<String> mots = null;
    private static Langue langue;

    /**
     * Initialise le dictionnaire. Doit impérativement
     * être appelé avant d'utiliser le dictionnaire.
     */
    public static void generer(Langue langue) {
        if (mots == null || Dictionnaire.langue != langue) {
            logger.info("Initialisation du dictionnaire " + langue.name());
            Dictionnaire.langue = langue;
            mots = listeDesMots(langue);
            logger.info("Dictionnaire initialisé");
        }
    }

    /**
     * Vérifie si le mot est dans le dictionnaire.
     * @param mot le mot à vérifier
     * @throws IllegalStateException si le dictionnaire n'a pas été initialisé
     * @return vrai si le mot est dans le dictionnaire, faux sinon
     */
    public static boolean estUnMot(String mot) {
        if (Dictionnaire.mots == null) {
            throw new IllegalStateException("Dictionnaire non initialisé");
        }
        if (mot == "") return false;
        return Dictionnaire.mots.contains(mot);
    }

    /**
     * Retourne la liste des mots du dictionnaire.
     * @param langue la langue du dictionnaire
     * @return la liste des mots du dictionnaire
     */
    private static Set<String> listeDesMots(Langue langue) {
        HashSet<String> mots = new HashSet<>();
        try {
            String nomFichier = "/langues/"
                    + switch (langue) {
                        case FR -> "fr_sans_accents.txt";
                        case DE -> "de_sans_accents.txt";
                        case ES -> "es_sans_accents.txt";
                        case EN -> "en.txt";
                    };
            BufferedReader lecteur = new BufferedReader(new InputStreamReader(lireFichier(nomFichier)));
            String ligne;
            while ((ligne = lecteur.readLine()) != null) {
                if (ligne.length() >= 3) mots.add(ligne.toLowerCase());
            }
            lecteur.close();
        } catch (FileNotFoundException e) {
            System.out.println("Fichier de langue manquant");
            System.exit(1);
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
        return mots;
    }

    /**
     * Lit un fichier qui se trouve dans les ressources.
     * @param fichier le nom du fichier à lire
     * @return le flux de lecture du fichier
     */
    private static InputStream lireFichier(String fichier) {
        return Dictionnaire.class.getResourceAsStream(fichier);
    }

    public static Set<String> getMots() {
        return mots;
    }
}
