#include "Joueur.hpp"

int Joueur::id = -1;

Joueur::Joueur(): id_joueur{++id} {}

Joueur::~Joueur(){}

Joueur::Joueur(Joueur &j): id_joueur{j.id_joueur} {
    std::cout << "Copie d'un joueur" << std::endl;
}

int Joueur::get_nb_piece_obtenu() {
    return piece_obtenu.size();
}

bool Joueur::add_piece_obtenu(int id_piece) {
    for(int i : piece_obtenu) {
        if(i == id_piece) {
            return false;
        }
    }
    piece_obtenu.push_back(id_piece);
    return true;
}

int Joueur::get_nb_type_piece_courant(int type) {
    redimension_piece_courant(type);
    return piece_courant[type].size();
}

bool Joueur::appartient_joueur(int id) {
    for(vector<int> v: piece_courant) {
        for(int i : v) {
            if(i == id) {
                return true;
            }
        }
    }
    return false;
}

std::ostream &operator<<(std::ostream &out, const Joueur &x) {
    out << "Joueur " << to_string(x.id_joueur);
    return out;
}

int Joueur::get_type_piece_id(int id) {
    for(int i = 0; i < (int)piece_courant.size(); i++) {
        for(int j = 0; j < (int)piece_courant[i].size(); j++) {
            if(piece_courant[i][j] == id) {
                return i;
            }
        }
    }
    return -1;
}

bool Joueur::retirer_piece_courant(int id, int type) {
    bool res{false};
    vector<int> v;
    for(int i = 0; i < (int)piece_courant[type].size(); i++) {
        if(piece_courant[type][i] != id) {
            v.push_back(piece_courant[type][i]);
        } else 
            res = true;
    }
    if(res)
        piece_courant[type] = v;
    return res;
}

bool Joueur::ajouter_piece_courant(int id, int type) {
    //on ajoute pas quand elle est déjà présente
    if(!appartient_joueur(id)) {
        redimension_piece_courant(type);
        piece_courant[type].push_back(id);
        return true;
    }
    return false;
}

void Joueur::redimension_piece_courant(int type) {
    while((int)piece_courant.size() <= type) {
            piece_courant.push_back(vector<int>());
    }
}

vector<int> Joueur::get_piece_obtenu() {
    return piece_obtenu;
}

void Joueur::vider_piece_obtenu() {
    piece_obtenu.clear();
}
