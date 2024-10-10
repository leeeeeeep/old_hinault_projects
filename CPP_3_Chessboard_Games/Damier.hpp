#ifndef _DAMIER
#define _DAMIER

#include <iostream>
#include <vector>
#include "Case.hpp"
#include <functional>

using namespace std;
class Damier final {
    private:
        const int longueur;
        vector<vector<Case*>> damier;
        Damier(const int longueur);
        virtual ~Damier();
        Damier(const Damier&d);

        //met une pièce à une coordonnée
        bool ajouter_piece(Piece* p, pair<int,int> coord);

        //retourne le type de la pièce
        int get_type_piece(pair<int,int> coord);

        //retire et retourne la pièce (pas supprimé)
        Piece* retirerPiece(pair<int,int> coord);

        //supprime une pièce
        bool suppression_piece(pair<int,int> coord);

        //retire et ajoute une pièce à une autre coordonnée
        //origine doit être non vide et destination vide
        bool deplacer_piece(pair<int,int> coord1, pair<int,int> coord2);

        //retourne la distance de déplacement d'une pièce
        int get_distance_piece(pair<int,int> coord);

        //retourne l'id de la pièce
        int get_id_piece(pair<int,int> coord);

        //retourne les coordonnées de la pièce
        pair<int,int> get_coord_piece(int id_piece);

        //retourne les coordonnées des pièces d'un joueur
        vector<pair<int,int>> get_coord_pieces(Joueur* joueur);

        bool est_case_vide(pair<int,int> coord);
        const int getLongueur() const;
        std::string chemin_image(int col, int row);

        //teste l'appartenance d'une pièce dans une case à un joueur
        bool appartient_joueur(pair<int,int> coord, int id_joueur);

        //pour supprimer les pieces quand elle n'est plus utilisée
        bool suppression_pieces(vector<int> id_pieces);

        //fonction pour vérifier si la case n'appartient à aucun joueur
        //seulement utile pour Safari
        bool aucune_appartenance(pair<int,int> coord);

        //fonction de vérification au fur et à mesure du déplacement
        bool verification_case (vector<pair<int,int>> *coord,
                                Joueur * joueur,
                                vector<int>* id_piece,
                                function <void (vector<pair<int,int>>*)> trajectoire, 
                                function <bool (vector<int>*, Joueur*)> verification);

        friend std::ostream& operator<<(std::ostream &out , const Damier &x);
        friend class Modejeu;
        friend class Butin;
        friend class Dames;
        friend class Safari;
};

#endif