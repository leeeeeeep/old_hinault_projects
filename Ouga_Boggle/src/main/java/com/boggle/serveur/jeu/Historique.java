package com.boggle.serveur.jeu;

import com.boggle.serveur.plateau.Mot;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;

public class Historique implements Serializable {
    private List<HashMap<String, DonneeJoueur>> manches = new ArrayList<HashMap<String, DonneeJoueur>>();

    public Historique(List<Manche> manches) {
        List<HashMap<Joueur, HashSet<Mot>>> manchesMap = new ArrayList<>();
        manches.forEach(m -> {
            manchesMap.add(m.getMots());
        });
        int index = 0;
        for (HashMap<Joueur, HashSet<Mot>> manche : manchesMap) {
            this.manches.add(new HashMap<String, DonneeJoueur>());
            for (Joueur joueur : manche.keySet()) {
                DonneeJoueur donnee = new DonneeJoueur(manche.get(joueur));
                this.manches.get(index).put(joueur.nom, donnee);
            }
            index++;
        }
    }

    public List<HashMap<String, DonneeJoueur>> getManches() {
        return manches;
    }

    public void print(String name, boolean afficherMots, int nombreJoueurs) {
        HashMap<String, Integer> scores = new HashMap<>();
        HashMap<String, ArrayList<String>> mots = new HashMap<>();
        for (HashMap<String, DonneeJoueur> manche : manches) {
            for (String joueur : manche.keySet()) {
                if (scores.containsKey(joueur)) {
                    scores.put(joueur, scores.get(joueur) + manche.get(joueur).getPoints());
                } else {
                    scores.put(joueur, manche.get(joueur).getPoints());
                }
                if (mots.containsKey(joueur)) {
                    mots.get(joueur)
                            .addAll(manche.get(joueur).getMots().stream()
                                    .map(Mot::toString)
                                    .collect(ArrayList::new, ArrayList::add, ArrayList::addAll));
                } else {
                    mots.put(
                            joueur,
                            new ArrayList<String>(manche.get(joueur).getMots().stream()
                                    .map(Mot::toString)
                                    .collect(ArrayList::new, ArrayList::add, ArrayList::addAll)));
                }
            }
        }
        var entries = scores.entrySet().stream()
                .sorted((e1, e2) -> e2.getValue().compareTo(e1.getValue()))
                .toArray(Entry[]::new);
        System.out.println("Scores " + name + " :");
        int i = 0;
        for (Entry entry : entries) {
            if (i++ == nombreJoueurs) break;
            System.out.println(entry.getKey() + " : " + entry.getValue()
                    + (afficherMots ? " " + mots.get(entry.getKey()).toString() : ""));
        }
    }
}

class DonneeJoueur {
    private int points;
    private HashSet<Mot> mots;

    public DonneeJoueur(HashSet<Mot> mots) {
        this.mots = mots;
        this.points = mots.stream().mapToInt(Mot::getPoints).sum();
    }

    public int getPoints() {
        return points;
    }

    public HashSet<Mot> getMots() {
        return mots;
    }
}
