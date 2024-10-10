#ifndef PIECE_HPP
#define PIECE_HPP

#include "Joueur.hpp"
#include <iostream>
#include <utility>

class Piece {
    protected :
        int id_joueur{-1};
        const int distance;
        virtual std::string afficher() const;
        static int id;
        pair<int,int> coord;
    public :

        //défini les coordonnées de la pièce
        void set_coord(pair<int,int> coord);

        //id unique
        const int id_courant;

        //pour compter le nombre de pièce crée
        static int debug;
        Piece(const int distance, pair<int,int> coord);
        virtual ~Piece();
        Piece(Piece& p);
        virtual int get_type() = 0;
        int get_distance() const;

        //defini le joueur qui possède la pièce
        void set_joueur(int id_joueur);

        //retourne le joueur qui possède la pièce
        int get_joueur();

        virtual std::string chemin_image() = 0;
    
        //compare si la pièce appartient au joueur
        bool compare_joueur(int id);
        friend std::ostream& operator<<(std::ostream &out, const Piece&p);
};


#endif