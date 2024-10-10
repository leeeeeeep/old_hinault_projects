const express = require("express");
const session = require('express-session');
const jwt = require('jsonwebtoken');

const server = new express();
server.use(express.json());
server.use(express.urlencoded({extended:true}));
server.use(express.static(__dirname + '/public'));
server.set('view engine','ejs');

server.use(session({
    secret: 'thisismysecretkey',
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 1000 * 60 * 60 * 24 }
}));

//le secret pour lire ensuire les token des sessions
const JWT_SECRET = "fldskjfslkhidsjkljshDFDGGdflskjdlertgjiYGuihbYFcHUJIBguFYiuTGtyrvuTFcYUGbIUGcfvRDYguvUYRFcYERTDESZqzsGVbJ?IJzZrTuIRZSEfGjjDFZETjIJGrRZzrtyuiopoHDSSQCbFrTGGbtgl!dflskjdlfqQDFGDE";

let bd = require("./bd.js");
const { type } = require("os");
const { access } = require("fs");
let actiongerant = false;
//on donne les types de vêtement pour le filtrage 
let types = require('./public/js/typeVetement.js');
types = JSON.stringify(types);

// vérifie si la session appartient à un utilisateur de type typeUser
function verifyTypeUser(req, typeUser) {
    if (req.session.token) {
        let user = jwt.verify(req.session.token, JWT_SECRET);
        if(user.type === typeUser) {
            return true;
        }
    }
    return false;
}

typeUser = {
    admin: "admin",
    user: "user",
}

// Fusionne les doublons qui sont dans le tableau d'articles
function combinerArticleDoublons(articles) {
    var result = [];

    articles.forEach(function(article) {
        var articleCombine = false;
        for(let i = 0; i < result.length; i++) {
            if (
                result[i].id_article === article.id_article &&
                result[i].produit.length === article.produit.length
            ) {
                var articleEqual = false;
                for (let j = 0; j < article.produit.length; j++) {
                    if (
                        article.id_produit[j] === result[i].id_produit[j] &&
                        article.indiceStock[j] === result[i].indiceStock[j]
                    ) {
                        articleEqual = true;
                        break;
                    }
                }
                if (articleEqual) {
                    // même article
                    result[i].quantiteMax = Math.min(result[i].quantiteMax,article.quantiteMax);
                    result[i].quantite += article.quantite;
                    articleCombine = true;
                    break;
                }
            }
        }
        if (!articleCombine) {
            // autre article
            result.push(article);
        }
    });

    return result;
}

// Renvoie un tableau qui ne contient que des produits
// avec le format d'un panier en
/* { id_article, indiceStock, id_produit, quantite }*/
function convertAllPaniertoProd(panier) {
    let tab = [];
    for(let i = 0; i < panier.length; i++) {
        if (panier[i].id_produit.length !== 1) {
            // cas où on a une combinaison
            for(let j = 0; j < panier[i].id_produit.length; j++) {
                tab.push({
                    id_article: panier[i].id_produit[j],
                    id_produit: panier[i].id_produit[j],
                    indiceStock: panier[i].indiceStock[j],
                    quantite: panier[i].quantite
                })
            }
        } else {
            // cas où on a un produit
            tab.push({
                id_article: panier[i].id_produit[0],
                id_produit: panier[i].id_produit[0],
                indiceStock: panier[i].indiceStock[0],
                quantite: panier[i].quantite
            })
        }
    }
    return tab;
}

async function run() {
    await bd.connect();

    server.get("/", async (req,res) => { 
        let produits = await bd.getProd();
        produits = produits.rows
        
        let filtres = req.query;
        console.log(filtres.combinaison == 'true');

        //toutes les combinaisons
        let combinaison = await bd.getAllCombi();
        let affiche_combi = false;

        //dans le cas où on nous demande d'afficher les combinaisons
        if(filtres.combinaison != null && filtres.combinaison === 'true') {
            affiche_combi = true;
        } else {
            const pred = require('./public/js/filtreAccueil.js');
            produits = pred.predicat(produits, filtres, JSON.parse(types));                
        }

        //on envoit en format JSON
        produits = JSON.stringify((produits));
        if(combinaison != undefined) {
            combinaison = JSON.stringify(combinaison.rows);
        }

        //on verifie si la personne qui demande la page est un gérant
        //pour afficher des boutons spécifique au gérant
        let gerant = verifyTypeUser(req, typeUser.admin);

        res.render("accueil", {produits, types, combinaison, affiche_combi, gerant});
    });

    server.route('/inscription')
        // page d'inscription
        .get((req, res) => {
            actiongerant = false;
            if(verifyTypeUser(req, typeUser.admin) &&
               verifyTypeUser(req, typeUser.user)) {
                res.redirect("/");
                return;
            }
            res.render("inscription", {
                message: '',
                email: '',
                mdp: ''
            });
        })
        // vérifie les informations que l'utilisateur a entré et 
        // le redirige vers la page de connexion si tout est valide
        .post(async (req,res) => {
            let body = req.body;
            if (body.email != undefined && body.mdp != undefined) {
                if (!await bd.isuser(body.email, body.mdp)) {
                    await bd.inscription(body.email, body.mdp);
                    let user = await bd.getUserId(body.email);
                    bd.makePanier(user);
                    res.redirect("connexion");
                } else {
                    res.render("inscription", {
                        message: 'Email déjà existant. Recommence.',
                        email: body.email,
                        mdp: body.mdp
                    });
                }
            } else {
                res.status(404).send("PROBLEME");
            }
        });

    server.route('/connexion')
        // page de connexion
        .get((req, res) => {
            actiongerant = false;
            if(verifyTypeUser(req, typeUser.admin) &&
               verifyTypeUser(req, typeUser.user)) {
                res.redirect("/");
                return;
            }
            res.render('connexion', {
                message: '',
                email: '',
                mdp: '',
                gerant: actiongerant
            });
        })
        // vérifie les informations que l'utilisateur a entré et le redirige vers la page d'accueil si les informations sont valides
        .post(async (req, res) => {
            let body = req.body;
            if (!await bd.isuser(body.email, body.mdp) || 
                (actiongerant && !await bd.isadmin(body.email)) ||
                (!actiongerant && await bd.isadmin(body.email))
            ) {
                res.render("connexion", {
                    message: 'Identifiant ou mot de passe invalide',
                    email: body.email,
                    mdp: body.mdp,
                    gerant: actiongerant
                });
            } else {
                let id = await bd.getUserId(body.email);
                let typeco;
                if(actiongerant) {
                    typeco = "admin";
                } else {
                    typeco = "user";
                }
                let panierco = await bd.getIdDernierPanier(id);
                req.session.token = jwt.sign({type : typeco, id_user : id, idPanier : panierco, email : body.email}, JWT_SECRET);
                res.redirect("/");
            }
        });

    server.get("/utilisateur", async (req, res) => {
        // page de l'utilisateur
        if(req.session.token) {
            let token = jwt.verify(req.session.token, JWT_SECRET);
            if(req.body.name == undefined) {
                let a = await bd.getAdr(token.email);
                res.render("utilisateur", {
                    name: token.email,
                    adresse: a.adresse,
                    indexadrdefault: a.indexadrdefault
                })
            } else if(token.email != req.body.name && 
                      !await bd.isadmin(token.email)) {
                res.redirect("utilisateur");
            } else {
                let a = await bd.getAdr(req.body.name);
                res.render("utilisateur", {
                    name: req.body.name,
                    adresse: a.adresse,
                    indexadrdefault: a.indexadrdefault
                })
            }
        } else {
            res.render("connexion", {
                message: "Connectez vous avant",
                email: '',
                mdp: '',
                gerant: actiongerant
            });
        }
    })

    server.route('/panier')
        // page du panier avec les articles 
        // qu'on a récupéré du panier de l'utilisateur
        .get(async (req, res) => {
            let panier_final = [];
            let nomfinal = "";
            let prenomfinal = "";
            let adressefinal = "";
            let mailfinal = "";

            if (req.session.token) {
                let token = jwt.verify(req.session.token, JWT_SECRET);
                mailfinal = token.email;
                let bd_panier = await bd.getPanier(mailfinal);
                panier_final = combinerArticleDoublons(bd_panier);
                if (!actiongerant) {
                    let adrdefault  = await bd.getAdrDefault(mailfinal);
                    if (adrdefault != {} && adrdefault != undefined) {
                        nomfinal = adrdefault.nom;
                        prenomfinal = adrdefault.prenom;
                        adressefinal = adrdefault.adresse;
                    }
                }
            }

            res.render("panier", {
                tab: panier_final,
                nom: nomfinal,
                prenom: prenomfinal,
                adresse: adressefinal,
                mail: mailfinal,
                gerant: actiongerant
            });
        })
        // Met a jour le panier qui a été confirmé
        .post(async (req, res) => {
            let body = req.body;
            if (body.panier == undefined) {
                res.status(404).send("PROBLEME");
                return;
            }
            if (actiongerant) {
                let p = JSON.parse(body.panier);
                let panier_final = convertAllPaniertoProd(p);
                await bd.addStock(panier_final);
                // Mise à jour du panier
                let token = jwt.verify(req.session.token, JWT_SECRET);
                let id = await bd.getUserId(token.email);
                await bd.resetPanier(id);
                await bd.insertArtInPanier(id, body.livraison, p);
                await bd.makePanier(id);
                return;
            } else {
                if (
                    body.mail == undefined ||
                    body.nom == undefined ||
                    body.prenom == undefined ||
                    body.adresse == undefined ||
                    body.num_tel == undefined ||
                    body.livraison == undefined
                ) {
                    res.status(404).send("PROBLEME");
                } else {
                    let p = JSON.parse(body.panier);
                    // Création / Mise à jour de l'utilisateur
                    await bd.updateUser(body.mail, body.nom, body.prenom, body.adresse, body.num_tel);
        
                    let id_utilisateur = await bd.getUserId(body.mail);
                    // Mise à jour du panier
                    await bd.resetPanier(id_utilisateur);
                    await bd.insertArtInPanier(id_utilisateur, body.livraison, p);

                    // Mise à jour des stock des produits
                    p = convertAllPaniertoProd(p);
                    await bd.removeStock(p);
                    await bd.makePanier(id_utilisateur);
                }
            }
        })

    server.get("/produit", async (req, res) => {
      let id = req.query.id;
      let subId = req.query.subId;
      if(id == undefined || isNaN(Number(id)) == true || (subId != undefined && isNaN(Number(subId)) == true )) {
        res.status(404).send("Pas de produit choisi");
      }

      if(subId == undefined) {
        subId = 0;
      }

      let gerant = verifyTypeUser(req, typeUser.admin);
      
      let produit = await bd.getThisProd(id);
      if(produit.rows.length === 0) {
        res.status(404).send("Produit non existant");
      }
      produit = JSON.stringify(produit.rows[0]);

      let allProd = await bd.getProd();
        allProd = JSON.stringify(allProd.rows);
       
      res.render("page-produit", {produit, id, subId, gerant, types, allProd});
    })

    // page d'une combinaison
    server.get("/combinaison", async (req, res) => {
        let id = req.query.id;
        if(id == undefined || isNaN(Number(id)) == true) {
            res.status(404).send("Pas de produit choisi");
        }
        let combinaison = await bd.getCombi(id);
        if(combinaison.rows.length === 0) {
            res.status(404).send("Produit non existant");
        }

        let produit = await bd.getProd();

        produit = JSON.stringify(produit.rows);
        combinaison = JSON.stringify(combinaison.rows[0]);

        res.render("combinaison", {combinaison, produit});
    })

    // page de modification d'un produit
    server.get("/updateProduit", async (req, res) => { 
        //seul un gérant peut accéder à cette page
        if(verifyTypeUser(req, typeUser.admin) == false) {
            res.redirect("/");
        }

        let id = req.query.id;
        if(id == undefined || isNaN(Number(id)) == true) {
            res.status(404).send("Pas de produit choisi");
        }
        let produit = await bd.getThisProd(id);
        if(produit.rows.length === 0) {
            res.status(404).send("Produit non existant");
        }
        produit = JSON.stringify(produit.rows[0]);

        allPhoto = await bd.getPhoto();
        allPhoto = JSON.stringify(allPhoto.rows);
        
        res.render("updateProduit", {produit, types, id, allPhoto});
        
    })

    // Modification d'un produit
    server.post("/modifProduitBd", async (req, res) => {
        //seul un gérant peut accéder à cette page
        if(verifyTypeUser(req, typeUser.admin) == false) {
            res.redirect("/");
            return;
        }

        //conversion en nombre
        let id = Number(req.body.idProduit);
        await bd.updateProduit(req.body.prod, id);
        res.redirect("/");
    })

    // page d'ajout d'une combinaison (accessible seulement par le gérant)
    server.get("/addcombinaison", async (req, res) => {
        //seul un gérant peut accéder à cette page
        if(verifyTypeUser(req, typeUser.admin) == false) {
            res.redirect("/");
            return;
        }

        let produits = await bd.getProd();
            
                produits = JSON.stringify(produits.rows);
                
                res.render("addcombinaison", {produits, types});
    })

    // utilisé lorsqu'on ajoute un produit dans le panier stocké dans la bd
    server.post("/updatePanier", async (req,res) => {
        if(req.session.token) {
            let token = jwt.verify(req.session.token, JWT_SECRET);
            let id_utilisateur = await bd.getUserId(token.email);
            let result = req.body;
            console.log(result);
            if (result.subId != undefined) {
                console.log(id_utilisateur);
                console.log(result.id_produit);
                console.log(result.subId);
                console.log(result.quantite);
                console.log("aaaaa");
                await bd.insertArtInPanierNonConfirm(
                    id_utilisateur,
                    result.id_produit,
                    result.subId,
                    result.quantite
                );
            } else {
                await bd.insertArtInPanierNonConfirm(
                    id_utilisateur,
                    JSON.parse(result.combi),
                    undefined,
                    result.quantite
                );
            }
            if(req.body.idAcc != '' && req.body.idAccSubId != '') {
                console.log(req.body);
                console.log(id_utilisateur);
                console.log(result.idAcc);
                console.log(result.idAccSubId);
                console.log(result.quantite);
                console.log("aaaaa");
                await bd.insertArtInPanierNonConfirm(
                    id_utilisateur,
                    result.idAcc,
                    result.idAccSubId,
                    1
                );
            }
            res.redirect("/");
        } else {
            res.redirect("connexion");
        }
    })

    // détruit la session s'il y en a un
    server.get("/deconnexion", async (req, res) => {
        if(req.session.token) {
            req.session.destroy(() => {
            })
        }
        res.redirect("/");
    })

    // Crée une combinaison et l'ajoute dans la table Combinaison
    server.post("/addCombiToBd", async (req, res) => {
        //seul un gérant peut accéder à cette page
        if(verifyTypeUser(req, typeUser.admin) == false) {
            res.redirect("/");
            return;
        }
        let token = jwt.verify(req.session.token, JWT_SECRET);

        if(
            req.body.combi === undefined ||
            req.body.description === undefined ||
            req.body.prix === undefined ||
            ! await bd.isadmin(token.email)
        ) {
            res.status(404).send("PROBLEME");
        } else {
            await bd.addCombi(
                req.body.combi, 
                req.body.description, 
                req.body.prix
            );
        }
        res.redirect("/");
    })

    // page d'ajout de produit (accessible seulement par le gérant)
    server.get("/addproduit", async (req, res) => {

        //seul un gérant peut accéder à cette page
        if(verifyTypeUser(req, typeUser.admin) == false) {
            res.redirect("/");
            return;
        }

        res.render("addproduit", {types});
    })

    server.get("/getProd", async (req,res) => {
        res.json(await bd.getProd());
    })

    server.post("/addProdToBd", async (req, res) => {

        //seul un gérant peut accéder à cette page
        if(verifyTypeUser(req, typeUser.admin) == false) {
            res.redirect("/");
            return;
        }
        
        let result = req.body;
        let vet = require("./public/js/vetements.js");
        vet.setVetement(result.prix, result.sexe, result.matiere,
            result.type, result.description);
        //on insère le produit dans la bd
        await bd.insertProd(vet);
        let prodCourant = await bd.getProd();
        prodCourant = prodCourant.rows;
        let index = prodCourant.length -1;
        res.redirect("/updateProduit?id="+index);
    })

    // utiliser pour mettre a jour l'adresse de l'utilisateur
    server.post("/updateAdr", async (req, res) => {
        let token = jwt.verify(req.session.token, JWT_SECRET);
        if (req.body.email != undefined &&
            req.body.nom != undefined &&
            req.body.prenom != undefined &&
            req.body.adresse != undefined &&
            req.body.index != undefined &&
            req.body.modifadr != undefined &&
            token.email === req.body.email
        ) {
            if (JSON.parse(req.body.modifadr) === true) {
                await bd.setAdrDefault(req.body.email, parseInt(req.body.index));
            }
            await bd.updateAdr(req.body.email, req.body.nom, req.body.prenom, 
                req.body.adresse, parseInt(req.body.index));
        } else {
            res.status(404).send("PROBLEME");
        }
    })

    // supprime un adresse de l'utilisateur
    server.post("/deleteAdr", async (req, res) => {
        let token = jwt.verify(req.session.token, JWT_SECRET);
        if (req.body.email != undefined &&
            req.body.index != undefined &&
            token.email === req.body.email
        ) {
            await bd.deleteAdr(req.body.email, parseInt(req.body.index));
            let adr = await bd.getAdr(req.body.email);
            if(adr.indexadrdefault === parseInt(req.body.index)) {
                await bd.setAdrDefault(req.body.email, parseInt(req.body.index)-1);
            }
        } else {
            res.status(404).send("PROBLEME");
        }
    })

    // récupère tous les utilisateurs présents dans la table Utilisateurs
    server.post("/action/users", async (req, res) => {
        res.json(await bd.getUsersEmail());
    })

    // modifie le mot de passe de l'utilisateur qui le demande
    server.post("/action/modifmdp", async (req, res) => {
        let body = req.body;
        if (
            body.nv_mdp == undefined || 
            body.actuel_mdp == undefined
        ) {
            res.send(false);
        }
        let token = jwt.verify(req.session.token, JWT_SECRET);
        if (token.email) {
            if(await bd.isuser(token.email, body.actuel_mdp)) {
                // modifier le mot de passe
                await bd.modifMdp(token.email, body.nv_mdp);
                console.log("Mot de passe modifié");
                res.send(true);
                return;
            }
        }
        console.log("Mot de passe inchangé");
        res.send(false);
    })

    // utiliser pour la barre de recherche
    server.get("/action/search", async (req, res) => {
        let query = req.query;
        if (query.word != undefined) {
            res.json(await bd.search(query.word));
        }
    })

    // mène à la page de connexion pour s'assurer que c'est bien le gérant
    server.route("/gerant")
    .get((req, res) => {
        actiongerant = true;
        res.render("connexion", {
            message: '',
            email: '',
            mdp: '', 
            gerant: actiongerant
        });
    });

    // envoie le prix total du panier de l'utilisateur connecté
    server.get('/totalPrice', async (req, res) => {
        let totalPrice = 0;
        if (req.session.token) {
          let token = jwt.verify(req.session.token, JWT_SECRET);
          totalPrice = await bd.getTotalPanier(token.email);
        }
        res.json({ total: totalPrice });
      });
      
}

// intercepter le signal SIGINT (CTRL+C)
process.on('SIGINT', async () => {
    // libérer le pool de connexions
    await bd.disconnect();
    process.exit(0);
});

run();
const port = 8081;
server.listen(port, () => console.log('Listening on port ' + port))
