CPP = g++ --std=c++11 -Wall
CCO = $(CPP) -c $<
OBJECTS = Case.o Piece.o Joueur.o Damier.o Mouvement.o ButinPiece.o DamesPiece.o SafariPiece.o Modejeu.o Butin.o Dames.o Safari.o Accueil.o GameInterface.o Main.o

all: $(OBJECTS)
	$(CPP) -o main $(OBJECTS) -lsfml-graphics -lsfml-window -lsfml-system

Case.o : Case.cpp Case.hpp
	$(CCO)

Piece.o: Piece.cpp Piece.hpp Joueur.hpp
	$(CCO)

Joueur.o : Joueur.cpp Joueur.hpp
	$(CCO)

Damier.o : Damier.cpp Damier.hpp Case.hpp
	$(CCO)

Mouvement.o : Mouvement.cpp Mouvement.hpp
	$(CCO)

ButinPiece.o : ButinPiece.cpp ButinPiece.hpp Piece.hpp
	$(CCO)

DamesPiece.o : DamesPiece.cpp DamesPiece.hpp Piece.hpp
	$(CCO)

SafariPiece.o : SafariPiece.cpp SafariPiece.hpp Piece.hpp
	$(CCO)

Modejeu.o : Modejeu.cpp Modejeu.hpp Damier.hpp Mouvement.hpp
	$(CCO)

Butin.o : Butin.cpp Butin.hpp Modejeu.hpp ButinPiece.hpp
	$(CCO)

Dames.o : Dames.cpp Dames.hpp Modejeu.hpp DamesPiece.hpp
	$(CCO)

Safari.o : Safari.cpp Safari.hpp Modejeu.hpp SafariPiece.hpp
	$(CCO)

GameInterface.o : GameInterface.cpp GameInterface.hpp Modejeu.hpp
	$(CCO)

Accueil.o : Accueil.cpp Accueil.hpp EnumModeJeu.hpp GameInterface.o
	$(CCO)

Main.o: Main.cpp Accueil.hpp
	$(CCO)

clean:
	rm -f *.o main