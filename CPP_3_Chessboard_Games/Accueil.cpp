#include "Accueil.hpp"

// récupère l'enum qui rassemble les jeu disponible
const std::vector<Jeu> jeu {EnumModeJeu::getJeuMode()};

void Accueil::lancerAccueil() {
    const size_t numJeux {jeu.size()};
    int jeuIndice {-1};

    // définit les dimentions des éléments
    const float windowWidth {800.0f};
    const float windowHeight {600.0f};

    const float buttonHeight {windowHeight / (2 * numJeux + 1)};
    const float buttonWidth {windowWidth * 0.8f};
    const float buttonGap {buttonHeight / 2.0f};
    const float taillePolice {buttonHeight / 2.0f};

    float debX {windowWidth / 2.0f};
    float debY {windowHeight / (1.5f * numJeux)};
    sf::RenderWindow homeWindow(sf::VideoMode(windowWidth, windowHeight), "La butin des Dames");

    sf::Font font;
    if (!font.loadFromFile("./ressource/LiberationSans-Italic.ttf")) {
        std::cout << "Erreur chargement de la police" << std::endl;
        return;
    }

    std::vector<sf::RectangleShape> boutons;
    std::vector<sf::Text> textes;

    // défini les boutons pour choisir le jeu à lancer
    for (size_t i = 0; i < numJeux; i++) {
        sf::RectangleShape bouton(sf::Vector2f(buttonWidth, buttonHeight));
        bouton.setOrigin(buttonWidth / 2.0f, buttonHeight / 2.0f);
        bouton.setPosition(debX, debY + i * (buttonHeight + buttonGap));
        bouton.setFillColor(sf::Color::Green);

        sf::Text texte(EnumModeJeu::enumToString(jeu[i]), font, taillePolice);
        texte.setFillColor(sf::Color::Black);
        sf::FloatRect texteRect = texte.getLocalBounds();
        texte.setOrigin(texteRect.left + texteRect.width / 2.0f, texteRect.top + texteRect.height / 2.0f);
        texte.setPosition(debX, debY + i * (buttonHeight + buttonGap));

        boutons.push_back(bouton);
        textes.push_back(texte);
    }

    while (homeWindow.isOpen()) {
        sf::Event event;
        while (homeWindow.pollEvent(event)) {
            if (event.type == sf::Event::Closed)
                homeWindow.close();

            // on a détecté un clic sur un des boutons qu'on a défini plus tot
            // donc on récupère l'indice du jeu à lancer et ferme la fenêtre actuelle
            if (event.type == sf::Event::MouseButtonReleased) {
                sf::Vector2i mousePos = sf::Mouse::getPosition(homeWindow);
                for (size_t i = 0; i < boutons.size(); ++i) {
                    if (boutons[i].getGlobalBounds().contains(static_cast<sf::Vector2f>(mousePos))) {
                        homeWindow.close();
                        jeuIndice = i;
                    }
                }
            }
        }
        homeWindow.clear(sf::Color::White);
        for (size_t i = 0; i < boutons.size(); ++i) {
            homeWindow.draw(boutons[i]);
            homeWindow.draw(textes[i]);
        }
        homeWindow.display();
    }

    if(jeuIndice != -1)
        lanceJeu(jeuIndice);

    std::cout << "NB case " << Case::debug << std::endl;
    std::cout << "NB piece " << Piece::debug << std::endl;
    std::cout << "Fin de l'accueil" << endl;
}

void Accueil::lanceJeu(int jeuIndice) {
    bool blocage{false};
    if(jeuIndice == Jeu::DAMES) blocage = true;
    GameInterface gi {jeu[jeuIndice], blocage};
    gi.initInterface();
}