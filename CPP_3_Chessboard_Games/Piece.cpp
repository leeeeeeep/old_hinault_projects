#include "Piece.hpp"

int Piece::debug = 0;
int Piece::id = 0;

Piece::Piece(const int distance, pair<int,int> coord) : distance{distance}, coord{coord} , id_courant{++id}{
    debug++;
}

Piece::~Piece() {
    debug--;
}

Piece::Piece(Piece &p): distance{p.distance}, id_courant{++id}{
    debug++;
    std::cout << "Copie d'une pièce" << std::endl;
}

int Piece::get_distance() const {
    return distance;
}

void Piece::set_coord(pair<int, int> coord) {
    this->coord = coord;
}

void Piece::set_joueur(int joueur) {
    this->id_joueur = joueur;
}

bool Piece::compare_joueur(int id_joueur) {
    return this->id_joueur == id_joueur;
}

int Piece::get_joueur() {
    return id_joueur;
}

std::string Piece::afficher() const {
    return {"P(" + std::to_string(distance) + ")"};
}

std::ostream &operator<<(std::ostream &out, const Piece &p) {
    out << p.afficher();
    return out;
}

