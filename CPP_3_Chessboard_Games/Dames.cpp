#include "Dames.hpp"

bool Dames::debut_partie(pair<int, int> coord) {
    return true;
}

bool Dames::formation_dame(pair<int, int> coord) {
    if(damier->get_type_piece(coord) != static_cast<int>(DamesPieceType::PION)) {
        return false;
    }
    //si on a un pion blanc (joueur 1), on regarde si il est sur la première ligne
    //si on a un pion noir (joueur 0), on regarde si il est sur la dernière ligne
    if((coord.first == 0 && joueur[1].first == joueur_courant) 
        || (coord.first == TAILLE_DAMIER_DAMES-1 && joueur[0].first == joueur_courant)) {
            DamesPiece* dame;
            //le joueur 1 a les pions blancs, le joueur 0 a les pions noirs
            int longueur{damier->getLongueur()};
            if(joueur[0].first == joueur_courant) {
                dame = new DamesPiece{longueur, PieceCouleur::NOIR, coord, DamesPieceType::DAME};
            } else {
                dame = new DamesPiece{longueur, PieceCouleur::BLANC, coord,DamesPieceType::DAME};
            }
            dame->set_joueur(joueur_courant->id_joueur);
            joueur_courant->retirer_piece_courant(damier->get_id_piece(coord), (int)DamesPieceType::PION);
            damier->suppression_piece(coord);
            damier->ajouter_piece(dame, coord);
            joueur_courant->ajouter_piece_courant(dame->id_courant, (int)DamesPieceType::DAME);
            return true;
    }
    return false;
}

bool Dames::verification_locale(vector<int>* id_piece, Joueur* j) {
    //si on a deux pions sur la trajectoire, on refuse le déplacement
    //on ne mange qu'une piece à la fois
    if(id_piece->size() > 2) {
        return false;
    }

    //si la dernière pièce rencontré est au joueur, on refuse le déplacement
    //on ne mange pas ses propres pièces
    if(id_piece->size() == 2  && j->appartient_joueur(id_piece->at(1))) {
        return false;
    }
    return true;
}

bool Dames::verification_deplacement(vector<pair<int,int>> coord, vector<int>* id_piece) {
    int dist {std::abs(coord[1].first - coord[0].first)};
    int dist2 {std::abs(coord[1].second - coord[0].second)};

    if(dist == 0 && dist2 == 0) {
        update_logger("déplacement impossible: même case");
        return false;
    }

    if(!Mouvement::checkDirectionDiagonalB(coord[0].second, coord[0].first, coord[1].second, coord[1].first, dist) 
        && !Mouvement::checkDirectionDiagonalH(coord[0].second, coord[0].first, coord[1].second, coord[1].first, dist)){
            update_logger("déplacement impossible: pas diagonale");
            return false;
    }

    bool est_dame {damier->get_type_piece(coord[0]) == static_cast<int>(DamesPieceType::DAME)};

    //un pion ne peut pas se déplacer de plus de 2 cases d'un coup
    //une case lors d'un déplacement normal, deux lors d'une prise
    if(dist > 2 && !est_dame) {
        update_logger("déplacement impossible: distance trop grande");
        return false;
    }

    bool res;
    //copie de coord pour ne pas modifier coord
    vector<pair<int,int>> coord_tmp{coord};
    //si la direction est diagonale haut droite
    if(coord[1].first < coord[0].first && coord[1].second > coord[0].second) {
        //on vérifie que la trajectoire est valide
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_haut_droite, &Dames::verification_locale);
        //le pion noir ne peut revenir en arrière que s'il fait une prise
        if(!est_dame && joueur_courant == joueur[0].first && id_piece->size() == 1) {
            return false;
        }
    } 
    //si la direction est diagonale haut gauche
    else if(coord[1].first < coord[0].first && coord[1].second < coord[0].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_haut_gauche, &Dames::verification_locale);

        //le pion noir ne peut revenir en arrière que s'il fait une prise
        if(!est_dame && joueur_courant == joueur[0].first && id_piece->size() == 1) {
            return false;
        }
    }
    //si la direction est diagonale bas droite
    else if(coord[1].first > coord[0].first && coord[1].second > coord[0].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_bas_droite, &Dames::verification_locale);

        //le pion blanc ne peut revenir en arrière que s'il fait une prise
        if(!est_dame && joueur_courant == joueur[1].first &&  id_piece->size() == 1) {
            return false;
        }
    }
    //si la direction est diagonale bas gauche
    else if(coord[1].first > coord[0].first && coord[1].second < coord[0].second) {
        res = damier->verification_case(&coord_tmp, joueur_courant, id_piece, &Mouvement::trajectoire_diagonale_bas_gauche, &Dames::verification_locale);

        //le pion blanc ne peut revenir en arrière que s'il fait une prise
        if(!est_dame && joueur_courant == joueur[1].first && id_piece->size() == 1) {
            return false;
        }
    }
    if(!res)
        update_logger("déplacement impossible: pièce alliés sur la trajectoire ou trop de pièces à manger");
    return res;
}

bool Dames::action(vector<pair<int, int>> coord) {
    vector<int> id_piece{};

    if(!verification_base(coord, joueur_courant))
        return false;

    //test redondant, on ne fait pas confiance à l'interface même s'il a déjà vérifié coord[0]
    //l'interface peut donner d'autres coordonnées que celles de la pièce sélectionnée auparavant par l'interface
    if(!peut_choisir_piece(coord[0]))
        return false;

    //on vérifie que le déplacement est valide puis que la piece n'est pas dans la liste des pièces à manger
    //dans le cas d'une rafle 
    if(!verification_deplacement(coord, &id_piece))
        return false;

    bool res{damier->deplacer_piece(coord[0], coord[1])};

    if(res) {
        if(id_piece.size() == 2) {
            joueur_courant->add_piece_obtenu(id_piece[1]);
        }
        //si le déplacement est bon on recalcule les mouvements possibles et obligatoires
        //on gère aussi la génération des dames
        dernier_joueur = joueur_courant;
        formation_dame(coord[1]);
        id_dernier_piece = damier->get_id_piece(coord[1]);
        mouvement_possible(damier->get_coord_pieces(joueur_courant));
        vector<pair<int,int>> coords = damier->get_coord_pieces(joueur_courant);
        mouvement_obligatoire(damier->get_coord_pieces(joueur_courant));
        for(pair<int,int> c : mouv_obligatoire) {
            cout << "obligatoire : " << c.first << ";" << c.second << endl;
        }
        for(pair<int,int> c : mouv_possible) {
            cout << "possible : " << c.first << ";" << c.second << endl;
        }
    }
    return res;
}

bool Dames::changement_tour_possible() {
    //ils sont égaux que quand une action de joueur_courant est valide
    //on a pas le droit de changer de tour tant qu'on a pas fini de manger
    if(dernier_joueur == joueur_courant && !continuer_rafle()) {
        return true;
    }
    return false;
}

bool Dames::est_fin_partie() {
    for(pair<Joueur*,int> j : joueur) {
        if(j.first->get_nb_type_piece_courant(DamesPieceType::PION) == 0 
            && j.first->get_nb_type_piece_courant(DamesPieceType::DAME) == 0) {
            return true;
        }
    }
    return false;
}

int Dames::get_indice_joueur_gagnant() {
    // retourne le joueur gagnant, celui qui a encore tous ses pièces
    if(joueur[0].first->get_nb_type_piece_courant(DamesPieceType::PION) == 0 
    && joueur[0].first->get_nb_type_piece_courant(DamesPieceType::DAME) == 0)
        return 1;
    else
        return 0;
}

Dames::Dames(int longueur): Modejeu{longueur} {
    update_logger("Tour des blancs");
    init_damier();
    cout << "------ Dames ------" << endl;
    cout << *damier;
}

Dames::~Dames() {
    cout << "Destruction du jeu Dames" << endl;
    mouv_obligatoire.clear();
    mouv_possible.clear();
}

void Dames::init_damier(){    
    for(int i = 0; i < TAILLE_DAMIER_DAMES; i++) {
        bool lignepair{i%2 == 0};
        for(int j = 0; j < TAILLE_DAMIER_DAMES; j++) {
            bool colonnepair{j%2 == 0};
            if(i < 4 && lignepair != colonnepair) {
                // init les pions du joueur noir 
                DamesPiece* noir = new DamesPiece{1,PieceCouleur::NOIR,{i,j}};
                noir->set_joueur(this->joueur[0].first->id_joueur);
                this->damier->ajouter_piece(noir, {i,j});
                this->joueur[0].first->ajouter_piece_courant(noir->id_courant, DamesPieceType::PION);
            } else if(i > 5 && (lignepair == !colonnepair || !lignepair == colonnepair)) {
                // init les pions du joueur blanc
                DamesPiece* blanc = new DamesPiece {1,PieceCouleur::BLANC,{i,j}};
                blanc->set_joueur(this->joueur[1].first->id_joueur);
                this->damier->ajouter_piece(blanc, {i,j});
                this->joueur[1].first->ajouter_piece_courant(blanc->id_courant, DamesPieceType::PION);
            }
        }
    }
    joueur_courant = joueur[1].first;
    vector<pair<int,int>> coords{damier->get_coord_pieces(joueur_courant)};
    mouvement_possible(coords);
}

bool Dames::test_partie_nulle() {
    //si plus aucun mouvement est possible
    if(mouv_possible.size() == 0){
        update_logger("Partie nulle: plus aucun mouvement possible");
        return true;
    }

    //si après 25 coups, aucun pion n'a été pris, la partie est nulle
    //donc 20 pions chacuns
    if(tour >= 25 
        && joueur[0].first->get_nb_type_piece_courant(DamesPieceType::PION) == MAX_PIECE 
        && joueur[1].first->get_nb_type_piece_courant(DamesPieceType::PION) == MAX_PIECE){
        update_logger("Partie nulle: aucun pion n'a été pris après 25 coups");
        return true;
    }

    int n {static_cast<int>(DamesPieceType::DAME)};
    int nb_dames_blanc {joueur[1].first->get_nb_type_piece_courant(n)};
    int nb_dames_noir {joueur[0].first->get_nb_type_piece_courant(n)};

    n = static_cast<int>(DamesPieceType::PION);
    int nb_pion_blanc {joueur[1].first->get_nb_type_piece_courant(n)};
    int nb_pion_noir {joueur[0].first->get_nb_type_piece_courant(n)};

    //si on a 1 ou 2 dames de chaque côté, la partie est nulle
    bool cond1 {(nb_pion_blanc == 0 && nb_pion_noir == 0) 
        && (nb_dames_blanc == nb_dames_noir) 
        && (nb_dames_blanc == 1 || nb_dames_blanc == 2)};

    if(cond1) {
        update_logger("Partie nulle: 1 ou 2 dames de chaque côté");
        return true;
    }

    //les conditions suivantes sont valables après le 16 coups chacuns
    //donc après 32 tours valides
    if(tour <= 32) 
        return false;

    //si on a 1 dame contre 3, la partie est nulle
    bool cond2 {(nb_pion_blanc == 0 && nb_dames_noir == 0) &&
        ((nb_dames_blanc == 1 && nb_dames_noir == 3) 
        || (nb_dames_blanc == 3 && nb_dames_noir == 1))};

    //si on a 2 dames contre 1 pion, la partie est nulle
    bool cond3 {(nb_dames_blanc == 2 && nb_pion_noir == 1 
        && nb_dames_noir == 0 && nb_pion_blanc == 0)
        || (nb_dames_noir == 2 && nb_pion_blanc == 1 
        && nb_dames_blanc == 0 && nb_pion_noir == 0)};

    //si on a 1 dame contre 2 pions, la partie est nulle
    bool cond4 {(nb_dames_blanc == 1 && nb_pion_noir == 2 
        && nb_dames_noir == 0 && nb_pion_blanc == 0)
        || (nb_dames_noir == 1 && nb_pion_blanc == 2 
        && nb_dames_blanc == 0 && nb_pion_noir == 0)};

    if(cond2) {
        update_logger("Partie nulle: 1 dame contre 3");
        return true;
    }

    if(cond3) {
        update_logger("Partie nulle: 2 dames contre 1 pion");
        return true;
    }

    if(cond4) {
        update_logger("Partie nulle: 1 dame contre 2 pions");
        return true;
    }

    return false;

}

bool Dames::changement_joueur() {
    bool res {changement_tour_possible()};
    if(res) {
        if(dernier_joueur == joueur[0].first) {
            update_logger("Tour des blancs");
            joueur_courant = joueur[1].first;
        } else {
            update_logger("Tour des noirs");
            joueur_courant = joueur[0].first;
        }
        ajoute_score(dernier_joueur->get_nb_piece_obtenu());
        vector<int> piece_obt{dernier_joueur->get_piece_obtenu()};
        for(int id : piece_obt) {
            if(!joueur_courant->retirer_piece_courant(id, DamesPieceType::PION))
                joueur_courant->retirer_piece_courant(id, DamesPieceType::DAME);
        }
        damier->suppression_pieces(piece_obt);
        dernier_joueur->vider_piece_obtenu();
        mouvement_possible(damier->get_coord_pieces(joueur_courant));
        mouvement_obligatoire(damier->get_coord_pieces(joueur_courant));
        for(pair<int,int> c : mouv_obligatoire) {
            cout << "obligatoire changement tour: " << c.first << ";" << c.second << endl;
        }
        for(pair<int,int> c : mouv_possible) {
            cout << "possible changement tour: " << c.first << ";" << c.second << endl;
        }
        tour++;
    } else 
        update_logger("Vous ne pouvez pas passer votre tour");
    return res;
}

void Dames::mouvement_possible(vector<pair<int,int>> coord_piece) {
    affichage_logger = false;
    mouv_possible.clear();
    for(int i = 0 ; i < damier->getLongueur(); i++) {
        for(int j = 0; j < damier->getLongueur(); j++) {
            for(pair<int,int> coord : coord_piece) {
                vector<int> id_piece;
                if(verification_deplacement({coord, {i,j}}, &id_piece) && id_piece.size() == 1){
                    bool tmp{false};
                    for(pair<int,int> c : mouv_possible) {
                        if(c.first == coord.first && c.second == coord.second) {
                            tmp = true;
                        }
                    }
                    if(!tmp)
                        mouv_possible.push_back(coord);
                }
            }
        }
    }
    affichage_logger = true;
}

void Dames::mouvement_obligatoire (vector<pair<int, int>> coord_piece) {
    affichage_logger = false;
    mouv_obligatoire.clear();
    for(int i = 0 ; i < damier->getLongueur(); i++) {
        for(int j = 0; j < damier->getLongueur(); j++) {
            for(pair<int,int> coord : coord_piece) {
                vector<int> id_piece;
                if(verification_base({coord, {i,j}}, joueur_courant) && verification_deplacement({coord, {i,j}}, &id_piece) && id_piece.size() == 2){
                    bool tmp{false};
                    pair<int,int> coord1 = damier->get_coord_piece(id_piece[1]);
                    for(pair<int,int> c : mouv_obligatoire) {
                        if(c.first == coord.first && c.second == coord.second) {
                            tmp = true;
                        }
                    }
                    if(!tmp 
                        && (coord1.first != coord.first && coord1.second != coord.second) 
                        && !damier->appartient_joueur(coord1, joueur_courant->id_joueur))
                            mouv_obligatoire.push_back(coord);
                }
            }
        }
    }
    affichage_logger = true;
}

bool Dames::continuer_rafle() {
    pair<int,int> coord{damier->get_coord_piece(id_dernier_piece)};
    vector<pair<int,int>> coord_piece{coord};
    mouvement_obligatoire(coord_piece);

    if(mouv_obligatoire.size() > 0 && dernier_joueur == joueur_courant && dernier_joueur->get_nb_piece_obtenu() > 0) {
        update_logger("Rafle à faire");
        return true;
    }
    return false; 
}

bool Dames::peut_choisir_piece(pair<int,int> coord) {
    //on regatde si la case possède une pièce
    if(damier->est_case_vide(coord)) {
        update_logger("choix impossible: case vide");
        return false;
    }

    if(dernier_joueur == joueur_courant && continuer_rafle()) {
        pair<int,int> coord_dernier_piece{damier->get_coord_piece(id_dernier_piece)};
        if(coord.first != coord_dernier_piece.first || coord.second != coord_dernier_piece.second) {
            update_logger("choix impossible: vous devez continuer la rafle");
            return false;
        }
        return true;
    }

    //à ce stade là, si dernier_joueur == joueur_courant, alors on a fait précédemment un déplacement
    //si on a fait un déplacement, on ne peut pas faire de prises  
    if(dernier_joueur != nullptr && damier->appartient_joueur(coord, dernier_joueur->id_joueur)) {
        update_logger("choix impossible: vous avez déjà fait un déplacement");
        return false;
    }

    //si seulement on a pas de prise obligatoires, on peut choisir une piece parmi les mouvements possibles
    if(mouv_obligatoire.size() == 0) {
        for(pair<int,int> c : mouv_possible) {
            if(c.first == coord.first && c.second == coord.second ) {
                return true;
            }
        }
    } else {
        for (pair<int,int> c : mouv_obligatoire) {
            if(c.first == coord.first && c.second == coord.second) {
                return true;
            }
        }
    }
    update_logger("choix impossible");
    return false;
}

int Dames::nb_coord_voulu() {
    //toujours 2 car on ne fait que des déplacements
    return 2;
}