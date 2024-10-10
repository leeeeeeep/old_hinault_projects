
module.exports = {
    predicat: function(produits, filtres, types) {
            //si on a catégorie dans l'URL 
        //et si cette catégorie valide -> dans types.categorie
        if(filtres.categorie != undefined) {
            let index = types.categorie.indexOf(filtres.categorie);
            if(index != -1) {
                switch(index){
                    case 0: produits = produits.filter(
                        element => types.types_hauts_over.includes(element.info.type)
                        === true)
                        console.log("haut_couvrant");
                        break;
                    case 1: produits = produits.filter(
                        element => types.types_hauts.includes(element.info.type)
                        === true)
                        break;
                    case 2: produits = produits.filter(
                        element => types.types_bas.includes(element.info.type)
                        === true)
                        break;
                    case 3: 
                        let accessoire = types.types_accessoires_bas.concat(
                            types.types_accessoires_chaussures);
                        accessoire = accessoire.concat(
                            types.types_accessoires_col);
                        accessoire = accessoire.concat(
                            types.types_accessoires_haut);
                        accessoire = accessoire.concat(
                            types.types_accessoires_standalone);
                        produits = produits.filter(
                            element => accessoire.includes(element.info.type) === true);
                        break; 
                    case 4: 
                        produits = produits.filter(
                            element => types.types_chaussures.includes(
                                element.info.type) === true
                        )
                        break;
                }
            }
        }
        if(filtres.couleur != undefined && types.couleur.indexOf(filtres.couleur) != -1) {
            for(let i = 0; i < produits.length; i++) {
                produits[i].info.stock = produits[i].info.stock.filter(
                    e => e.couleur === filtres.couleur
                );
            }
        }
        if (filtres.sexe != undefined && types.sexe.indexOf(filtres.sexe) != -1) {
            produits = produits.filter (
                element => element.info.sexe === filtres.sexe
            );
        }
        if(filtres.taille != undefined && types.tailles.indexOf(filtres.taille) != -1) {
            for(let i = 0; i < produits.length; i++) {
                produits[i].info.stock = produits[i].info.stock.filter(
                    e => e.taille === filtres.taille
                );
            }
        }
        if(filtres.matiere != undefined && types.matiere.indexOf(filtres.matiere) != -1) {
            produits = produits.filter (
                element => element.info.matiere === filtres.matiere
            );
        }
        if(filtres.style != undefined && types.style.indexOf(filtres.style) != -1) {
            produits = produits.filter (
                element => element.info.style === filtres.style
            );
        }
        return produits;
    }
};