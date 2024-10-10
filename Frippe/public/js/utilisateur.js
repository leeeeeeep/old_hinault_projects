$(document).ready(function () {
    let save = $(".save");
    let edit = $(".edit");
    let del = $(".delete");
    let ajout = $("#ajout_adr");
    let mdp = $("#modif_mdp");
    save.hide();

    let email = $("#email").val();
    let nom;
    let prenom;
    let adresse;
    
    $(".checkdefault").prop('checked', false);
    $(".checkdefault").prop('disabled', true);

    save.click(function() {
        $(this).hide();
        edit.removeAttr('disabled');
        let parent = $(this).parent();
        parent.css("border-color", "black");
        let index = $('.save').index(this);
        let nom_input = parent.find(".nom input").val();
        let prenom_input = parent.find(".prenom input").val();
        let adresse_input = parent.find(".adresse input").val();
        let checkdefault = parent.find(".checkdefault").prop("checked")
        if(!nom_input || !prenom_input || !adresse_input) {
            let tmp = "Nom : " + nom;
            parent.children(".nom").html(tmp);
            tmp = "Prenom : " + prenom;
            parent.children(".prenom").html(tmp);
            tmp = "Adresse : " + adresse;
            parent.children(".adresse").html(tmp);
        } else {
            maj_adresse(email, nom_input, prenom_input, adresse_input, checkdefault, index);
        }
        ajout.removeAttr('disabled');
    })

    edit.click(function () {
        edit.attr('disabled', true);
        ajout.attr('disabled', true);
        let parent = $(this).parent();
        parent.css("border-color", "red");
        parent.children(".save").show();

        nom = parent.children(".nom").text().replace("Nom : ", "");
        let tmp = "<label for='nom'>Nom : </label>" +
                "<input type='text' name='nom' id='nom' value='"+ nom +"'><br>";
        parent.children(".nom").html(tmp);
        prenom = parent.children(".prenom").text().replace("Prenom : ", "");
        tmp = "<label for='prenom'>Prenom : </label>" +
            "<input type='text' name='prenom' id='prenom' value='"+ prenom +"'><br>";
        parent.children(".prenom").html(tmp);
        adresse = parent.children(".adresse").text().replace("Adresse : ", "");
        tmp = "<label for='adresse'>Adresse : </label>" +
                "<input type='text' name='adresse' id='adresse' value='"+adresse+"'><br>";
        parent.children(".adresse").html(tmp);
        parent.children(".checkdefault").removeAttr('disabled');
    })

    ajout.click(function() {
        $(this).attr('disabled', true);
        $("#register").slideDown();
        edit.attr('disabled', true);
    })

    $(".cancel").click(function() {
        $("#register").slideUp();
        ajout.removeAttr('disabled');
        edit.removeAttr('disabled');
        $("input[name=nom]").val("");
        $("input[name=prenom]").val("");
        $("input[name=adresse]").val("");
    })

    $(".save_register").click(function() {
        let parent = $("#register");
        let nom_input = parent.find("#nom").val();
        let prenom_input = parent.find("#prenom").val();
        let adresse_input = parent.find("#adresse").val();
        $("#register").slideUp();
        ajout.removeAttr('disabled');
        edit.removeAttr('disabled');
        $("input[name=nom]").val("");
        $("input[name=prenom]").val("");
        $("input[name=adresse]").val("");
        if(!nom_input || !prenom_input || !adresse_input) {
            console.log("Invalid donc non rajouter");
        } else {
            maj_adresse(email, nom_input, prenom_input, adresse_input, false, -1);
        }
    })

    del.click(function() {
        let index = $('.delete').index(this);
        $(this).parent().remove();
        $.post("http://localhost:8081/deleteAdr", 
            {email: email, index: index},
            function(data) {
                window.location.reload();
            }
        );
        setTimeout(function() {
            window.location.reload();
        }, 100);
    })

    function maj_adresse(mail, nom, prenom, adresse, modif_adr, index) {
        $.post("http://localhost:8081/updateAdr", 
            {
                email: mail, nom: nom, prenom: prenom,
                adresse: adresse, modifadr: modif_adr, index: index},
            function(data) {
                window.location.reload();
            }
        );
        setTimeout(function() {
            window.location.reload();
        }, 100);
    }
    
    $("#notif_modif").hide();
    mdp.click(function() {
        $("#notif_modif").hide();
        $(this).attr('disabled', true);
        $("#modif_pwd").slideDown();
        edit.attr('disabled', true);
        ajout.attr('disabled', true);
    })

    $(".save_modif_mdp").click(function() {
        $("#modif_pwd").slideUp();
        ajout.removeAttr('disabled');
        edit.removeAttr('disabled');
        mdp.removeAttr('disabled');

        let actuel = $("input[name=actuel_mdp]").val();
        let nouveau  = $("input[name=nv_mdp]").val();
        $("input[name=actuel_mdp]").val("");
        $("input[name=nv_mdp]").val("");

        $.post("http://localhost:8081/action/modifmdp", 
            {
                actuel_mdp: actuel,
                nv_mdp: nouveau
            },
            function(data) {
                console.log(data);
                if(data) {
                    $("#notif_modif").css({"color": "green"});
                    $("#notif_modif").text("Modification effectué");
                } else {
                    $("#notif_modif").css({"color": "red"});
                    $("#notif_modif").text("Mot de passe incorrect donc inchangé");
                }
                $("#notif_modif").show();
            }
        );
    })
})