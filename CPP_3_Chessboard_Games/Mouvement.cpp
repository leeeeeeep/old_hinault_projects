#include "Mouvement.hpp"

bool Mouvement::checkDirectionVerticalH(int colonne, int ligne, int newcolonne, int newligne, int distance) {
    return (colonne == newcolonne) && (newligne < ligne) && (ligne - newligne <= distance);
}

bool Mouvement::checkDirectionVerticalB(int colonne, int ligne, int newcolonne, int newligne, int distance) {
    return (colonne == newcolonne) && (newligne > ligne) && (newligne - ligne <= distance);
}

bool Mouvement::checkDirectionHorizontal(int colonne, int ligne, int newcolonne, int newligne, int distance) {
    return (ligne == newligne) && (std::abs(newcolonne - colonne) <= distance);
}

bool Mouvement::checkDirectionDiagonalH(int colonne, int ligne, int newcolonne, int newligne, int distance) {
    return (std::abs(newcolonne - colonne) == std::abs(newligne - ligne)) && (newligne < ligne) && (std::abs(newcolonne - colonne) <= distance);
}

bool Mouvement::checkDirectionDiagonalB(int colonne, int ligne, int newcolonne, int newligne, int distance) {
    return (std::abs(newcolonne - colonne) == std::abs(newligne - ligne)) && (newligne > ligne) && (std::abs(newcolonne - colonne) <= distance);
}

void Mouvement::trajectoire_horizontale_droite(vector<pair<int,int>> *coord) {
    coord->at(0).second++;
}

void Mouvement::trajectoire_horizontale_gauche(vector<pair<int,int>> *coord) {
    coord->at(0).second--;
}

void Mouvement::trajectoire_verticale_haut(vector<pair<int,int>> *coord) {
    coord->at(0).first--;
}

void Mouvement::trajectoire_verticale_bas(vector<pair<int,int>> *coord) {
    coord->at(0).first++;
}

void Mouvement::trajectoire_diagonale_haut_droite(vector<pair<int,int>> *coord) {
    coord->at(0).first--;
    coord->at(0).second++;
}

void Mouvement::trajectoire_diagonale_haut_gauche(vector<pair<int,int>> *coord) {
    coord->at(0).first--;
    coord->at(0).second--;
}

void Mouvement::trajectoire_diagonale_bas_droite(vector<pair<int,int>> *coord) {
    coord->at(0).first++;
    coord->at(0).second++;
}

void Mouvement::trajectoire_diagonale_bas_gauche(vector<pair<int,int>> *coord) {
    coord->at(0).first++;
    coord->at(0).second--;
}
