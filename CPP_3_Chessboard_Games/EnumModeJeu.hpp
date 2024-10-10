#ifndef MODEJEUTYPE_HPP
#define MODEJEUTYPE_HPP

#include <iostream>
#include <vector>

class Modejeu;
#include "Dames.hpp"
#include "Butin.hpp"
#include "Safari.hpp"

enum Jeu { DAMES, BUTIN, SAFARI };

class EnumModeJeu {
    public:
        // Converti l'enum jeu en string
        static std::string enumToString(Jeu jeu) {
            switch (jeu) {
                case DAMES:
                    return "Dames";
                case BUTIN:
                    return "Butin";
                case SAFARI:
                    return "Safari";
                default:
                    throw std::runtime_error("Type de jeu non pris en charge.");
            }
        }

        // Retourne un vector d'enums des jeux
        static const std::vector<Jeu> getJeuMode() {
            return {DAMES, BUTIN, SAFARI};
        }

        static Modejeu* createJeu(Jeu jeu) {
            switch (jeu) {
                case DAMES:
                    return new Dames{};
                case BUTIN:
                    return new Butin{};
                case SAFARI:
                    return new Safari{};
                default:
                    throw std::runtime_error("Type de jeu non pris en charge.");
            }
        }
};

#endif