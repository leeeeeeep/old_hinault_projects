#include "ButinPiece.hpp"

ButinPiece::ButinPiece(int distance, const PieceCouleur couleur, pair<int,int> coord): Piece{distance, coord}, couleur{couleur} {}

ButinPiece::~ButinPiece() {}

ButinPiece::ButinPiece(ButinPiece &p): Piece{p.distance, p.coord}, couleur{p.couleur}{
    cout << "Copie Butin piece " << endl;
}

int ButinPiece::get_type() {
    return static_cast<int>(couleur);
}

std::string ButinPiece::chemin_image() {
    std::string s{""};
    switch(couleur) {
        case PieceCouleur::JAUNE :
            s += "./ressource/rondJaune.png";
            break;
        case PieceCouleur::ROUGE :
            s += "./ressource/rondRouge.png";
            break;
        case PieceCouleur::NOIR :
            s += "./ressource/rondNoir.png";
            break;
        default :
            break;
    }
    return s;
}

std::string ButinPiece::afficher() const {
    return {"B(" + std::to_string((int)couleur) + ")"};
}