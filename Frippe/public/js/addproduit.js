//selon le tableau types
function makeSelect(type, select) {
    for(let i = 0; i < type.length;  i++) {
        console.log(type[i]);
      let option = document.createElement("option");
      option.appendChild(document.createTextNode(type[i]));
      select.appendChild(option);
    }
}

//génère les menus déroulant du formulaire
function setform(types) {
    console.log(types);

    let selectMatiere = document.getElementById("matiere");
    makeSelect(types.matiere, selectMatiere);

    let selectType = document.getElementById("type");
    //alltypes représente tous les types possibles
    let allType = types.types_hauts.concat(types.types_bas);
    allType = allType.concat(types.types_chaussures);
    allType = allType.concat(types.types_hauts_over);
    allType = allType.concat(types.types_accessoires_haut);
    allType = allType.concat(types.types_accessoires_bas);
    allType = allType.concat(types.types_accessoires_col);
    allType = allType.concat(types.types_accessoires_chaussures);
    console.log(allType);
    makeSelect(allType, selectType);

    let selectSexe = document.getElementById("sexe");
    makeSelect(types.sexe, selectSexe);

}

//fonction pour le bouton d'envoi
function send() {
    let description = document.getElementById("description");
    let prix = document.getElementById("prix");
    let selectMatiere = document.getElementById("matiere");
    let selectType = document.getElementById("type");

    if(description.value.length > 0 && prix.value > 0) {
        let form = document.getElementById("form");
        form.submit();
    }
}