package com.boggle.util;

import com.google.gson.Gson;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Scanner;

public class Parametres {
    public static boolean charges = false;
    private static Logger logger = Logger.getLogger("PARAMETRES");
    private static ParametresData data;
    private static Gson gson = new Gson();

    // Ne pas utiliser directement, utiliser les methodes get
    private static final String FICHIER_PARAMETRES = "config.json";
    private static final String DOSSIER_PARAMETRES = ".config/ouga-boggle";

    private static String getCheminFichierParametres() {
        return Paths.get(System.getProperty("user.home"), DOSSIER_PARAMETRES, FICHIER_PARAMETRES)
                .toString();
    }

    private static String getCheminDossierParametres() {
        return Paths.get(System.getProperty("user.home"), DOSSIER_PARAMETRES).toString();
    }

    public static void charger() {
        String json = "";
        try {
            logger.info(String.format("Lecture du fichier de configuration %s", getCheminFichierParametres()));
            File fileObj = new File(getCheminFichierParametres());
            Scanner reader = new Scanner(fileObj);
            while (reader.hasNextLine()) {
                String data = reader.nextLine();
                json += data;
            }
            reader.close();
            ParametresData parametres = gson.fromJson(json, ParametresData.class);
            Parametres.data = parametres;
        } catch (FileNotFoundException e) {
            logger.info(String.format(
                    "Fichier %s non trouvé, chargements des paramètres par defaut", getCheminFichierParametres()));
            Parametres.data = new ParametresData();
        }
    }

    public static String getNom() {
        return data.nom;
    }

    public static String getHost() {
        return data.host;
    }

    public static int getPort() {
        return data.port;
    }

    public static boolean getSon() {
        return data.son;
    }

    public static void setNom(String nom) {
        data.nom = nom;
        save();
    }

    public static void setHost(String host) {
        data.host = host;
        save();
    }

    public static void setPort(int port) {
        data.port = port;
        save();
    }

    public static void setSon(boolean son) {
        data.son = son;
        save();
    }

    private static void save() {
        String json = gson.toJson(data);
        try {
            File directory = new File(getCheminDossierParametres());
            if (directory.mkdir()) {
                logger.warn(
                        "Le dossier de configuration " + directory.getAbsolutePath() + " n'existe pas, il à été créé.");
            } else {
                logger.info("Le dossier de configuration " + directory.getAbsolutePath() + " existe déjà.");
            }
            FileWriter writer = new FileWriter(getCheminFichierParametres());
            writer.write(json);
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        Parametres.charger();
        System.out.println(Parametres.getNom());
        System.out.println(Parametres.getHost());
        System.out.println(Parametres.getPort());
        System.out.println(Parametres.getSon());
        Parametres.setNom("toto");
        Parametres.setHost("titi");
        Parametres.setPort(1234);
        Parametres.setSon(false);
    }
}

class ParametresData {
    public String nom = "";
    public String host = "127.0.0.1";
    public int port = 8080;
    public boolean son = true;
}
