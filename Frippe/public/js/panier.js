$(document).ready(function () {
  let prix_total = $("#prix_total");

  // Supprime le produit spécifié par le bouton
  $('.delete-btn').click(function () {
    $(this).closest('tr').remove();
  });

  // Ajouter un événement clic sur le bouton "add"
  $(".add").click(function () {
    // Obtenir la quantité actuelle
    let quantity = parseInt($(this).closest('tr').find('.quantity').text());
    let quantityMax = parseInt($(this).closest('tr').find('.quantiteMax').text());

    // Incrémenter la quantité
    if (quantityMax === -1) {
      quantity++;
      // Mettre à jour la quantité affichée
      $(this).prev().text(quantity);

      // Mettre à jour le prix total
      var price = parseFloat($(this).closest("tr").find(".prix_unite").text());
      var totalPriceProduct = (quantity * price).toFixed(2);
      $(this).closest("tr").find(".prix").text(totalPriceProduct + " €");

      var totalPrice = (parseFloat(prix_total.text()) + price).toFixed(2);
      prix_total.text(totalPrice);
      
    } else if (quantity < quantityMax) {
      quantity++;

      // Mettre à jour la quantité affichée
      $(this).prev().text(quantity);

      // Mettre à jour le prix total
      var price = parseFloat($(this).closest("tr").find(".prix_unite").text());
      var totalPriceProduct = (quantity * price).toFixed(2);
      $(this).closest("tr").find(".prix").text(totalPriceProduct + " €");

      var totalPrice = (parseFloat(prix_total.text()) + price).toFixed(2);
      prix_total.text(totalPrice);
    }
  });

  // Ajouter un événement clic sur le bouton "decrease"
  $(".decrease").click(function () {
    // Obtenir la quantité actuelle
    let quantity = $(this).closest('tr').find('.quantity').text();

    // Décrémenter la quantité si elle est supérieure à 1
    if (quantity > 1) {
      quantity--;

      // Mettre à jour la quantité affichée
      $(this).next().text(quantity);

      // Mettre à jour le prix total
      var price = parseFloat($(this).closest("tr").find(".prix_unite").text());
      var totalPriceProduct = (quantity * price).toFixed(2);
      $(this).closest("tr").find(".prix").text(totalPriceProduct + " €");

      var totalPrice = (parseFloat(prix_total.text()) - price).toFixed(2);
      prix_total.text(totalPrice);
    }
  });

  function ValidateEmail(mail) {
    // vérifie le format de l'email
    var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(mail);
  }

  function isuser() {
    return new Promise((resolve, reject) => {
      let mail = $("#mail").val();
      $.post("http://localhost:8081/action/users", {}, function(data) {
        for(let i=0; i<data.length; i++) {
          if (data[i] === mail) {
            resolve(true);
            return;
          }
        }
        resolve(false);
      });
    });
  }

  // Vérifie que tous les données dans le formulaire sont tous remplis
  // et qu'ils sont valides
  function incomplete() {
    let bloque = false;
    let email = $("#mail");
    email.prev().text("Email");
    
    // Vérification que tous les données ont bien un contenu
    info.each(function () {
      if (!$(this).val()) {
        bloque = true;
        $(this).prev().css({ "color": "red" });
      }
      else {
        $(this).prev().css({ "color": "black" });
      }
    });
    // Vérification de la longuer du numéro de téléphone
    if ($("#num_tel").val().length != 10 ||
      isNaN($("#num_tel").val())
    ) {
      bloque = true;
      $("#num_tel").prev().css({ "color": "red" });
    }
    // Vérification de la validité de l'email entré
    if(!ValidateEmail(email.val())) {
      email.prev().css({"color": "red"});
      bloque = true;
    }
    // Mise a jour du bouton confirm par rapport à la validité de nos input
    if (bloque) {
      $("#confirm").attr('disabled', true);
    }
    else {
      $("#confirm").removeAttr('disabled');
    }
  }
  let info = $(".req");
  info.keyup(incomplete);

  $("#confirm").click(async function () {
    if(!$("#mail").prop("disabled")) {
      let userExists = await isuser();
      if(userExists) {
        let mail = $("#mail");
        mail.prev().css({"color": "red"});
        mail.prev().text("Email : cet email est déjà utilisé");
        return;
      }
    }

    // Récupérer le panier
    let panier = [];

    $('.article').each(function () {
      let article = {};

      // Récupérer l'ID de l'article
      let id_article = parseInt($(this).find('.product-info .id_article').text());

      // Récupérer les ID des produits inclus dans l'article
      let id_produit = [];
      $(this).find('.product-info .id_produit').each(function () {
        let id_prod = parseInt($(this).text());
        id_produit.push(id_prod);
      });

      // Récupérer les indices des produits inclus dans l'article
      let indiceStock = [];
      $(this).find('.product-info .produit').each(function() {
        let indice = $(this).data('indicestock');
        indiceStock.push(indice);
      })
      
      // Récupérer la quantité commandée
      let quantite = parseInt($(this).find('.quantity').html());

      // Ajouter les informations de l'article à l'objet
      article.indiceStock = indiceStock;
      article.id_article = id_article;
      article.id_produit = id_produit;
      article.quantite = quantite;

      // Ajouter l'article à la liste des articles du panier
      panier.push(article);
    })

    let p = JSON.stringify(panier);

    // Récupérer les valeurs du formulaires
    let nomInput = $("#nom").val();
    let prenomInput = $("#prenom").val();
    let adresseInput = $("#adresse").val();
    let num_telInput = $("#num_tel").val();
    let livraisonInput = $("#livraison").val();
    let mailInput = $("#mail").val();
    let form = $("#formPanier")[0];
    if (form) {
      form.reset();
    }
    
    $.post("http://localhost:8081/panier", 
        {
          nom: nomInput, prenom: prenomInput, adresse: adresseInput,
          num_tel: num_telInput, livraison: livraisonInput, mail: mailInput,
          panier: JSON.stringify(panier)
        },
        function(data) {
           window.location.reload();
        }
    );
    setTimeout(function() {
      window.location.reload();
    }, 100);
  })
})
