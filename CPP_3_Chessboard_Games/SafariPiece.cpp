#include "SafariPiece.hpp"

SafariPiece::SafariPiece(const int distance, const SafariTypePiece type, pair<int,int> coord): Piece{distance,coord}, type{type} {}

SafariPiece::~SafariPiece() {}

SafariPiece::SafariPiece(SafariPiece &p): Piece{p.distance, p.coord}, type{p.type} {
    cout << "Copie de Safari piece" << endl;
}

int SafariPiece::get_type(){
    return static_cast<int>(type);
}

std::string SafariPiece::afficher() const {
    return {"S(" + std::to_string((int)type) + ")"};
}

std::string SafariPiece::chemin_image() {
    std::string s{""};
    switch(type) {
        case SafariTypePiece::ELEPHANT :
            s += "./ressource/elephant.png";
            break;
        case SafariTypePiece::LION :
            s += "./ressource/lion.png";
            break;
        case SafariTypePiece::RHINO :
            s += "./ressource/rhino.png";
            break;
        case SafariTypePiece::BARRIERE :
            s += "./ressource/fondNoir.png";
            break;
        default :
            break;
    }
    return s;
}
