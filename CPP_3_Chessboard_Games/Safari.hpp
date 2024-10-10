#ifndef SAFARI_HPP
#define SAFARI_HPP

#include "Modejeu.hpp"
#include "SafariPiece.hpp"

#define AJOUT_BARRIERE_INIT 1
#define MAX_PIECE_ANIMAL 3
#define TAILLE_DAMIER_SAFARI 17

enum class Mode {ANIMAL, BARRIERE};
enum direction {NONE, GAUCHE, DROITE, HAUT, BAS, HAUT_GAUCHE, HAUT_DROITE, BAS_GAUCHE, BAS_DROITE};

class Safari final : public Modejeu {
    private :
        void  init_damier();
        int cpt_init_joueur = MAX_PIECE_ANIMAL;
        Mode mode;

        vector<pair<int,int>> animaux_capture;

        bool verification_deplacement(vector<pair<int,int>> coord, vector<int>* id_piece);
        static bool verification_locale(vector<int>* id_piece, Joueur* joueur_courant);
        bool debut_partie(pair<int, int> coord);
        void ajoute_score(int score);
        bool changement_tour_possible();
        void calcul_enclos(vector<pair<int,int>> case_rencontre, direction d, pair<int,int> coord_courant, pair<int,int> destination);
        void calcul_animaux_encercles(vector<pair<int,int>> case_rencontre);
        void calcul_score_animaux_capture(vector<pair<int,int>>* animaux_capture);
    public :
        Safari(int longueur = TAILLE_DAMIER_SAFARI);
        virtual ~Safari();

        bool action(vector<pair<int, int>> coord);
        bool est_fin_partie();
        bool test_partie_nulle();
        bool changement_joueur();
        bool peut_choisir_piece(pair<int,int> coord);
        int nb_coord_voulu();
        int get_indice_joueur_gagnant();
};

#endif