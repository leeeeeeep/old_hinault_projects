function Types() {
  this.sexe = ["H", "F", "U"];
  this.categorie = ["haut_couvrant", "haut", "bas", "accessoire", "chaussure"];
  //couleurs acceptés
  this.couleur = ["blue", "navy", "green", "lime", "red", "violet", "pink", "yellow", "black", "beige", "brown", "grey", "orange", "multicolor", "undefined"];
  this.types_hauts = ["t-shirt", "chemise", "pull", "débardeur"];
  //types de hauts qui peuvent se mettre au dessus des hauts
  this.types_hauts_over = ["manteau", "veste", "cardigan", "coupe-vent"];
  this.types_bas = ["jean", "chino", "short_c", "short", "jupe_c", "jupe", "jogging"];
  this.types_chaussures = ["basket", "botte", "mocassin", "talon", "sandales", "pantoufles"];
  this.types_accessoires_haut = ["echarpe"];
  this.types_accessoires_col = ["noeud_papillon", "cravatte"]
  this.types_accessoires_bas = ["ceinture", "bretelles"];
  this.types_accessoires_chaussures = ["chaussette_longue", "chaussette_courte", "socquette"];
  //accessoires qui ne dépendent pas d'un habit
  this.types_accessoires_standalone = ["casquette", "chapeau", "lunette", "gant", "bijou"];
  this.tailles = ["XS", "S", "M", "L", "XL"];
  this.matiere = ["cotton", "cuir", "lin", "soie", "polyester", "denim"];
  this.style = ["Roi des clochards", "Clochard de moyenne classe", "Pauvre clochard"];
}
module.exports = new Types();
