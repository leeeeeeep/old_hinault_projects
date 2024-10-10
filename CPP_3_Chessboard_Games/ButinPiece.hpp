#ifndef BUTINPIECE_HPP
#define BUTINPIECE_HPP

#include "Piece.hpp"
#include "PieceType.hpp"
#include <iostream>

using namespace std;

class ButinPiece final : public Piece {
    public:
        ButinPiece(int distance, const PieceCouleur couleur, pair<int,int> coord);
        virtual ~ButinPiece();
        ButinPiece(ButinPiece& p);
        int get_type();
        std::string chemin_image();
        std::string afficher() const;
    private:
        const PieceCouleur couleur;
};


#endif
