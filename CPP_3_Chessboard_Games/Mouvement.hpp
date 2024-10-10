#ifndef MOUVEMENT_HPP
#define MOUVEMENT_HPP

#include <iostream>
#include <vector>
#include <utility>

using namespace std;

class Mouvement final {
    public:
        //retourne un booléen si c'est une trajectoire valide 
        static bool checkDirectionVerticalH(int colonne, int ligne, int newcolonne, int newligne, int distance);
        static bool checkDirectionVerticalB(int colonne, int ligne, int newcolonne, int newligne, int distance);
        static bool checkDirectionHorizontal(int colonne, int ligne, int newcolonne, int newligne, int distance);
        static bool checkDirectionDiagonalH(int colonne, int ligne, int newcolonne, int newligne, int distance);
        static bool checkDirectionDiagonalB(int colonne, int ligne, int newcolonne, int newligne, int distance);

        //incrémente la coordonnée pour correspondre à la trajectoire
        static void trajectoire_horizontale_droite(vector<pair<int,int>> *coord);
        static void trajectoire_horizontale_gauche(vector<pair<int,int>> *coord);
        static void trajectoire_verticale_haut(vector<pair<int,int>> *coord);
        static void trajectoire_verticale_bas(vector<pair<int,int>> *coord);
        static void trajectoire_diagonale_haut_droite(vector<pair<int,int>> *coord);
        static void trajectoire_diagonale_haut_gauche(vector<pair<int,int>> *coord);
        static void trajectoire_diagonale_bas_droite(vector<pair<int,int>> *coord);
        static void trajectoire_diagonale_bas_gauche(vector<pair<int,int>> *coord);
};

#endif