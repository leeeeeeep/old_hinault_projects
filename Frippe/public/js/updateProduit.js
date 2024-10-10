
//selon le tableau types
function makeSelect(type, select) {
    for(let i = 0; i < type.length;  i++) {
      let option = document.createElement("option");
      option.appendChild(document.createTextNode(type[i]));
      select.appendChild(option);
    }
}

//taille de chaussures
let tabTaille = [];
for(let i = 28; i < 46; i++) {
    tabTaille.push(i);
}

let prod;
let prodId;

function affichage_modif (produit, id, types, allPhoto) {
    let photoProd = document.getElementById("photo-prod");
    //affichage de la première photo du produit
    if(produit.info.stock.length > 0) {
        photoProd.src = produit.info.stock[0].img;
    }

    prod = produit;
    prodId = id;
    let couleurDispo = produit.info.stock.map(element => element.couleur);
    //pour retirer les doublons
    couleurDispo = couleurDispo.filter((element, index) => {
      return couleurDispo.indexOf(element) === index; });
    
    //menu déroulant des couleurs
    let selectCouleur = document.getElementById("col");
    makeSelect(types.couleur, selectCouleur);

    //menu déroulant des tailles
    let selectTaille = document.getElementById("taille");
    //cas de taille de chaussures
    if(types.types_chaussures.find(element => element 
        === produit.info.type)) {
        makeSelect(tabTaille, selectTaille);
    } else {
        makeSelect(types.tailles, selectTaille);
    }

    //menu déroulant des photos
    let selectPath = document.getElementById("photo-path");
    console.log(allPhoto);
    allImg = allPhoto.map(element => element.img);
    console.log(allImg);
    console.log(allPhoto);
    makeSelect(allImg, selectPath);

    selectPath.addEventListener("change", function() {
        photoProd.src = selectPath.value;
    });


}

function send() {
    let selectCouleur = document.getElementById("col");
    let selectTaille = document.getElementById("taille");
    let selectQuantite = document.getElementById("quantite");
    let selectPhoto = document.getElementById("photo-path");


    //pour trouver l'index dans le stock du produit à un ID
    let predicatSubId = element => 
        element.taille === selectTaille.value &&
        element.couleur === selectCouleur.value;
    let res = prod.info.stock.findIndex(predicatSubId);

    //vérification avant envoi
    //les autres ont déjà des valuers par défaut
    if(selectPhoto.value.length > 0) {
        if(prod.info.stock[res] != undefined) {
            prod.info.stock[res].quantite = Number(selectQuantite.value);
            console.log(selectPhoto.value);
            prod.info.stock[res].img = selectPhoto.value;
        } else {
            let newStock = {taille: selectTaille.value, 
            couleur: selectCouleur.value, 
            quantite: Number(selectQuantite.value), 
            img: selectPhoto.value};
            prod.info.stock.push(newStock);
        }    

        //on rempli le formulaire avec nos informations
        let info = document.getElementById("prod");
        info.value = JSON.stringify(prod.info);

        let idProduit = document.getElementById("idProduit");
        idProduit.value = prodId;

        let form = document.getElementById("form");
        form.submit();
    }
}