#ifndef GAMEINTERFACE_HPP
#define GAMEINTERFACE_HPP

#include <SFML/Graphics.hpp>
#include "Modejeu.hpp"
#include "EnumModeJeu.hpp"
#include <iostream>

using namespace sf;
using namespace std;

class GameInterface final {
    private :
        Jeu enumjeuNum;
        Modejeu* jeu;
        RenderWindow window;
        std::vector<RectangleShape> squares;
        RectangleShape skipTurnButtonRect;
        const bool blocage;
        bool fin_de_partie;

        // initialiser les carreaux du damier qui seront stocké dans squares
        void init_carreaux();

        void dessine_info();

        // dessine le damier avec ses carreaux et
        // fait appel à une fonction auxiliaire pour générer son contenu
        void dessine_damier();
        // génère le contenu de la case à la coordonnée (col,row)
        void charge_contenu_case(int col, int row);
        // dessine l'image à la position (col,row) du damier par le chemin de l'image récupérer
        void charge_image(int col, int row, string chemin_image);

        // rassemble les gestions des événements entre l'utilisateur
        // et l'interface graphique
        void gestion_Event(Event);
    public :
        GameInterface(Jeu jeu, bool blocage = true);
        ~GameInterface();
        void initInterface();
};

#endif