all:
	# -shell escape : nécessaire pour minted
	pdflatex -shell-escape rapport-crocombette--pasquet-hinault.tex
	# on compile une deuxième fois pour les références
	pdflatex -shell-escape rapport-crocombette--pasquet-hinault.tex

clean:
	rm -rf *bak *~ *out *log *aux _minted-rapport-crocombette--pasquet-hinault *.aex
