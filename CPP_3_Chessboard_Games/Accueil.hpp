#ifndef ACCUEIL_HPP
#define ACCUEIL_HPP

#include <SFML/Graphics.hpp>
#include <iostream>
#include "EnumModeJeu.hpp"
#include "GameInterface.hpp"

class Accueil final {
    private:
        // Initialise l'interface graphique à partir de l'indice du jeu 
        // dans l'ensemble des jeux qu'on peut lancer
        void lanceJeu(int);

    public:
        // lance la fenêtre d'accueil
        void lancerAccueil();
};

#endif