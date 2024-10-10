//assurer que toutes les boites de produits
//sont de la même taille
function descriptionCourte(description) {
  let res = description;
  if(description.length > 20) {
    res = description.substring(0, 17) + "...";
  }
  return res;
}

function affichageCombi(produit, combi) {
  //affichageCombi utilise la même base que les produits
  //les valeurs sont initialisé plus tard car on doit itérer 
  //sur toutes les valeurs de la combinaison pour faire l'affichage complet

  for(let i = 0; i < combi.length; i++) {
    let res = produit.filter(
      element => element.id_produit
      === combi[i].info[0][0]
    )
    let result = affichageProduit(res, true);
    //result contient les références des balises précédemment générées
    //par affichage produit

    let prixTotal = 0;
    let allPhoto = [];
  
    //on récupère les photos
    //on additionne le prix de tous les produits de la combinaison
    for(let j = 0; j < combi[i].info.length; j++) {
        
        //info -> tableau de couple (ID, index stock)
        let id = combi[i].info[j][0];
        let subId = combi[i].info[j][1];
        prixTotal += produit[id - 1].info.prix;
        allPhoto.push(produit[id - 1].info.stock[subId].img);
    }
  
    let prix = result[0];
    //on affiche le prix 
    prix.appendChild(document.createTextNode(prixTotal + "€"));
  
    let description = result[1]
    let descriptionText = descriptionCourte(combi[i].description);
    description.appendChild(document.createTextNode(descriptionText));

    let link = result[2]; 
    link.href = "/combinaison?id=" + combi[i].num_combinaison;

    let button = result[3];
    let photo = result[4];
    let idCycle = 0;

    button.addEventListener("click", function() {
      idCycle++;
      if(idCycle === allPhoto.length) {
          idCycle = 0;
      }
      photo.src = allPhoto[idCycle];
    });

  }
}

function affichageProduit(tab, isCombinaison) {
  const container  = document.getElementById("container-produit");
  let prix;
  let description;
  let link;
  let button;
  let photo;

  //on itère sur les produits pour produire chaque affichage
  for(elem of tab) {
    if(elem.info.stock.length > 0) {
      let prodContainer = document.createElement("div");
      prodContainer.classList.add("produit");
      container.appendChild(prodContainer);

      //conteneur de la photo
      let photoContainer = document.createElement("div");
      photoContainer.classList.add("photo-produit");
      prodContainer.appendChild(photoContainer);

      //afffichage de la photo
      photo = document.createElement("img");
      photo.alt = "/Produits/default.png";
      photo.classList.add("photo-produit");
      photo.src = elem.info.stock[0].img;
      photoContainer.appendChild(photo);

      //conteneur d'information
      let infoProduit = document.createElement("div");
      infoProduit.classList.add("info-produit");
      prodContainer.appendChild(infoProduit);

      //on met un bouton pour cycler sur les photos
      //si on a une combinaison 
      //car on a plusieurs produits
      if(isCombinaison == true) {
        button = document.createElement("input");
        button.setAttribute("id", "button-cycle");
        button.type = "button";
        button.value = "Photo Suivante";
        infoProduit.appendChild(button);
      }

      //affichage prix
      prix = document.createElement("div");
      prix.setAttribute("id","prix");
      if(isCombinaison == false) {
        prix.appendChild(document.createTextNode(elem.info.prix + "€"));
      }
      infoProduit.appendChild(prix);

      description = document.createElement("div");
      description.setAttribute("id", "description");

      //la description sera intialisé plus tard
      //si on veur afficher une combinaison
      if(isCombinaison == false) {
        let descriptionText = descriptionCourte(elem.info.description);
        description.appendChild(document.createTextNode(descriptionText));
      }
      infoProduit.appendChild(description);


      //le lien vers le produit
      link = document.createElement("a");
      link.appendChild(document.createTextNode("Voir plus"));
      if(isCombinaison == false) {
        link.href = "produit?id=" + elem.id_produit;
      }
      infoProduit.appendChild(link);
    }

  }

  //le res permet d'adapter un affichage de produit
  //en affichage de combinaisons
  //car les deux possèdent la même base
  let res = [];
  res.push(prix);
  res.push(description);
  res.push(link);
  res.push(button);
  res.push(photo);
  return res;

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

//afficher ou non les boutons pour ajouter 
//une combinaison ou un produit
function gerantbouton(gerantboolean) {
  if(gerantboolean == false) {
    let linkcombi = document.getElementById("linkcombi");
    let linkprod = document.getElementById("linkprod");

    linkcombi.style.visibility = "hidden";
    linkprod.style.visibility = "hidden";
  } 
}

//on rempli les menu déroulants par les choix possibles
//dans typeVetement.js, qui dicte les types disponibles
function filtrage(types) {
  
  let categorie = document.getElementById("categorie");
  makeSelect(types.categorie, categorie);
  categorie.value = "";

  let sexe = document.getElementById("sexe");
  makeSelect(types.sexe, sexe);
  sexe.value = "";

  let couleur = document.getElementById("couleur");
  makeSelect(types.couleur, couleur)
  couleur.value = "";

  let taille = document.getElementById("taille");
  makeSelect(types.tailles, taille);
  taille.value = "";

  let matiere = document.getElementById("matiere");
  makeSelect(types.matiere, matiere);
  matiere.value = "";

}

//permet d'envoyer les filtres à la page d'accueil
//avec la methode get
function filtrer() {
  let form = document.getElementById("form");
  form.submit();
}



