#include "Modejeu.hpp"

Modejeu::Modejeu(int longueur): damier{new Damier{longueur}}, cpt_init{2} {
    joueur.reserve(2);
    joueur.push_back({new Joueur{},0});
    joueur.push_back({new Joueur{},0});
}

Modejeu::~Modejeu() {
    for(pair<Joueur*,int> j : joueur) {
        delete j.first;
    }
    delete damier;
}

bool Modejeu::verification_base(vector<pair<int,int>> coord, Joueur* j) {
    //on teste si les coordonnées sont dans le damier
    int longueur = damier->getLongueur();
    if(coord[0].first < 0 || coord[0].first >= longueur || coord[0].second < 0 || coord[0].second >= longueur ||
       coord[1].first < 0 || coord[1].first >= longueur || coord[1].second < 0 || coord[1].second >= longueur) {
        logger = "coordonnées sorties du damier";
        return false;
    }

    //on vérifie que ce sont pas les mêmes coordonnées
    if(coord[0].first == coord[1].first && coord[0].second == coord[1].second) {
        logger = "coordonnées identiques";
        return false;
    }

    //erreur si la case de départ est vide ou que la case d'arrivée est occupée
    if(damier->est_case_vide(coord[0]) == true || damier->est_case_vide(coord[1]) == false) {
        logger = "déplacement impossible: case d'origine vide ou case d'arrivée occupée";
        return false;
    }

    //on teste l'appartenance du joueur à la pièce
    if(!damier->aucune_appartenance(coord[0]) && !damier->appartient_joueur(coord[0], j->id_joueur)) {
        logger = "deplacement impossible: la pièce ne vous appartient pas";
        return false;
    }

    return true;
}

int Modejeu::get_longueur_damier() {
    return damier->getLongueur();
}

std::string Modejeu::chemin_image(int col, int row) {
    return damier->chemin_image(col,row);
}

const std::vector<int> Modejeu::get_score() const {
    vector<int> res{};
    for(pair<Joueur*,int> p_joueur : joueur) {
        res.push_back(p_joueur.second);
    }
    return res;
}

int Modejeu::get_indice_joueur_courant() {
    int indice = 0;
    for (pair<Joueur*,int>& s : joueur) {
        if(s.first == joueur_courant) {
            return indice;
        }
        indice++;
    }
    return 0;
}

void Modejeu::ajoute_score(int score) {
    for (pair<Joueur*,int>& s : joueur) {
        if(s.first == dernier_joueur) {
            s.second += score;
        }
    }
}

void Modejeu::update_logger(string s) {
    logger = s;
    if(affichage_logger) {
        cout << logger << endl;
    }
}

string Modejeu::get_logger() {
    return logger;
}