#ifndef DAMESPIECE_HPP
#define DAMESPIECE_HPP

#include "Piece.hpp"
#include "PieceType.hpp"

using namespace std;

enum DamesPieceType {
    PION,
    DAME
};

class DamesPiece final: public Piece{
    public:
        DamesPiece(const int distance, const PieceCouleur couleur, pair<int,int> coord,const DamesPieceType type = PION);
        virtual ~DamesPiece();
        DamesPiece(DamesPiece& p);
        PieceCouleur get_type() const;
        std::string chemin_image();
        std::string afficher() const;
        const DamesPieceType piece_type;
        int get_type();
    private:
        const PieceCouleur couleur;
};


#endif
