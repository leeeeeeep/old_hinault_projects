#ifndef DAMES_HPP
#define DAMES_HPP

#include "Modejeu.hpp"
#include "DamesPiece.hpp"

#define TAILLE_DAMIER_DAMES 10
#define MAX_PIECE 20

class Dames final: public Modejeu {
    private :
        void  init_damier();
        bool debut_partie(pair<int, int> coord);
        bool test_partie_nulle();

        bool verification_deplacement(vector<pair<int,int>> coord, vector<int>* id_piece);
        static bool verification_locale(vector<int>* id_piece, Joueur* j);
        bool continuer_rafle();
        vector<pair<int,int>> mouv_possible{};
        vector<pair<int,int>> mouv_obligatoire{};

        bool changement_tour_possible();
        void mouvement_possible(vector<pair<int,int>> coord_piece);
        void mouvement_obligatoire (vector<pair<int, int>> coord_piece);
        bool formation_dame(pair<int, int> coord);

    public :
        int nb_coord_voulu();
        
        Dames(int longueur = TAILLE_DAMIER_DAMES);
        virtual ~Dames();
        bool action(vector<pair<int, int>> coord);
        bool changement_joueur();
        bool est_fin_partie();
        bool peut_choisir_piece(pair<int,int> coord);
        int get_indice_joueur_gagnant();
};

#endif