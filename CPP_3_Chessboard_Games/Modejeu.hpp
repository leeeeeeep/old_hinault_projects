#ifndef _MODEJEU
#define _MODEJEU

#include "Damier.hpp"
#include "Mouvement.hpp"
#include <utility>

class Modejeu {
    protected:
        string logger;
        vector<pair<Joueur*,int>> joueur;
        Joueur* joueur_courant;
        Damier* damier;
        virtual void init_damier() = 0;
        Joueur* dernier_joueur{nullptr};
        int id_dernier_piece;
        int tour{0} ;

        //pour afficher ou non le logger
        bool affichage_logger{true};

        friend class GameInterface;

        // retourne true si les déplacements des coordonnées est corrects et 
        // remplis le vector<int> de pièce qu'on a survolé qui serais valide (il y a aussi la pièce soit même)
        virtual bool verification_deplacement(vector<pair<int,int>> coord, vector<int>* id_piece) = 0;
        int cpt_init;

        // retourne true si une étape de l'initialisation est un succès sinon false
        virtual bool debut_partie(pair<int, int> coord) = 0;

        // retourne true si les coordonnées respectent les limites du tableau, 
        bool verification_base(vector<pair<int,int>> coord, Joueur* joueur);

        //retourne true si le joueur peut changer de tour
        virtual bool changement_tour_possible() = 0;

        // incrémente le score au joueur qui a fini son tour 
        void ajoute_score(int score);

        // met à jour le logger par le message et l'affiche
        void update_logger(string s);

    public:
        Modejeu(int longueur);
        virtual ~Modejeu();
        int get_longueur_damier();

        // retourne le chemin vers l'image de la pièce s'il y en a
        std::string chemin_image(int col, int row);
        // récupère le message du logger du mode de jeu
        string get_logger();
        // retourne le score des joueurs au tour courant
        const vector<int> get_score() const;
        // retourne le nombre de coordonnées que doit fournir l'interface pour une action
        virtual int nb_coord_voulu() = 0;
        // retourne l'indice du joueur courant dans le vector joueur
        int get_indice_joueur_courant();

        //décrit un placement de pièce ou un déplacement
        virtual bool action(vector<pair<int, int>> coord) = 0;
        //retourne true si la partie est finie
        virtual bool est_fin_partie() = 0;
        // retourne si la première pièce qu'on a choisi est possible
        virtual bool peut_choisir_piece(pair<int,int> coord) = 0;
        // retourne si on peut changer de joueur et l'effectue si c'est possible
        virtual bool changement_joueur() = 0;
        // retourne l'indice du joueur gagnant du vector joueur
        virtual int get_indice_joueur_gagnant() = 0;
        // retourne vrai si les conditions de la partie nulle est vrai s'il y en a
        // sinon retourne false
        virtual bool test_partie_nulle() = 0;
};

#endif
