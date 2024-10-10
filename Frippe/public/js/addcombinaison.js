
//fait les options d'un select 
//selon le tableau types
function makeSelect(type, select) {
  for(let i = 0; i < type.length;  i++) {
    let option = document.createElement("option");
    option.appendChild(document.createTextNode(type[i]));
    select.appendChild(option);
  }
}

//fait les options d'un select de produit
function makeSelectProd(produits, select) {
  for(let i = 0; i < produits.length; i++ ) {
    let op = document.createElement("option");
    op.setAttribute("id", produits[i]);
    op.appendChild(document.createTextNode(produits[i].id_produit + " - " + produits[i].info.description));
    select.appendChild(op);
  }
}

//fait les options d'un select 
function makeSelectQuantite(quantite, select) {
  for(let i = 0 ; i < quantite; i++) {
    let option = document.createElement("option");
    option.appendChild(document.createTextNode(i));
    select.appendChild(option);
  }
}

//supprime les choix d'un select
function deleteSelect(select){
  let child = select.lastElementChild;
  while (child) {
    select.removeChild(child)
    child = select.lastElementChild;
  }
}

//pour se retrouver dans les différents types 
let combinaison = ["accessoire", "haut_couvrant", "haut", "bas", "chaussure"];
function init(produits, types) {

  let i = 0;
  //on produit chaque cas pour la construction d'une combinaison
  //on laisse pour l'instant ces 5 types à remplir si on le veut
  while(i < combinaison.length) {
    switch(i) {
      case 0: combi(produits, types.types_accessoires_standalone, combinaison[0], types);
        i++;
        break;
      case 1: combi(produits, types.types_hauts_over, combinaison[1], types);
        i++;
        break;
      case 2: combi(produits, types.types_hauts, combinaison[2], types);
        i++;
        break;
      case 3: combi(produits, types.types_bas, combinaison[3], types);
        i++;
        break; 
      case 4: combi(produits, types.types_chaussures, combinaison[4], types);
        i++;
        break;
    }
  }

   
}

let allId = [];


function combi(produits, types, typeStr, allTypes) {
  
  let body = document.body;


  let container = document.createElement("div");
  container.classList.add("container-combi");
  body.appendChild(container);

  let containerProd = document.createElement("div");
  containerProd.classList.add("container-prod");
  container.appendChild(containerProd);

  //conteneur de la photo
  let photoCont = document.createElement("div");
  photoCont.classList.add("photo");
  //photo
  let img = document.createElement("img");
  img.alt = "/Produits/default.png";
  img.classList.add("photo");
  img.src = "/Produits/default.png";
  photoCont.appendChild(img);
  containerProd.appendChild(photoCont);

  //conteneur des choix
  let info = document.createElement("div");
  info.classList.add("info");
  containerProd.appendChild(info);

  //conteneurs de choix spécifiques
  let selectCont = document.createElement("div");
  info.appendChild(selectCont);

  let selectProdCont = document.createElement("div");
  info.appendChild(selectProdCont);

  let selectCouleurCont = document.createElement("div");
  info.appendChild(selectCouleurCont);

  let selectTailleCont = document.createElement("div");
  info.appendChild(selectTailleCont);

  //menu déroulant de type
  let select = document.createElement("select");
  select.setAttribute("id", "select");
  makeSelect(types, select);
  select.value = "type accessoire";
  
  //menu déroulant de produits
  let selectProd = document.createElement("select");
  selectProd.setAttribute('id', "selectProd");

  //menu déroulant de couleurs 
  let selectCouleur = document.createElement("select");
  selectCouleur.setAttribute("id", "selectCouleur");

  //menu déroulant de taille 
  let selectTaille = document.createElement("select");
  selectTaille.setAttribute("id", "selectTaille");
  
  //label 
  let selectLabel = document.createElement("label");
  selectLabel.htmlfor = "select";
  selectLabel.appendChild(document.createTextNode("Type " + typeStr + "  "));

  //label
  let selectProdLabel = document.createElement("label");
  selectProdLabel.htmlfor = "selectProd";
  selectProdLabel.appendChild(document.createTextNode("Choix produit  "));
  
  //label
  let selectCouleurLabel = document.createElement("label");
  selectCouleurLabel.htmlfor = "selectCouleur";
  selectCouleurLabel.appendChild(document.createTextNode("Choix couleur  "));

  //label 
  let selectTailleLabel = document.createElement("label");
  selectTailleLabel.htmlfor = "selectTaille";
  selectTailleLabel.appendChild(document.createTextNode("Choix taille  "));

  //on assemble tout 
  selectCont.appendChild(selectLabel);
  selectCont.appendChild(select);
  selectProdCont.appendChild(selectProdLabel);
  selectProdCont.appendChild(selectProd);
  selectCouleurCont.appendChild(selectCouleurLabel);
  selectCouleurCont.appendChild(selectCouleur);
  selectTailleCont.appendChild(selectTailleLabel);
  selectTailleCont.appendChild(selectTaille);

  //ID produit
  let prodId = -1;
  //couleur
  let col = "";
  //taille
  let staille = "";
  //couple ID, subID dans le stock
  let id = [];
  //index dans le tableau allID 
  //si on a beosin d'enlever
  let index = -1;
  //index dans le stock du produit courant
  let subId = -1;

  //pour séléctionner un type de produit
  //dans une catégorie: hauts, bas, chaussure
  select.addEventListener("change", function() {
    deleteSelect(selectProd);
    deleteSelect(selectCouleur);
    deleteSelect(selectTaille);
    let accFilter = produits.filter(element => types.find(e => e === element.info.type) 
      && element.info.type === select.value );
    makeSelectProd(accFilter, selectProd);
    selectProd.value = "Choix du produit";
    staille = "";
    col = "";
    prodId = -1;


    if(id.length != 0) {
      id = [];
      subId = -1;
      if(index != -1) {
        allId.splice(index, 1);
        index = -1;
      }
    }
  });

  //pour quand on séléctionne un produit
  //on peut trouver toutes les couleurs pour un produit
  selectProd.addEventListener("change", function() {
    prodId = selectProd.value.split(' ')[0];
    prodId = Number(prodId);
    img.src = produits[prodId - 1].info.stock[0].img;
    let couleurDispo = produits[prodId - 1].info.stock.filter(element => element.quantite > 0);
    couleurDispo = couleurDispo.map(element => element.couleur);
    couleurDispo = couleurDispo.filter((element, index) => {
      return couleurDispo.indexOf(element) === index; });
    deleteSelect(selectCouleur);
    deleteSelect(selectTaille);
    makeSelect(couleurDispo, selectCouleur);
    selectCouleur.value = "couleur";
    staille = "";
    col = "";


    if(id.length != 0) {
      id = [];
      subId = -1;
      if(index != -1) {
        allId.splice(index, 1);
        index = -1;
      }
    }
  })

  let accAdded = false;

  //pour quand on choisi une couleur
  //on peut calculer les tailles disponibles
  //avec la couleur
  selectCouleur.addEventListener("change", function() {
    col = selectCouleur.value;
    deleteSelect(selectTaille);
    let tailleDispo = produits[prodId - 1].info.stock.filter(element => element.couleur === col)
    tailleDispo = tailleDispo.map(element => element.taille);
    tailleDispo = tailleDispo.filter((element, index) => {
      return tailleDispo.indexOf(element) === index; });
    makeSelect(tailleDispo, selectTaille);
    selectTaille.value = "taille";
    staille ="";
    if(id.length != 0) {
      id = [];
      subId = -1;
      if(index != -1) {
        allId.splice(index, 1);
        index = -1;
      }
    }
  })


  //si on rempli une case en entier, alors on génère un espace pour les accessoires
  //correspondant --> une manteau avec une écharpe par exemple
  selectTaille.addEventListener("change", function() {
    if(accAdded == false && typeStr != "accessoire") {
      accAdded == true;
      if(typeStr == combinaison[2] && select.value === "chemise") {
        combi(produits, allTypes.types_accessoires_col, "accessoire "+ typeStr);
      } else if (typeStr == combinaison[2] || typeStr == combinaison[1]) {
        combi(produits, allTypes.types_accessoires_haut, "accessoire "+ typeStr);
      } 
      else if (typeStr == combinaison[3])  {
        combi(produits, allTypes.types_accessoires_bas, "accessoire "+ typeStr);
      } else if (typeStr == combinaison[4]) {
        combi(produits, allTypes.types_accessoires_chaussures, "accessoire "+ typeStr);
      }
    }

    //dès que toutes les infos remplies, on peut avoir le produit qu'on veut
    //on l'ajoute aux produits
    if(id.length != 0) {
      id = [];
      subId = -1;
      if(index != -1) {
        allId.splice(index, 1);
        index = -1;
      }
    }

    //dès que tout est rempli on stocke dans le tableau allId
    //on stocke que l'ID et l'index dans le stock de ce produit
    staille = selectTaille.value;
    subId = produits[prodId - 1].info.stock.findIndex(element => element.couleur === col && element.taille === staille);
    id.push(prodId);
    id.push(subId);
    allId.push(id);
    index = allId.length - 1;

  })
}

//fonction pour le bouton d'envoi
//on récupère le tableau des produits
//on envoie en post la description, prix et produits
function send() {

  let description = document.getElementById("description");
  let prix = document.getElementById("prix");
  //il faut au moins tous les champs rempli + au moins 2 produits
  //pour envoyer
  if (allId.length >= 2 && description.value.length > 0 && prix.value > 0 ) {
    let form = document.getElementById("form");
    let text = document.getElementById("text");
    let toSend = JSON.stringify(allId);
    text.value = toSend;
    form.submit();
    
  }


}
