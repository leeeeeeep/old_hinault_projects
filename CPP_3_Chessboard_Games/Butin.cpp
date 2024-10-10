#include "Butin.hpp"

Butin::Butin(int longueur) : Modejeu{longueur}
{
    init_damier();
    cout << "------- Butin --------" << endl; 
    cout << *damier;
}

Butin::~Butin() {
    cout << "Destruction du jeu Butin" << endl;
}

int Butin::nb_coord_voulu() {
    if(cpt_init != 0) {
        return 1;
    }
    return 2;
}

bool Butin::action(vector<pair<int, int>> coord) {
    if(nb_coord_voulu() != static_cast<int>(coord.size())) {
        throw std::runtime_error("action() : ne correspond pas au nombre de coordonnée attendu");
    }

    if(cpt_init != 0) {
        return debut_partie(coord[0]);
    }

    if(!verification_base(coord, joueur_courant)) {
        return false;
    }

    if(dernier_joueur == joueur_courant && damier->get_id_piece(coord[0]) != id_dernier_piece) {
        update_logger("choix impossible: Vous devez selectionner la piece que vous avez déplacé au dernier tour");
        return false;
    }

    vector<int> id_piece;
    if(!verification_deplacement(coord, &id_piece))
        return false;

    PieceCouleur type_piece = static_cast<PieceCouleur>(damier->get_type_piece(damier->get_coord_piece(id_piece[1])));

    if(damier->get_type_piece(coord[0]) == static_cast<int>(PieceCouleur::JAUNE)) {
        damier->suppression_piece(damier->get_coord_piece(id_piece[1]));
        id_dernier_piece = damier->get_id_piece(coord[0]);
        damier->deplacer_piece(coord[0], coord[1]);
        dernier_joueur = joueur_courant;
        ajoute_score(get_point_piece(type_piece));
        tour++;
        if(static_cast<int>(type_piece) == static_cast<int>(PieceCouleur::JAUNE))
            cpt_jaune--;
        mouvement_possible();
        if(est_fin_partie())
            ajoute_score(-sum_score_piece_restant());
        return true;
    }

    update_logger("Vous devez selectionner une piece Jaune au départ");
    return false;
}

bool Butin::est_fin_partie() {
    return cpt_jaune <= 0 || (tour != 0 && mouvement_possible_jaune.size() == 0);
}

int Butin::get_indice_joueur_gagnant() {
    // on compare le score des 2 joueurs
    if(joueur[1].second > joueur[0].second)
        return 1;
    else 
        return 0;
}


bool Butin::peut_choisir_piece(pair<int, int> coord) {
    if(damier->get_type_piece(coord) == static_cast<int>(PieceCouleur::JAUNE)) {
        return true;
    }
    update_logger("Vous devez selectionner une piece Jaune au départ");
    return false;
}

bool Butin::changement_joueur() {
    if(changement_tour_possible()) {
        if(joueur_courant == joueur[0].first) {
            joueur_courant = joueur[1].first;
            update_logger("Le joueur 1 joue");
        } else {
            joueur_courant = joueur[0].first;
            update_logger("Le joueur 0 joue");
        }
        mouvement_possible();
        return true;
    }
    update_logger("impossible de passer son tour: vous devez jouer votre tour avant");
    return false;
}

void Butin::init_damier() {
    vector<int> nbcouleurRestant{NB_JAUNE, NB_ROUGE, NB_NOIR}; // jaune, rouge, noir
    srand(time(NULL));

    //le choix de joueur est aléatoire
    int randomJoueur = rand() % 2;
    joueur_courant = joueur[randomJoueur].first;
    update_logger("Le joueur " + to_string(joueur_courant->id_joueur) + " commence la partie");

    for (int i = 0; i < TAILLE_DAMIER_BUTIN; i++) {
        for (int j = 0; j < TAILLE_DAMIER_BUTIN; j++) {
            while(true) {
                int res {-1};
                int randomColor = rand() % (NB_JAUNE + NB_NOIR + NB_ROUGE);
                PieceCouleur col {PieceCouleur::NONE};
                if (randomColor >= 0 && randomColor <= NB_JAUNE 
                    && nbcouleurRestant[(int)PieceCouleur::JAUNE] > 0) { // jaune
                    col = PieceCouleur::JAUNE;

                } else if (randomColor > NB_JAUNE &&
                           randomColor <= NB_JAUNE+NB_ROUGE &&
                           nbcouleurRestant[(int)PieceCouleur::ROUGE] > 0) { // rouge
                    col = PieceCouleur::ROUGE;

                } else if (randomColor > NB_ROUGE+NB_JAUNE &&
                           randomColor <= NB_JAUNE+NB_NOIR+NB_ROUGE &&
                           nbcouleurRestant[(int)PieceCouleur::NOIR] > 0) { // Noir
                    col = PieceCouleur::NOIR;
                }

                if (col != PieceCouleur::NONE) {
                    res = (int)col;
                    nbcouleurRestant[res]--;
                    ButinPiece* p = new ButinPiece{1, col, {i,j}};
                    this->damier->ajouter_piece(p, {i,j});
                    if(col == PieceCouleur::JAUNE)
                        id_jaune.push_back(p->id_courant);
                    break;
                }
            }
        }
    }
    mouvement_possible();
}

bool Butin::debut_partie(pair<int, int> coord) {
    if(damier->get_type_piece(coord) == static_cast<int>(PieceCouleur::JAUNE)) {
        damier->suppression_piece(coord);
        cpt_init--;
        cpt_jaune--;
        return true;
    }
    update_logger("choix impossible: Vous devez selectionner une piece Jaune à enlever");
    return false;

}

bool Butin::verification_deplacement(vector<pair<int, int>> coord, vector<int> *id_piece) {
    int longueur{damier->getLongueur()};

    //on vérifie la validité de la direction
    if(!Mouvement::checkDirectionDiagonalB(coord[0].second, coord[0].first, coord[1].second, coord[1].first, longueur) &&
       !Mouvement::checkDirectionDiagonalH(coord[0].second, coord[0].first, coord[1].second, coord[1].first, longueur) &&
       !Mouvement::checkDirectionHorizontal(coord[0].second, coord[0].first, coord[1].second, coord[1].first, longueur) &&
       !Mouvement::checkDirectionVerticalB(coord[0].second, coord[0].first, coord[1].second, coord[1].first, longueur) &&
       !Mouvement::checkDirectionVerticalH(coord[0].second, coord[0].first, coord[1].second, coord[1].first, longueur)
    ) {
        update_logger("deplacement impossible: la trajectoire n'est pas valide");
        return false;
    }

    // on vérifie la validité de la trajectoire
    bool res{false};
    vector<pair<int, int>> coord_tmp{coord};

    //si la trajectoire est haut
    if(coord[0].first > coord[1].first && coord[0].second == coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_verticale_haut, &Butin::verification_locale);
    }
    //si la trajectoire est bas
    else if(coord[0].first < coord[1].first && coord[0].second == coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_verticale_bas, &Butin::verification_locale);
    }
    //si la trajectoire est gauche
    else if(coord[0].first == coord[1].first && coord[0].second > coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_horizontale_gauche, &Butin::verification_locale);
    }
    //si la trajectoire est droite
    else if(coord[0].first == coord[1].first && coord[0].second < coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_horizontale_droite, &Butin::verification_locale);
    }
    //si la trajectoire est diagonal haut gauche
    else if(coord[0].first > coord[1].first && coord[0].second > coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_haut_gauche, &Butin::verification_locale);
    }
    //si la trajectoire est diagonal haut droite
    else if(coord[0].first > coord[1].first && coord[0].second < coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_haut_droite, &Butin::verification_locale);
    }
    //si la trajectoire est diagonal bas gauche
    else if(coord[0].first < coord[1].first && coord[0].second > coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_bas_gauche, &Butin::verification_locale);
    }
    //si la trajectoire est diagonal bas droite
    else if(coord[0].first < coord[1].first && coord[0].second < coord[1].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_bas_droite, &Butin::verification_locale);
    }

    if(id_piece->size() == 1) {
        update_logger("choix impossible: vous ne pouvez pas capturer votre propre piece");
        return false; 
    }

    if(!res && id_piece->size() > 2) {
        update_logger("choix impossible: vous ne pouvez capturer qu'une seule piece à la fois");
        return false;
    }

    return res;
}

bool Butin::changement_tour_possible() {
    if (dernier_joueur == joueur_courant) 
        return true;
    return false;
}

bool Butin::verification_locale(vector<int>* id_piece, Joueur* j) {
    if(id_piece->size() > 2) {
        return false;
    }

    if(id_piece->size() == 2) {
        return true;
    }
    return true;
}

void Butin::mouvement_possible() {
    affichage_logger = false;
    mouvement_possible_jaune.clear();

    for(int jaune: id_jaune) {
        for(int i = 0; i < damier->getLongueur(); i++) {
            for(int j = 0; j < damier->getLongueur(); j++) {
                pair<int, int> coord{damier->get_coord_piece(jaune)};
                vector<pair<int, int>> coord_tmp{coord ,{i,j}};
                vector<int> id_piece;
                if(verification_base(coord_tmp, joueur_courant)  
                    && verification_deplacement(coord_tmp, &id_piece)) {
                    bool doublon{false};
                    for(pair<int, int> c: mouvement_possible_jaune) {
                        if(c.first == coord.first && c.second == coord.second) {
                            doublon = true;
                            break;
                        }
                    }

                    if(!doublon) {
                        mouvement_possible_jaune.push_back(coord);
                    }

                }
            }
        }
    }
    affichage_logger = true;
}

// Retourne le nombre de point de la pièce en passant son type de couleur
int Butin::get_point_piece(PieceCouleur pc) {
    switch(pc) {
        case PieceCouleur::JAUNE:
            return SCORE_JAUNE;
        case PieceCouleur::ROUGE:
            return SCORE_ROUGE;
        case PieceCouleur::NOIR:
            return SCORE_NOIR;
        default:
            throw std::runtime_error("Calcul du point avec une couleur inconnu");
            return 0;
    }
}

// retourne la somme des scores des pièces qui reste sur le damier 
int Butin::sum_score_piece_restant() {
    int res = 0;
    for(int i = 0; i < damier->getLongueur(); i++) {
        for(int j = 0; j < damier->getLongueur(); j++) {
            int type = damier->get_type_piece({i, j});
            if(type != -1) {
                res += get_point_piece(static_cast<PieceCouleur>(type));
            }
        }
    }
    return res;
}

bool Butin::test_partie_nulle() {
    return false;
}