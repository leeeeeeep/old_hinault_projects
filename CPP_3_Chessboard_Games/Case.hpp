#ifndef _CASE
#define _CASE

#include <iostream>
#include "Piece.hpp"
class Case final {
    private:
        Piece* piece;
        void remove_piece();
        bool set_piece(Piece* piece);

        friend class Damier;
        Case();
        Case(Piece* piece);
        virtual ~Case();
        Case(Case& c);

        Piece* const get_piece() const;
        bool estCaseVide() const;
    public:
        static int debug;
        friend std::ostream& operator<<(std::ostream &out , const Case &x);
};


#endif
