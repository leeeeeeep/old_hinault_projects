#ifndef BUTIN_HPP
#define BUTIN_HPP

#include "Modejeu.hpp"
#include "ButinPiece.hpp"

using namespace std;

#define NB_JAUNE 34
#define NB_ROUGE 20
#define NB_NOIR 10

#define SCORE_JAUNE 1
#define SCORE_ROUGE 2
#define SCORE_NOIR 3

#define TAILLE_DAMIER_BUTIN 8

class Butin final: public Modejeu {
    private :
        void init_damier();
        bool debut_partie(pair<int, int> coord);
        bool verification_deplacement(vector<pair<int,int>> coord, vector<int>* id_piece);
        bool changement_tour_possible();
        int cpt_jaune{NB_JAUNE};
        static bool verification_locale(vector<int>* id_piece, Joueur* j);
        vector<int> id_jaune;
        void mouvement_possible();
        vector<pair<int,int>> mouvement_possible_jaune;

        int get_point_piece(PieceCouleur pc);
        int sum_score_piece_restant();
    public :
        Butin(int longueur = TAILLE_DAMIER_BUTIN);
        virtual ~Butin();

        int nb_coord_voulu();
        bool action(vector<pair<int, int>> coord);
        bool est_fin_partie();
        bool peut_choisir_piece(pair<int,int> coord);
        bool changement_joueur();
        int get_indice_joueur_gagnant();
        bool test_partie_nulle();

};

#endif