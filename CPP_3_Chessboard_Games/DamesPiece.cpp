#include "DamesPiece.hpp"

DamesPiece::DamesPiece(const int distance, const PieceCouleur couleur, pair<int,int> coord, DamesPieceType type): Piece{distance, coord}, piece_type{type} , couleur{couleur}{}

DamesPiece::~DamesPiece() {}

DamesPiece::DamesPiece(DamesPiece &p) : Piece{p.distance, p.coord}, piece_type{p.piece_type}, couleur{p.couleur} {
    cout << "Copie Dames piece" << endl;
}

PieceCouleur DamesPiece::get_type() const {
    return couleur;
}

std::string DamesPiece::chemin_image() {
    std::string s{""};
    switch(couleur) {
        case PieceCouleur::BLANC :
            if (distance == 1) {
                s += "./ressource/rondBlanc.png";
            } else {
                s += "./ressource/dameBlanche.png";
            }
            break;
        case PieceCouleur::NOIR :
            if (distance == 1) {
                s += "./ressource/rondNoir.png";
            } else {
                s += "./ressource/dameNoire.png";
            }
            break;
        default :
            break;
    }
    return s;
}

std::string DamesPiece::afficher() const {
    return {"D(" + std::to_string((int)couleur) + ")"};
}

int DamesPiece::get_type() {
    return static_cast<int>(piece_type);
}