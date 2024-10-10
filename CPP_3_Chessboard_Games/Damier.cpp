#include "Damier.hpp"

Damier::Damier(const int longueur): longueur{longueur}{
    damier.reserve(longueur);
    for(int i = 0; i < longueur; i++) {
        std::vector<Case*> lignei;
        lignei.reserve(longueur);
        for(int j = 0; j < longueur; j++) {
            lignei.push_back(new Case());
        }
        damier.push_back(lignei);
    }
}

Damier::~Damier() {
    for (size_t row = 0; row < damier.size(); row++) {
        for (size_t col = 0; col < damier[row].size(); col++) {
            delete damier[row][col];
        }
    }
}

Damier::Damier(const Damier &d): longueur{d.longueur}, damier{d.damier} {}

const int Damier::getLongueur() const {
    return longueur;
}

std::string Damier::chemin_image(int col, int row) {
    if(!damier[row][col]->estCaseVide()) {
        return damier[row][col]->get_piece()->chemin_image();
    }
    return "";
}

std::ostream &operator<<(std::ostream &out, const Damier &x) {
    out << "Longueur " << x.longueur << endl;
    for (size_t row = 0; row < x.damier.size(); row++) {
        for (size_t col = 0; col < x.damier[row].size(); col++) {
            out << *x.damier[row][col] << " ";
        }
        out << endl;
    }
    return out;
}

bool Damier::ajouter_piece(Piece* p, pair<int,int> coord) {
    if (damier[coord.first][coord.second]->get_piece() == nullptr) {
        damier[coord.first][coord.second]->set_piece(p);
        return true;
    }
    return false;
}

Piece* Damier::retirerPiece(pair<int,int> coord) {
    Piece* p = damier[coord.first][coord.second]->get_piece();
    damier[coord.first][coord.second]->remove_piece();
    return p;
}

bool Damier::deplacer_piece(pair<int,int> coord1, pair<int,int> coord2) {
    Piece *p = retirerPiece(coord1);
    if(p == nullptr)
        return false;
    if(ajouter_piece(p, coord2)) {
        p->set_coord(coord2);
        return true;
    } else {
        //cas si on a pas vérifié que la case était vide avant
        ajouter_piece(p, coord1);
    }
    return false;
}

// retourne le type de la pièce s'il a une pièce à la coordonnée passé en arguement sinon retourne -1
int Damier::get_type_piece(pair<int,int> coord) {
    Piece* p = damier[coord.first][coord.second]->get_piece();
    if(p == nullptr)
        return -1;
    return p->get_type();
}

bool Damier::suppression_piece(pair<int,int> coord) {
    Piece* p = retirerPiece(coord);
    if(p == nullptr)
        return false;
    delete p;
    return true;
}

bool Damier::est_case_vide(pair<int,int> coord) {
    //on verifie qu'on est dans le damier
    if(coord.first < 0 || coord.first > longueur || coord.second < 0 || coord.second > longueur) {
        return false;
    }
    return damier[coord.first][coord.second]->estCaseVide();
}

int Damier::get_distance_piece(pair<int,int> coord) {
    Piece* p = damier[coord.first][coord.second]->get_piece();
    if(p == nullptr)
        return -1;
    return p->get_distance();
}

bool Damier::appartient_joueur(pair<int,int> coord, int id_joueur) {
    Piece* p = damier[coord.first][coord.second]->get_piece();
    if(p == nullptr)
        return false;
    return p->compare_joueur(id_joueur);
}

bool Damier::aucune_appartenance(pair<int,int> coord) {
    Piece* p = damier[coord.first][coord.second]->get_piece();
    if(p == nullptr)
        return false;
    //l'absence d'appartenance est représentée par -1
    if(p->get_joueur() == -1)
        return true;
    return false;
}

bool Damier::verification_case(vector<pair<int,int>> *coord,
                                Joueur* joueur,
                                vector<int> *id_piece,
                                function <void (vector<pair<int,int>>*)> trajectoire,
                                function <bool (vector<int>*, Joueur*)> verification) {

    //on vérifie que la case est bien dans le damier
    if(coord->at(0).first < 0 || coord->at(0).first >= longueur || coord->at(0).second < 0 || coord->at(0).second >= longueur) {
        return false;
    }

    //si la case qu'on rencontre n'est pas vide on l'enregistre
    if(!damier[coord->at(0).first][coord->at(0).second]->estCaseVide()) {
        vector<int> id_piece_obtenu = joueur->get_piece_obtenu();
        Piece * pp = damier[coord->at(0).first][coord->at(0).second]->get_piece();

        for(int i = 0; i < (int)id_piece_obtenu.size(); i++) {
            if(id_piece_obtenu[i] == pp->id_courant)
                return false;
        }
        id_piece->push_back(pp->id_courant);
    }

    //si la premiere coordonnée est égale à la deuxieme, on a fini de parcourir la trajectoire
    if(coord->at(0).first == coord->at(1).first && coord->at(0).second == coord->at(1).second) {
        return true;
    }

    //on utilise la fonction de vérification pour vérifier si la case est valide selon les règles du mode
    if(verification(id_piece, joueur) == false) {
        return false;
    }

    //on continue de parcourir le damier selon la trajectoire
    trajectoire(coord);
    return verification_case(coord, joueur, id_piece, trajectoire, verification);
}

int Damier::get_id_piece(pair<int,int> coord) {
    Piece* p = damier[coord.first][coord.second]->get_piece();
    if(p == nullptr)
        return -1;
    return p->id_courant;
}


bool Damier::suppression_pieces(vector<int> id_pieces) {
    for(int i = 0; i < (int)id_pieces.size(); i++) {
        pair<int,int> coord {get_coord_piece(id_pieces[i])};
        if(coord.first == -1 && coord.second == -1) {
            throw std::runtime_error("Paramètre supression_pieces invalide");
        }
        suppression_piece(coord);
    }
    return true;
}

pair<int,int> Damier::get_coord_piece(int id_piece) {
    Piece *p;
    for (int i = 0; i < longueur; i++) {
        for (int j = 0; j < longueur; j++) {
            p = damier[i][j]->get_piece();
            if(p != nullptr) {
                if(p->id_courant == id_piece) {
                    return {i,j};
                }
            }
        }
    }
    return {-1,-1};
}

vector<pair<int,int>> Damier::get_coord_pieces(Joueur* joueur) {
    vector<pair<int,int>> coord;
    Piece *p;
    for (int i = 0; i < longueur; i++) {
        for (int j = 0; j < longueur; j++) {
            p = damier[i][j]->get_piece();
            if(p != nullptr) {
                if(p->compare_joueur(joueur->id_joueur)) {
                    coord.push_back({i,j});
                }
            }
        }
    }
    return coord;
}