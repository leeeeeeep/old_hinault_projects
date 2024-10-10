#include "GameInterface.hpp"

GameInterface::GameInterface(Jeu jeu, bool bloque) : enumjeuNum{jeu}, jeu{EnumModeJeu::createJeu(jeu)}, blocage{bloque} {
    std::cout << "Initiation GameInterface" << std::endl;
}

GameInterface::~GameInterface() {
    std::cout << "Fin GameInterface" << std::endl;
    delete jeu;
    squares.clear();
}

const int tileSize{60}; // Taille d'une case du damier
const int infoWidth{250}; // Largeur de la zone d'informations du joueur
int windowWidth;
int windowHeight;

void GameInterface::initInterface() {
    windowWidth = jeu->get_longueur_damier() * tileSize + infoWidth;
    windowHeight = jeu->get_longueur_damier() * tileSize;
    window.create(VideoMode(windowWidth, windowHeight), "La butin de damier");

    init_carreaux();
    float sectionHeight = windowHeight / 2.0f;
    skipTurnButtonRect.setSize(Vector2f(infoWidth, (sectionHeight/4.0f)));
    skipTurnButtonRect.setFillColor(Color(100, 100, 100));
    skipTurnButtonRect.setPosition(jeu->get_longueur_damier() * tileSize, sectionHeight-(sectionHeight/4.0f));

    while(window.isOpen()) {
        fin_de_partie = jeu->est_fin_partie();
        Event event;
        while (window.pollEvent(event)) {
            gestion_Event(event);
        }
        window.clear(sf::Color::White);
        dessine_damier();
        dessine_info();
        window.display();
    }
}

void GameInterface::init_carreaux() {
    for (int row = 0; row < jeu->get_longueur_damier(); row++) {
        for (int col = 0; col < jeu->get_longueur_damier(); col++) {
            RectangleShape square;
            square.setSize(Vector2f(tileSize, tileSize));

            if(enumjeuNum == Jeu::DAMES) {
                if((row + col) % 2 == 0) {
                    square.setFillColor(Color::White);
                } else {
                    square.setFillColor(Color::Black);
                }
            }
            if(enumjeuNum == Jeu::SAFARI) {
                if(row % 2 == 0 || col % 2 == 0) {
                    square.setFillColor(Color::Red);
                }
            }
            square.setPosition(col * tileSize, row * tileSize);
            square.setOutlineColor(Color::Black);
            square.setOutlineThickness(2);
            squares.push_back(square);
        }
    }
}

void GameInterface::dessine_damier() {
    for (const RectangleShape& square : squares) {
        window.draw(square);
    }

    for (int row = 0; row < jeu->get_longueur_damier(); row++) {
        for (int col = 0; col < jeu->get_longueur_damier(); col++) {
            charge_contenu_case(col, row);
        }
    }
}

void GameInterface::charge_contenu_case(int col, int row) {
    string chemin_image = jeu->chemin_image(col, row);
    if(chemin_image != "") {
        charge_image(col, row, chemin_image);
    }
}

void GameInterface::charge_image(int col, int row, string chemin_image) {
    Texture img;
    img.loadFromFile(chemin_image);

    Sprite tuile;
    tuile.setTexture(img);
    const float spriteScaleFactor{1.0f / 5.0f}; // Facteur d'échelle pour le sprite
    tuile.setScale(Vector2f(spriteScaleFactor, spriteScaleFactor));

    float centerX {col * tileSize + (tileSize - tuile.getGlobalBounds().width) / 2.0f};
    float centerY {row * tileSize + (tileSize - tuile.getGlobalBounds().height) / 2.0f};
    tuile.setPosition(centerX, centerY);
    window.draw(tuile);
}

void GameInterface::dessine_info() {
    float sectionHeight {windowHeight / 2.0f};
    sf::Font font;
    if (!font.loadFromFile("./ressource/LiberationSans-Italic.ttf")) {
        std::cout << "Erreur chargement de la police" << std::endl;
        return;
    }

    // Section pour les infos du joueur
    RectangleShape playerInfoSection(Vector2f(infoWidth, sectionHeight));
    playerInfoSection.setFillColor(Color(200, 200, 200));
    playerInfoSection.setPosition(jeu->get_longueur_damier() * tileSize, 0);
    window.draw(playerInfoSection);

    Text playerInfoText("Infos des Joueurs\n\n", font, 16);
    int posTextX{jeu->get_longueur_damier() * tileSize + 10};
    int posTextY{5};
    playerInfoText.setPosition(posTextX, posTextY);
    window.draw(playerInfoText);

    int taillePolice = playerInfoText.getCharacterSize();
    posTextY += taillePolice + 10; // 10 pour avoir un peu d'espace entre les textes
    const vector<int> scores{jeu->get_score()};
    int indice_joueur_courant = jeu->get_indice_joueur_courant();

    for(int i = 0; i < (int)scores.size(); i++) {
        Text playerInfo("Player " + to_string(i) + "\n Score : " + to_string(scores[i]) + "\n\n", font, 16);
        if(i == indice_joueur_courant)
            playerInfo.setFillColor(Color::Black);
        playerInfo.setPosition(posTextX, posTextY);
        posTextY += playerInfoText.getCharacterSize()*2 + 10;

        window.draw(playerInfo);
    }

    // Section pour le bouton skip
    window.draw(skipTurnButtonRect);
    Text skipTurnButtonText("Passer le Tour", font, 16);
    skipTurnButtonText.setPosition(jeu->get_longueur_damier() * tileSize + 10, sectionHeight - (sectionHeight/4.0f) + 5);
    window.draw(skipTurnButtonText);

    // Section pour le logger
    string textTmp;
    if(fin_de_partie) {
        int joueurgagnant_i{jeu->get_indice_joueur_gagnant()};
        textTmp = "Joueur " + to_string(joueurgagnant_i) + " gagne";
    } else if(jeu->test_partie_nulle()) {
        textTmp = jeu->get_logger();
    }
    Text joueurgagnantText{textTmp, font, 16};
    joueurgagnantText.setPosition(jeu->get_longueur_damier() * tileSize + 10, sectionHeight + 5);
    joueurgagnantText.setFillColor(Color::Black);
    window.draw(joueurgagnantText);
}

vector<pair<int,int>> coords;

void GameInterface::gestion_Event(Event event) {
    switch(event.type) {
        case Event::Closed:
            window.close();
            break;
        case Event::MouseButtonPressed:
            if (event.mouseButton.button == Mouse::Left && !fin_de_partie) {
                Vector2f mouse = window.mapPixelToCoords(Mouse::getPosition(window));
                if(skipTurnButtonRect.getGlobalBounds().contains(mouse)) {
                    cout << "[GUI] Clic sur le skip" << endl;
                    if(jeu->changement_joueur()) {
                        coords.clear();
                    }
                    break;
                }
                for (const RectangleShape square : squares) {
                    if (!square.getGlobalBounds().contains(mouse)) {
                        continue;
                    }
                    int col {static_cast<int>(mouse.x / tileSize)};
                    int row {static_cast<int>(mouse.y / tileSize)};
                    cout << "[GUI] : case " << row << col << endl;
                    if(coords.size() == 0) {
                        if(jeu->peut_choisir_piece({row,col})) {
                            cout << "[GUI] peut choisir ok" << endl;
                            coords.push_back({row,col});
                        }
                    } else {
                        coords.push_back({row,col});
                    }
                    if(jeu->nb_coord_voulu() == (int)coords.size()) {
                        if(jeu->nb_coord_voulu() == 2)
                            cout << "[GUI] " << coords[0].first << coords[0].second << " a " << coords[1].first << coords[1].second << endl;
                        if(jeu->action(coords)) {
                            coords.clear();
                            cout << "[GUI] action ok" << endl;
                        } else {
                            cout << "[GUI] action fail" << endl;
                            if(!blocage) { 
                                // l'action a échoué donc on supprime tous les coordonnées qu'on a stocker
                                coords.clear();
                            } else {
                                // l'action a échoué donc on supprime la dernière coordonnée qu'on a rajouté
                                coords.pop_back();
                            }
                        }
                    }
                }
            }
            break;
        default:
            break;
    }
}