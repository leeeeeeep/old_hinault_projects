let allBoutonsSuggestions = [];

function affichageProduit(produit, subId, gerant, idProd, types, allProd) {
  
  let tailleArray = [];
  let couleurArray = [];
  let tailleCourante = produit.info.stock[subId].taille
  let couleurCourante = produit.info.stock[subId].couleur;
  let quantiteCourante = produit.info.stock[subId].quantite;
  console.log(quantiteCourante);

  if(quantiteCourante < 1) {
    let bouton = document.getElementById("envoi");
    console.log(bouton);
    bouton.disabled = true;
  }

  

  //si on affiche ou non le bouton pour modifier le produit 
  //qu'on est en train de consulter
  //seul un  gérant peut le faire.
  let gerantBouton = document.getElementById("modif");
  if(gerant != true) {
    gerantBouton.style.visibility = "hidden";
  }
  gerantBouton.href = "/updateProduit?id="+idProd;

  //pour le panier on enverra ensuite l'id et son index 
  //dans le stock de ce produit.
  let submitId = document.getElementById("id_produit");
  submitId.value = produit.id_produit;

  let submitSubId = document.getElementById("subId");
  submitSubId.value = subId;

  //on cherche toutes les tailles et couleur
  //qui ont été disponibles pour ce produit
  for (elem of produit.info.stock) {
    if(tailleArray.find(element => element === elem.taille) == undefined) {
      tailleArray.push(elem.taille);
    }
    if(couleurArray.find(element => element === elem.couleur) == undefined) {
      couleurArray.push(elem.couleur);
    }
  }

  //cadre de la photo
  let photo = document.getElementById("photo-produit");

  //affichage photo produit
  let photoProd = document.createElement("img");
  photoProd.alt = "/Produits/default.png";
  photoProd.classList.add("photo-produit");
  photoProd.src = produit.info.stock[subId].img;
  photo.appendChild(photoProd);

  //contiendra le prix, les select et les couleurs
  let info = document.getElementById("info");

  //affichage prix
  let prix = document.getElementById("prix");
  prix.appendChild(document.createTextNode(produit.info.prix + '€'))
 
  //menu déroulant des quantités 
  let selectQuantite = document.getElementById("quantite");
  //on initialise la première valeur lors du premier chargement
  selectQuantite.value = quantiteCourante;
  for (let i = 1; i <= 10; i++) {
    let optionQuantite = document.createElement("option");
    optionQuantite.appendChild(document.createTextNode(i));
    optionQuantite.value = i;
    selectQuantite.appendChild(optionQuantite);
    //on désactive la quantité si on en a pas assez
    if(quantiteCourante < i) {
      optionQuantite.disabled = true;
    }
    console.log(quantiteCourante);
  }

  if(quantiteCourante < 1) {
    selectQuantite.value = 0;
    selectQuantite.disabled = true;
  } else {
    selectQuantite.disabled = false;
  }
  

  //le menu déroulant des tailles
  let selectTaille = document.getElementById("select");
  
  //on initalise les tailles disponibles
  //pour le menu déroulant
  let acc = 0;
  for(choixTaille of tailleArray) {
    let option = document.createElement("option");
    option.setAttribute("id", "option"+acc);
    selectTaille.appendChild(option);
    option.value = choixTaille;
    option.appendChild(document.createTextNode(choixTaille));
    acc++;

    let dispo = produit.info.stock.find(element => element.taille === choixTaille && element.couleur === couleurCourante && element.quantite > 0);
    
    //on désactive l'option si la taille n'est pas disponible pour la couleur courante
    if(dispo == undefined) {
      option.disabled = true;
    }
  }
  
  //à chaque fois qu'on change de taille on actualise
  //les quantités disponibles
  selectTaille.addEventListener("change", function() {
    //on cherche la taille grâce au addEventListener
    //alors on actualise la taille courante
    tailleCourante = selectTaille.value; 
    selectQuantite.value =  cascadeUpdate(submitSubId, produit, couleurCourante, tailleCourante);
    
    
  })
  
  //on initalise la valeur du menu taille 
  //pour le premier chargement de la page
  selectTaille.value = tailleCourante;

  //couleur contiendra toutes les carrés de couleur
  let couleur = document.getElementById("couleur");
  couleur.appendChild(document.createTextNode('Couleur : '));

  let cpt = 0;
  
  //on génère chaque carré de couleur 
  //selon les couleurs disponibles dans couleurArray
  for(col of couleurArray) {
    //square est un petit carré qui contiendra la couleur
    let square = document.createElement("div");
    square.classList.add("square");
    square.style.background = col;
    square.setAttribute('id', "couleur" + cpt);
    cpt++;


    //on cherche si on a moins un produit disponible
    //pour cette couleur
    let disponibilite = produit.info.stock.find(element => element.quantite > 0 && element.couleur === col );
    //mise à jour des quantite disponibles
    
    //pour montrer la couleur courante 
    //lors du premier affichage de la page
    if(couleurCourante === col) {
      square.style.border = "1px solid orange";
    }

    //On actualise la taille, la quantité et la photo
    //quand on choisi une nouvelle couleur
    square.addEventListener("click", function couleurListener() {

      //on change l'affichage de la nouvele couleur courante
      //et on change la valeur de couleur courante 
      for (let i = 0; i < couleur.children.length; i++) {
        if(couleur.children[i].getAttribute("id") === square.getAttribute("id") ) {
          couleur.children[i].style.border = "1px solid orange";
          couleurCourante = couleurArray[i];
          //on cherche le premier produit qui correspond à la couleur choisie 
          //puis on actualise la photo du produit
          let indexCourant = produit.info.stock.findIndex(element => element.couleur == couleurCourante);
          photoProd.src = produit.info.stock[indexCourant].img;
        } else {
          couleur.children[i].style.border = "1px solid black";
        }
      }
      
      //on cherche les tailles disponibles et on actualise la valeur du menu déroulant
      //on met indefined si aucune taille n'est disponible, donc tous les choix sont désactivés
      let tailleDispo = produit.info.stock.filter(element => element.couleur == couleurCourante && element.quantite > 0);
      tailleDispo = tailleDispo.map(element => element.taille);
      if(tailleDispo.length != 0) {
        selectTaille.value = tailleDispo[0];
        tailleCourante = tailleDispo[0];
      } else {
        tailleCourante = undefined;
        selectTaille.value = "";
      }
      
      //lors du choix de la couleur, on actualise les tailles disponibles
      //on désactive le bouton si la taille n'est pas disponible pour la couleur courante
      for(let i = 0; i < tailleArray.length; i++) {
        if(tailleCourante == undefined || tailleDispo.indexOf(tailleArray[i]) == -1) {
          selectTaille.children[i].disabled = true;
        } else {
          selectTaille.children[i].disabled = false;
        }
      }

      //on actualise ensuite les quantites disponibles pour la première taille disponible pour cette couleur
      selectQuantite.value = cascadeUpdate(submitSubId, produit, couleurCourante, tailleCourante);
    })
    

    //pour montrer que la couleur est en fait Indisponible
    if(disponibilite == undefined) {
      square.style.opacity = "33%";
    }

    //on ajoute la couleur à l'affichage
    couleur.appendChild(square);

    //dans le cas où il n'y a plus de produit on affiche un message
    if(disponibilite == undefined && produit.info.stock[subId].couleur == col) {
      addDispo();
    }
    
  }

  //Ajout de la description du produit
  let description = document.getElementById("description");
  description.appendChild(document.createTextNode(produit.info.description));



  //on défini le type d'accessoire qu'on veut proposer
  let typeAccessoires = accessoireType(produit, types);

  //le cas undefined, quand on est déjà sur une page accessoire
  //alors on ne propose pas d'autres accessoires
  if(typeAccessoires != undefined) {
    //container de toutes les suggestions
    let containerSuggestions = document.getElementById("container-suggestion");
    //on récupère tous les produits
    let accessoires = allProd;
    //on filtre les produits pour ne garder que ceux qui sont du type compatible
    accessoires = accessoires.filter(element => typeAccessoires.includes(element.info.type));

    //on choisit 6 produits parmi les produits compatibles
    let length = accessoires.length;
    if(length > 6) {
      length = 6;
    }
    //pour éviter de montrer deux fois le même produit
    let randomPicked = [];
    for (let i = 0; i < length; i++) {
      //on va proposer 6 produits aléatoires ou moins
      let random = Math.floor(Math.random() * accessoires.length);
      while(randomPicked.includes(random)) {
        random = Math.floor(Math.random() * accessoires.length);
      }
      //on les insère pour éviter de se répéter
      randomPicked.push(random);
      //on filtre les produits pour ne garder que ceux qui sont du type compatible
      accessoires[random].info.stock = accessoires[random].info.stock.filter(element => element.quantite > 0);

      //on affiche le produit si il est disponible
      if(accessoires[random].info.stock.length != 0) {

        //container de la suggestion
        let suggestion = document.createElement("div");
        suggestion.classList.add("suggestion");

        //photo du produit suggestion
        let photoSuggestions = document.createElement("img");
        photoSuggestions.alt = "/Produits/default.png";
        photoSuggestions.src = accessoires[random].info.stock[0].img;
        photoSuggestions.classList.add("photo-suggestion");
        suggestion.appendChild(photoSuggestions);

        //nom du produit suggestion
        let nomSuggestions = document.createElement("p");
        nomSuggestions.appendChild(document.createTextNode(accessoires[random].info.description));
        nomSuggestions.classList.add("nom-suggestion");
        suggestion.appendChild(nomSuggestions);

        //prix du produit suggestion
        let prixSuggestions = document.createElement("p");
        prixSuggestions.appendChild(document.createTextNode(accessoires[random].info.prix + "€"));
        prixSuggestions.classList.add("prix-suggestion");
        suggestion.appendChild(prixSuggestions);

        containerSuggestions.appendChild(suggestion);

        //un div pour bien séparer les menus déroulants
        let div1 = document.createElement("div");
        suggestion.appendChild(div1);

        let div2 = document.createElement("div");
        suggestion.appendChild(div2);

        //menu déroulant pour la couleur
        let selectCouleurSuggestions = document.createElement("select");
        selectCouleurSuggestions.classList.add("select-couleur-suggestion");
        div2.appendChild(selectCouleurSuggestions);
        //on récupère les couleurs disponibles
        let couleurDispoSuggestions = couleurDispo(accessoires, random);
        makeSelect(couleurDispoSuggestions, selectCouleurSuggestions);

        //menu déroulant pour la taille
        let selectTailleSuggestions = document.createElement("select");
        selectTailleSuggestions.classList.add("select-taille-suggestion");
        div1.appendChild(selectTailleSuggestions);


        //on récupère la première couleur disponible
        let couleurSuggestion = couleurDispoSuggestions[0];
        //on récupère les tailles disponibles pour cette couleur
        let tailleDispoSuggestions = tailleDispo(accessoires, random, couleurSuggestion);
        makeSelect(tailleDispoSuggestions, selectTailleSuggestions);

        //quand on choisit une couleur on actualise les tailles disponibles
        selectCouleurSuggestions.addEventListener("change", function() {
          couleurSuggestion = selectCouleurSuggestions.value;
          deleteSelect(selectTailleSuggestions);
          makeSelect(tailleDispo(accessoires, random, couleurSuggestion), selectTailleSuggestions);
        });

        //on récupère le subId du produit suggestion
        let subIdSuggestions = 0;
        selectTailleSuggestions.addEventListener("change", function() {
          subIdSuggestions = accessoires[random].info.stock.findIndex(element => element.couleur == couleurSuggestion && element.taille == selectTailleSuggestions.value);
        });
        

        //bouton pour ajouter l'accessoire
        let boutonSuggestions = document.createElement("input");
        boutonSuggestions.type = "button";
        boutonSuggestions.value = "Ajouter cet accessoire";
        boutonSuggestions.classList.add("bouton-suggestion");
        suggestion.appendChild(boutonSuggestions);

        //pour retenir l'état de la suggestion
        //si elle est ajoutée ou non 
        let boutonState = [];
        let indexBouton = allBoutonsSuggestions.length;
        boutonState.push(boutonSuggestions);
        boutonState.push(false);
        allBoutonsSuggestions.push(boutonState);

        //quand on clique sur le bouton on ajoute l'accessoire
        boutonSuggestions.addEventListener("click", function() { 
          let inputAcc = document.getElementById("idAcc");
          let inputAccSubId = document.getElementById("idAccSubId");

          if(allBoutonsSuggestions[indexBouton][1] == true) {
            for(elem of allBoutonsSuggestions) {
                elem[0].value = "Ajouter cet accessoire";
                elem[1] = false;
            }
            //on réinitialise les valeurs du formulaire caché
            inputAcc.value = "";
            inputAccSubId.value = "";
          } else {
            for(elem of allBoutonsSuggestions) {
              elem[0].value = "Ajouter cet accessoire";
              elem[1] = false;
            }
            boutonSuggestions.value = "Ajouté";
            allBoutonsSuggestions[indexBouton][1] = true;
            //on met cette valeur dans le formulaire caché
            inputAcc.value = accessoires[random].id_produit;
            inputAccSubId.value = subIdSuggestions;
            
          }
          
        });
      }

      

    }
  }

}

//renvoie le tableau accessoire du type correspondant
//on propose des chaussettes quand on a une chaussure par exemple
function accessoireType(produit, types) {
  if(types.types_hauts.includes(produit.info.type) == true && produit.info.type === "chemise") {
    return types.types_accessoires_col;
  } else if (types.types_bas.includes(produit.info.type)) {
    return types.types_accessoires_bas;
  } else if (types.types_chaussures.includes(produit.info.type)) {
    return types.types_accessoires_chaussures;
  } else if (types.types_accessoires_standalone.includes(produit.info.type)) {
    return undefined;
  } else if (types.types_hauts_over.includes(produit.info.type)) {
    return types.types_accessoires_haut;
  } else if (types.types_hauts.includes(produit.info.type)) {
    return types.types_accessoires_haut;
  }
}


/*
* Trouve l'index qui correspond au produit avec une certaine taille et couleur qui servira à se reprérer dans le stock[] du produit
* @param {string} tailleCourante - la taille courante choisie
* @param {string} couleurCourante - la taille courante choisie
* @param {Object} produit - l'object qui correspond au produit 
* */
function findSubId(tailleCourante, couleurCourante, produit) {
  let predicat = element => element.taille === tailleCourante && element.couleur === couleurCourante;
  return produit.info.stock.findIndex(predicat);
}

/*
* met à jour la quantité disponible de produit
* @param {Number} update - l'index qui correspond à la position dans le stock du produit courant de la page
* @param {Object} produit - object du produit courant
* @param {Element} selectQuantite - menu déroulant à actualiser
* @return {Number} la quantite disponible (max 10 par panier)
* */
function updateQuantite (produit, update, selectQuantite) {
      let quantiteDispo = produit.info.stock[update].quantite;
      for(let i = 1; i <= 10; i++) {
        if(i <= quantiteDispo) {
          selectQuantite.children[i - 1].disabled = false;
        } else {
          selectQuantite.children[i - 1].disabled = true;
        }
      }
  return quantiteDispo;
}

/*
* affiche un message en cas de non disponibilite
* @param {Object} info - les informatiosn liées au produit
* */
function addDispo () {
  let bouton = document.getElementById("envoi");
  bouton.disabled = true;
  bouton.value = "Produit Indisponible";
  let quantite = document.getElementById("quantite");
  quantite.disabled = true;
  quantite.value = 0;
}

//enleve le message Indisponible
function removeDispo () {
  let bouton = document.getElementById("envoi");
  bouton.disabled = false;
  bouton.value = "Ajouter au panier";
  let quantite = document.getElementById("quantite");
  quantite.disabled = false;
}

/*
* @param {Number} submitSubId - idex du stock du produit
* @param {Object} produit - informations sur le produit
* @param {String} couleurCourante - couleur choisie
* @patam {String} tailleCourante - taile choisie 
* */
function cascadeUpdate(submitSubId, produit, couleurCourante, tailleCourante) {
    let selectQuantite = document.getElementById("quantite");
    let update = findSubId(tailleCourante, couleurCourante, produit);
    submitSubId.value = update;
    if(update >= 0) {
      let quantiteRestante = updateQuantite(produit, update, selectQuantite);
      removeDispo();
      return quantiteRestante
    }
    addDispo();
    return 0;
}


//trouve les tailles disponibles pour un produit
function tailleDispo(produit, id, couleur)  {
  let taille = [];
  for(let i = 0; i < produit[id].info.stock.length; i++) {
      if(produit[id].info.stock[i].quantite > 0 
          && produit[id].info.stock[i].couleur == couleur 
          && !taille.includes(produit[id].info.stock[i].taille)) {

          taille.push(produit[id].info.stock[i].taille);

      }
  }
  return taille;
}

//trouve les couleurs disponibles pour un produit
function couleurDispo(produit, id) {
  let couleur = [];
  for(let i = 0; i < produit[id].info.stock.length; i++) {
      if(produit[id].info.stock[i].quantite > 0 
          && !couleur.includes(produit[id].info.stock[i].couleur)) {

          couleur.push(produit[id].info.stock[i].couleur);

      }
  }
  return couleur;
}

//supprime les choix d'un select
function deleteSelect(select){
  let child = select.lastElementChild;
  while (child) {
    select.removeChild(child)
    child = select.lastElementChild;
  }
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