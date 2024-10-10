#include "Safari.hpp"

Safari::Safari(int longueur): Modejeu{longueur}, mode{Mode::ANIMAL} {
    cout << "------Safari-------" << endl;
    init_damier();
    cout << *damier;
}

Safari::~Safari() {
    cout << "Destruction du jeu Safari" << endl;
}

bool Safari::debut_partie(pair<int, int> coord) {
    //si l'une des deux coordonnées est pair alors c'est une barriere
    //on vérifie qu'on est pas en mode animal
    if((coord.first % 2 == 0 || coord.second % 2 == 0) && mode == Mode::ANIMAL) {
        update_logger("choix impossible: emplacement pour barrière");
        return false;
    }

    //si les deux coordonnées sont impairs alors c'est un animal
    //on vérifie qu'on est pas en mode barriere
    if(coord.first % 2 != 0 && coord.second % 2 != 0 && mode == Mode::BARRIERE) {
        update_logger("choix impossible: emplacement pour animal");
        return false;
    }


    if(cpt_init == 0) {
        joueur_courant = joueur[0].first;
        mode = Mode::ANIMAL;
        return true;
    }

    SafariPiece* p;
    if(mode == Mode::ANIMAL) {
        for(int i = 0; i < (int)joueur.size(); i++) {
            if(joueur[i].first == joueur_courant) {
                //le type d'animal est associé à la position du joueur dans le vecteur joueur
                //qu'on associe au enum SafariTypePiece
                p = new SafariPiece(damier->getLongueur(), static_cast<SafariTypePiece>(i), coord);
                p->set_joueur(joueur_courant->id_joueur);
                break;
            }
        }
    } else {
        p = new SafariPiece(0, SafariTypePiece::BARRIERE, coord);
    }

    //si le placement est possible, on actualise le dernier joueur
    bool res{damier->ajouter_piece(p, coord)};
    if(res) {
        dernier_joueur = joueur_courant;
        if(mode == Mode::ANIMAL)
            joueur_courant->ajouter_piece_courant(p->id_courant, p->get_type());
        cpt_init_joueur--;

        //Chaque joueur place 3 animaux sur le damier puis 1 barriere
        //cpt_init est le nombre de joueurs qui n'ont pas encore placé leurs animaux
        //cpt_init_joueur est le nombre Piece que le joueur doit encore placer
        if(cpt_init_joueur == 0 && mode == Mode::BARRIERE) {
            //si cpt_init_joueur == 0, le joueur a placé sa barriere, donc son init est terminé
            //on passe au joueur suivant en décrémentant cpt_init
            cpt_init--;
            cpt_init_joueur = MAX_PIECE_ANIMAL;
            mode = Mode::ANIMAL;

            for(int i = 0; i < (int)joueur.size(); i++) {
                if(joueur_courant == joueur[i].first) {
                    joueur_courant = joueur[(i+1)%joueur.size()].first;
                    update_logger("Tour du joueur " + to_string(joueur_courant->id_joueur));
                    break;
                }
            }
        }

        //on passe au mode barriere quand le joueur a posé ses 3 animaux
        if(cpt_init_joueur == 0 && mode == Mode::ANIMAL) {
            cpt_init_joueur = AJOUT_BARRIERE_INIT;
            mode = Mode::BARRIERE;
        }
    } else 
        delete p;
    return res;

}

bool Safari::changement_tour_possible() {
    //dans l'initialisation, le joueur doit placer 3 animaux d'affilé
    if(cpt_init != 0) {
        //si le joueur a placé ses 3 animaux et sa barriere, c'est le tour du joueur suivant
        if(cpt_init_joueur == 0 && mode == Mode::BARRIERE) {
            return true;
        }
        return false;
    }
    //Si le joueur a posé sa barriere, par extension il a déplacé son animal
    //il peut donc changer de tour
    if(joueur_courant == dernier_joueur && mode == Mode::ANIMAL){
        return true;
    }
    return false;
}

bool Safari::verification_locale(vector<int>* id_piece, Joueur* joueur_courant) {
    return true;
}

bool Safari::verification_deplacement(vector<pair<int,int>> coord, vector<int>* id_piece) {
    vector<pair<int,int>> coord_temp{coord};
    function<void (vector<pair<int,int>>*)> trajectoire;
    int dist{0};

    //si la direction est la gauche
    if(coord[0].second > coord[1].second) {
        dist = damier->getLongueur() - coord[0].second;
        //on vérifie la route est bien horizontale
        if(Mouvement::checkDirectionHorizontal(coord[0].second, coord[0].first, coord[1].second, coord[1].first, dist) == false)
            return false;
        trajectoire = &(Mouvement::trajectoire_horizontale_gauche);

    }
    //si la direction est la droite  
    else if (coord[0].second < coord[1].second) {
        dist = coord[0].second;
        //on vérifie la route est bien horizontale
        if(Mouvement::checkDirectionHorizontal(coord[0].second, coord[0].first, coord[1].second, coord[1].first, dist) == false)
            return false;
        trajectoire = &(Mouvement::trajectoire_horizontale_droite);
    }
    //si la direction est en haut
    else if(coord[0].first > coord[1].first) {
        dist = damier->getLongueur() - coord[0].first;
        //on vérifie la route est bien verticale haute
        if(Mouvement::checkDirectionVerticalH(coord[0].second, coord[0].first, coord[1].second, coord[1].first, dist) == false)
            return false;
        trajectoire = &(Mouvement::trajectoire_verticale_haut);
    }
    //si la direction est en bas
    else if (coord[0].first < coord[1].first) {
        dist = coord[0].first;
        //on vérifie la route est bien verticale basse
        if(Mouvement::checkDirectionVerticalB(coord[0].second, coord[0].first, coord[1].second, coord[1].first, dist) == false)
            return false;
        trajectoire = &(Mouvement::trajectoire_verticale_bas);
    }

    bool res {damier->verification_case(&coord_temp, joueur_courant, id_piece, trajectoire, verification_locale)};

    for(int id : *id_piece) {
        if(damier->get_type_piece(damier->get_coord_piece(id)) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            update_logger("déplacement impossible: une pièce rencontrée est une barriere");
            return false;
        }
    }

    return res;

}

bool Safari::action(vector<pair<int, int>> coord) {
    if(nb_coord_voulu() == 2) {
        if((coord[1].first % 2 == 0 || coord[1].second % 2 == 0) && mode == Mode::ANIMAL) {
            update_logger("choix impossible: emplacement destination pour barrière");
            return false;
        }
    } else if (mode == Mode::BARRIERE) {
        //si les deux coordonnées sont impairs alors c'est un animal
        //on vérifie qu'on est pas en mode barriere
        if(coord[0].first % 2 != 0 && coord[0].second % 2 != 0) {
            update_logger("choix impossible: emplacement source pour animal");
            return false;
        }
    }

    //si on est en phase d'initialisation, on appelle la fonction debut_partie
    if(cpt_init != 0) {
        return debut_partie(coord[0]);
    }

    //impossible d'avoir une coordonées pendant un déplacement d'aninal
    //impossible d'avoir deux coordonnées lors d'un placement de barriere
    if((coord.size() != 1 && mode == Mode::BARRIERE) 
        ||  (coord.size() != 2 && mode == Mode::ANIMAL)) {
        throw std::runtime_error("action() : ne correspond pas au nombre de coordonnée attendu");

    }

    bool res;

    if(mode == Mode::ANIMAL) {
        vector<int> id_piece;

        if(!verification_base(coord, joueur_courant) 
            || !verification_deplacement(coord, &id_piece))
            return false;
        res = damier->deplacer_piece(coord[0], coord[1]);
        if(res) 
            mode = Mode::BARRIERE;
    } else {
        SafariPiece* p = new SafariPiece(0, SafariTypePiece::BARRIERE, coord[0]);
        p->set_joueur(joueur_courant->id_joueur);
        res = damier->ajouter_piece(p, coord[0]);
        if(res) {
            //on calcule les animaux encerclés
            calcul_enclos({}, direction::NONE, coord[0], coord[0]);
            mode = Mode::ANIMAL;
            tour++;
        } else {
            update_logger("Impossible de placer une barriere ici");
            delete p;
        }
    }

    if(res) {
        dernier_joueur = joueur_courant;
    }

    return res;
}

bool Safari::est_fin_partie() {
    if(cpt_init != 0)
        return false;
    int k {0};
    int type {0};
    //on associe chaque type d'animal à un entier
    for(pair<Joueur*, int> jj : joueur) {
        if(jj.first->get_nb_type_piece_courant(type) == 0)  {
            k++;
        }
        type++;
    }
    //s'il reste un seul joueur qui a encore des animaux, la partie est finie
    if(k >= (int)joueur.size()-1 && cpt_init == 0) 
        return true;
    return false;
}

int Safari::get_indice_joueur_gagnant() { // TODO
    return 0;
}

int Safari::nb_coord_voulu() {
    if(mode != Mode::ANIMAL || cpt_init != 0)
        return 1;
    return 2;
}

void Safari::ajoute_score(int score){
    for(pair<Joueur*,int> j : joueur) {
        if(j.first == joueur_courant) {
            j.second += score;
        }
    }
}

void Safari::init_damier() {
    for(int i = 0; i < TAILLE_DAMIER_SAFARI; i++) {
        for(int j = 0; j < TAILLE_DAMIER_SAFARI; j++) {
            if(i == 0 || j == 0 || i == TAILLE_DAMIER_SAFARI-1 || j == TAILLE_DAMIER_SAFARI-1) {
                // cas où on est aux extremités
                SafariPiece *p = new SafariPiece{0, SafariTypePiece::BARRIERE, {i,j}};
                this->damier->ajouter_piece(p, {i,j});
            }
        }
    }
    joueur_courant = joueur[0].first;
}


void Safari::calcul_enclos(vector<pair<int,int>> case_rencontre, direction d, pair<int,int> coord_courant, pair<int,int> destination) {

    int longueur{damier->getLongueur()};

    if(coord_courant.first == destination.first 
        && coord_courant.second == destination.second 
        && d != direction::NONE) {

        calcul_animaux_encercles(case_rencontre);
        return;
    }

    vector<pair<int,int>> case_rencontre_bis{case_rencontre};
    //si coord_courant est déjà dans case_rencontre, on ne l'ajoute pas on return
    for(pair<int,int> p : case_rencontre) {
        if(p.first == coord_courant.first && p.second == coord_courant.second) {
            return;
        }
    }
    case_rencontre_bis.push_back(coord_courant);

    //si haut droite est possible
    if(coord_courant.first-1 >= 0 && coord_courant.second+1 < longueur && d != direction::HAUT_DROITE) {
        if(!damier->est_case_vide({coord_courant.first-1, coord_courant.second+1}) && damier->get_type_piece({coord_courant.first-1, coord_courant.second+1}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::BAS_GAUCHE, {coord_courant.first-1, coord_courant.second+1}, destination);
        }
    }

    //si haut gauche est possible
    if(coord_courant.first-1 >= 0 && coord_courant.second-1 >= 0 && d != direction::HAUT_GAUCHE) {
        if(!damier->est_case_vide({coord_courant.first-1, coord_courant.second-1}) && damier->get_type_piece({coord_courant.first-1, coord_courant.second-1}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::BAS_DROITE, {coord_courant.first-1, coord_courant.second-1}, destination);
        }
    }

    //si bas droite est possible
    if(coord_courant.first+1 < longueur && coord_courant.second+1 < longueur && d != direction::BAS_DROITE) {
        if(!damier->est_case_vide({coord_courant.first+1, coord_courant.second+1}) && damier->get_type_piece({coord_courant.first+1, coord_courant.second+1}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::HAUT_GAUCHE, {coord_courant.first+1, coord_courant.second+1}, destination);
        }
    }

    //si bas gauche est possible
    if(coord_courant.first+1 < longueur && coord_courant.second-1 >= 0 && d != direction::BAS_GAUCHE) {
        if(!damier->est_case_vide({coord_courant.first+1, coord_courant.second-1}) && damier->get_type_piece({coord_courant.first+1, coord_courant.second-1}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::HAUT_DROITE, {coord_courant.first+1, coord_courant.second-1}, destination);
        }
    }

    //si la haut est possible
    if(coord_courant.first-1 >= 0 && coord_courant.second != longueur-1 && d != direction::HAUT) {
        if(!damier->est_case_vide({coord_courant.first-1, coord_courant.second}) && damier->get_type_piece({coord_courant.first-1, coord_courant.second}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::BAS, {coord_courant.first-1, coord_courant.second}, destination);
        }
    }

    //si le gauche est possible
    if(coord_courant.second-1 >= 0  && coord_courant.first != 0 && d != direction::GAUCHE) {
        if(!damier->est_case_vide({coord_courant.first, coord_courant.second-1}) && damier->get_type_piece({coord_courant.first, coord_courant.second-1}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::DROITE, {coord_courant.first, coord_courant.second-1}, destination);
        }
    }

    //si la droite est possible
    if(coord_courant.second+1 < longueur && coord_courant.first != longueur-1 && d != direction::DROITE) {
        if(!damier->est_case_vide({coord_courant.first, coord_courant.second+1}) && damier->get_type_piece({coord_courant.first, coord_courant.second+1}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::GAUCHE, {coord_courant.first, coord_courant.second+1}, destination);
        }
    }

    //si le bas est possible
    if(coord_courant.first+1 < longueur && coord_courant.second != 0 && d != direction::BAS) {
        if(!damier->est_case_vide({coord_courant.first+1, coord_courant.second}) && damier->get_type_piece({coord_courant.first+1, coord_courant.second}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            calcul_enclos(case_rencontre_bis, direction::HAUT, {coord_courant.first+1, coord_courant.second}, destination);
        }
    }
}

void Safari::calcul_animaux_encercles(vector<pair<int,int>> case_rencontre) {
    vector<pair<int,int>> animaux_capture;
    int longueur{damier->getLongueur()};

    int aire{0};
    for(pair<int,int> p : case_rencontre) {
        vector<pair<int,int>> capture_bis{};
        int aire_tmp{0};
        for(int i = p.first+1; i < longueur; i++) {
            if(aire_tmp >= 8)
                break;

            //on incrémente l'aire si seulement on est sur une case qui peut accueillir un animal
            if(i % 2 != 0 && p.second % 2 != 0) {
                aire_tmp++;
            }

            if(!damier->est_case_vide({i, p.second})) {
                if(damier->get_type_piece({i, p.second}) == static_cast<int>(SafariTypePiece::BARRIERE)) {
                    for(pair<int,int> pp : case_rencontre) {
                        if(i == pp.first && pp.second == p.second) {
                            aire += aire_tmp;
                            animaux_capture.insert(animaux_capture.end(), capture_bis.begin(), capture_bis.end());
                            break;
                        }
                    }
                    break;
                } 
                int type = damier->get_type_piece({i, p.second});
                if(type >= static_cast<int>(SafariTypePiece::ELEPHANT) && type <= static_cast<int>(SafariTypePiece::LION)) {
                    capture_bis.push_back({i, p.second});
                }
            }
        }
    }
    if(aire >= 8)
        return;

    calcul_score_animaux_capture(&animaux_capture);
}

void Safari::calcul_score_animaux_capture(vector<pair<int,int>> *animaux_capture) {
    //on actualise la liste des animaux capturés
    this->animaux_capture.insert(this->animaux_capture.end(), animaux_capture->begin(), animaux_capture->end());

    for(pair<int,int> p : *animaux_capture) {
        SafariTypePiece type = static_cast<SafariTypePiece>(damier->get_type_piece(p));
        logger= "Le joueur " + to_string(joueur_courant->id_joueur) + " a capturé un ";
        switch(type) {
            case SafariTypePiece::ELEPHANT:
                logger += "éléphant ";
                break;
            case SafariTypePiece::RHINO:
                logger += "rhinocéros ";
                break;
            case SafariTypePiece::LION:
                logger += "lion ";
                break;
            default:
                break;
        }
    }

    //on enlève les animaux dans les pièces courantes du joueur
    for(pair<int,int> p : *animaux_capture) {
        int type = damier->get_type_piece(p);
        for(int i = 0; i< (int)joueur.size(); i++) {
            //on ne gagne pas de point si on enferme son propre animal
            if(joueur[i].first->retirer_piece_courant(damier->get_id_piece(p), type)
                && joueur[i].first != joueur_courant)
                ajoute_score(1);
        }
    }
}

bool Safari::peut_choisir_piece(pair<int,int> coord) {
    if(mode == Mode::ANIMAL) {
        //si vrai alors le joueur vient de poser sa barriere, donc passe son tour
        //seulement valable hors phase d'initialisation
        if(dernier_joueur == joueur_courant && cpt_init == 0) {
            update_logger("choix impossible: le joueur a fini de jouer");
            return false;
        }

        //on vérifie que la case n'est pas vide
        if(damier->est_case_vide(coord) && cpt_init == 0) {
            update_logger("choix impossible: la case est vide");
            return false;
        } else if(cpt_init != 0) 
            return true;

        //on vérifie que la pièce appartient bien au joueur
        if(!damier->appartient_joueur(coord, joueur_courant->id_joueur)) {
            update_logger("choix impossible: la pièce n'appartient pas au joueur");
            return false;
        }
        //on vérifie que la pièce n'est pas une barriere
        if(damier->get_type_piece(coord) == static_cast<int>(SafariTypePiece::BARRIERE)) {
            update_logger("choix impossible: la pièce est une barriere");
            return false;
        }

        //on vérifie que la piece n'est pas capturée
        for(pair<int,int> p : animaux_capture) {
            if(p.first == coord.first && p.second == coord.second) {
                update_logger("choix impossible: la pièce est capturée");
                return false;
            }
        }
    } else {
        if(!damier->est_case_vide(coord)) {
            update_logger("choix impossible: la case doit être vide");
            return false;
        }
    }
    return true;
}

bool Safari::changement_joueur() {
    if(changement_tour_possible()) {
        for(int i = 0; i < (int)joueur.size(); i++) {
            if(joueur_courant == joueur[i].first) {
                joueur_courant = joueur[(i+1)%joueur.size()].first;
                update_logger("Tour du joueur " + to_string(joueur_courant->id_joueur));
                break;
            }
        }
        return true;
    }
    return false;
}

bool Safari::test_partie_nulle() {
    return false;
}