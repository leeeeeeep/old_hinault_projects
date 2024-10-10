/**
* @param {Number} id - identifiant du produit dans la BD, -1 si on a un nouveau produit qu'on introduira dans la BD
* @param {Number} prix - prix du produit
* @param {String} sexe - F, M ou U, sexe du produit
* @param {String} taille - XS, S, M, L, XL ou Universel, la taille du produit
* @param {String} matiere - matiere du produit
* @param {String} img - path de l'image du produit
* @param {String} type - Haut, Bas, Chaussure...etc categorie du produit
* @param {String} Description - description du produit
*/
function Vetement() {
  this.prix = -1;
  this.sexe = "";
  this.matiere = "";
  this.type = ""; 
  this.description = "";
  this.stock = [];
}

Vetement.prototype = {
  constructor : Vetement,
  setVetement : function (prix, sexe, matiere, type, description) {
    this.prix = prix;
    this.sexe = sexe; 
    this.matiere = matiere;
    this.type = type; 
    this.description = description; 
  },
  addStock : function (size, color, stock, img) {
    let s = new Stock();
    s.setStock(size, color, stock, img);
    this.stock.push(s);
  }
}

function Stock() {
  this.taille = "";
  this.couleur = "";
  this.quantite = 0;
  this.img = "";
}

Stock.prototype = {
  constructor : Stock,
  setStock : function (taille, color, quantity, img) {
    this.taille = taille;
    this.quantite = quantity;
    this.couleur = color;
    this.img = img;
  }
}

module.exports = new Vetement();
