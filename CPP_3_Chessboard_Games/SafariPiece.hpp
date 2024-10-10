#ifndef SAFARIPIECE_HPP
#define SAFARIPIECE_HPP

#include "Piece.hpp"
#include "PieceType.hpp"
#include <iostream>

using namespace std;

class SafariPiece final : public Piece {
    public:
        SafariPiece(const int distance, const SafariTypePiece type, pair<int, int> coord);
        virtual ~SafariPiece();
        SafariPiece(SafariPiece& p);
        int get_type();
        std::string afficher() const;
        std::string chemin_image();
    private:
        const SafariTypePiece type;
};

#endif