//modifie l'affichage de la quantite disponible
function ajustementQuantite(quantiteStock) {
    let quantite = document.getElementById("quantite");
    //on désactive le bouton si la quantite est nulle
    let bouton = document.getElementById("envoi");
    if(quantiteStock == 0) {
        bouton.disabled = true;
        quantite.value = 0;
        quantite.max = 0;
        quantite.min = 0;
    } else {
        bouton.disabled = false;
        //on limite à 10 la quantite max
        if(quantiteStock < 10) {
            quantite.max = quantiteStock;
        } else {
            quantite.max = 10;
        }
        quantite.value = 1;
        quantite.min = 1;
    }
}

//trouve les tailles disponibles pour un produit
function tailleDispo(produit, id, couleur)  {
    let taille = [];
    for(let i = 0; i < produit[id - 1].info.stock.length; i++) {
        if(produit[id - 1].info.stock[i].quantite > 0 
            && produit[id - 1].info.stock[i].couleur == couleur 
            && !taille.includes(produit[id - 1].info.stock[i].taille)) {

            console.log(produit[id - 1].info.stock[i]);
            taille.push(produit[id - 1].info.stock[i].taille);

        }
    }
    return taille;
}

//fait les options d'un select 
//selon le tableau types
function makeSelect(type, select) {
    for(let i = 0; i < type.length;  i++) {
      let option = document.createElement("option");
      option.appendChild(document.createTextNode(type[i]));
      select.appendChild(option);
    }
}

//nouveau affichage en cas de changement de taille
//et de quantite disponibles
function updateAffichage(combinaison, produit) {

    
    let quantiteStock = 10;

    for(let i = 0; i < combinaison.info.length; i++) {
        //info -> tableau de couple (ID, index stock)
        let id = combinaison.info[i][0];
        let subId = combinaison.info[i][1];
        quantiteStock = Math.min(produit[id - 1].info.stock[subId].quantite, quantiteStock);
        console.log(quantiteStock);
    }


    ajustementQuantite(quantiteStock);
}

let comb;

function affichageCombinaison(produit, combinaison) {

    //pour la fonction send
    comb = combinaison;

    //conteneur des menus tailles 
    let containerSelect = document.getElementById("info-complement");

    let prix = document.getElementById("prix");
    let prixAffiche = combinaison.prix;
    let allPhoto = [];
    //quanbtite max qu'on peut ajouter au panier
    let quantiteStock = 10;

    //on récupère les photos
    //on additionne le prix de tous les produits de la combinaison
    for(let i = 0; i < combinaison.info.length; i++) {
        
        //info -> tableau de couple (ID, index stock)
        let id = combinaison.info[i][0];
        let subId = combinaison.info[i][1];
        quantiteStock = Math.min(produit[id - 1].info.stock[subId].quantite, quantiteStock);
        allPhoto.push(produit[id - 1].info.stock[subId].img);

        let tailleDisp = tailleDispo(produit, id, produit[id - 1].info.stock[subId].couleur);
        let div = document.createElement("div");
        let label = document.createElement("label");
        label.appendChild(document.createTextNode("  Taille " + produit[id - 1].info.type + " : "));
        let select = document.createElement("select");

        makeSelect(tailleDisp, select);
        div.appendChild(label);
        div.appendChild(select);
        containerSelect.appendChild(div);

        select.addEventListener("change", function() {
            combinaison.info[i][1] = produit[id - 1].info.stock.findIndex(x => x.taille == select.value);
            updateAffichage(combinaison, produit);
        });

        console.log(produit[id - 1].info);
    }

    ajustementQuantite(quantiteStock);

    //on affiche le prix 
    prix.appendChild(document.createTextNode(prixAffiche + "€"));

    //le bouton qui va servir à cycler les photos de la combinaison
    let cycle = document.getElementById("cycle-photo");
    //l'index dans ce cycle
    let idCycle = 0;

    let photo = document.getElementById("photo-combi");
    photo.src = allPhoto[idCycle];

    cycle.addEventListener("click", function() {
        idCycle++;
        if(idCycle === allPhoto.length) {
            idCycle = 0;
        }
        photo.src = allPhoto[idCycle];
    })

    //description de la combinaison
    let description = document.getElementById("description");
    description.appendChild(document.createTextNode(combinaison.description));
    
    
}

function send() {
    //pour remplir le champs hidden combi
    //qui le tableau de couple (ID, index stock)
    //pour le mettre dans le panier
    let combiSend = document.getElementById("combi");
    combiSend.value = JSON.stringify(comb);
    let form = document.getElementById("form");
    form.submit();
}