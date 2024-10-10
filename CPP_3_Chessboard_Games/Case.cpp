#include "Case.hpp"

int Case::debug = 0;

Case::Case(): piece{nullptr} {
    debug++;
}

Case::Case(Piece *piece): piece{piece} {
    debug++;
}

Case::~Case() {
    debug--;
    if(piece) delete piece;
}

Case::Case(Case &c): piece{c.piece} {
    if(debug) {
        std::cout << "Copie de la case" << std::endl;
    }
}

Piece* const Case::get_piece() const {
    return piece;
}

bool Case::estCaseVide() const {
    return piece == nullptr;
}

void Case::remove_piece() {
    if(piece) {
        piece = nullptr;
    }
}

bool Case::set_piece(Piece* piece) {
    if(!estCaseVide()) return false;
    this->piece = piece;
    return true;
}

std::ostream &operator<<(std::ostream &out, const Case &x) {
    if(x.get_piece()) {
        out << *x.get_piece();
    } else {
        out << "vide";
    }
    return out;
}
