#ifndef _JOUEUR
#define _JOUEUR

#include <iostream>
#include <vector>
#include <utility>
using namespace std;

class Piece;

class Joueur final {
    private:
        vector<int> piece_obtenu;
        vector<vector<int>> piece_courant;
        static int id;
    public:
        const int id_joueur;
        Joueur();
        ~Joueur();
        Joueur(Joueur&j);
        vector<int> get_piece_obtenu();
        int get_nb_type_piece_courant(int type);
        int get_type_piece_id(int id);
        int get_nb_piece_obtenu();

        //vide les pièces obtenues/gagné par le joueur
        void vider_piece_obtenu();

        //retire la piece des pièces possédé par le joueur
        bool retirer_piece_courant(int id, int type);

        //ajoute une pièce aux pièces possédé par le joueur
        bool ajouter_piece_courant(int id, int type);

        //teste si le joueur possède la pièce
        bool appartient_joueur(int id);

        //ajoute une pièce aux pièces obtenues/gagné par le joueur
        bool add_piece_obtenu(int id_piece);

        //la taille de piece_courant dépend du nombre de type de piece
        void redimension_piece_courant(int type);
};

std::ostream& operator<<(std::ostream &out , const Joueur &x );

#endif