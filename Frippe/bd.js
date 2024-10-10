function bd() {
    const pg = require('pg');
    const bc = require("bcrypt");

    const pool = new pg.Pool ({
    user: 'em',
        host: 'localhost',
        database: 'frip_clochard',
        password: 'password',
        port: 5432
    });

    let client;
    
    // Connection à la base de donnée 
    this.connect = async function() {
        client = await pool.connect();
    }

    // Termine la connection à la base de donnée
    this.disconnect = async function() {
        pool.end();
    }

    this.search = async function(query) {
        let tab = []
        let q = "SELECT id_produit, info ->> 'description' as description " +
                "FROM produit " +
                "WHERE info->>'description' LIKE $1";
        let res = await client.query(q, ["%"+query+"%"]);
        for(let r of res.rows) {
            tab.push({id_produit: r.id_produit, description: r.description});
        }
        return tab;
    }

    // Renvoie si c'est un utilisateur inscrit
    this.isuser = async function(email, pwd) {
        let res = await client.query("SELECT * FROM utilisateur WHERE mail = $1", 
                                    [email]);
        if(res.rows != 0) {
            return new Promise((resolve, reject) => {
                bc.compare(pwd, res.rows[0].password, function(err, result) {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(result);
                    }
                });
            });
        }
        return false;
    }

    this.mailisuser = async function(email) {
        let q = await client.query("SELECT * FROM utilisateur WHERE mail = $1", 
                                    [email]);
        if (q.rows != 0) {
            return true;
        }
        return false;
    }

    // Renvoie si l'utilisateur est un gérant ou pas
    this.isadmin = async function(email) {
        let q = "SELECT * FROM utilisateur WHERE mail = $1 AND gerant = true";
        let res = await client.query(q, [email]);
        return res.rows != 0;
    }

    // Ajout d'un utilisateur (lors de l'inscription)
    this.inscription = async function(email, pwd) {
        if (!await this.isuser(email, pwd)) {
          try {
            // hashage du mot de passe
            const hashedPwd = await new Promise((resolve, reject) => {
              bc.hash(pwd, 10, function(err, hash) {
                if (err) reject(err);
                resolve(hash);
              });
            });
      
            await client.query("INSERT INTO utilisateur(mail, password) VALUES ($1, $2)", [email, hashedPwd]);
          } catch (error) {
            console.error("Erreur lors du hachage du mot de passe :", error);
          }
        } else {
          console.log("Déjà présent donc non rajouté");
        }
      }
      
    this.getPhoto = async function() {
        let q = "SELECT img FROM photo";
        return await client.query(q);
    }

    
    this.modifMdp = async function(email, nv_mdp) {
        bc.hash(nv_mdp, 10, async function(err, hash) {
            let q = "UPDATE utilisateur SET password = $1 WHERE mail = $2";
            await client.query(q, [hash, email]);
        });
    }

    this.updateProduit = async function (produit, id) {
        let q = "Update produit SET info = $1 Where id_produit = $2";
        await client.query(q, [produit, id]);
    }

    // Ajout d'un produit
    this.insertProd = async function(prod) {
        console.log(JSON.stringify(prod));
        await client.query("INSERT INTO produit(info) VALUES ($1)", 
            [JSON.stringify(prod)]);
    }

    //tous les produits
    this.getProd = async function () {
      let prod = await client.query ("SELECT * From produit");
      return prod;
    }

    //combinaison particulière
    this.getCombi = async function (id) {
        let q = "SELECT * from combinaison where num_combinaison = $1"
        let combi = await client.query(q, [id]);
        return combi;
    }

    //toutes les combi
    this.getAllCombi = async function () {
        let q = "SELECT * from combinaison";
        return await client.query(q);
    }

    //produit particulier
    this.getThisProd = async function(id) {
      let query = "Select * From produit where id_produit = $1";
      let res = await client.query (query, [id]);
      return res;
  }

    // Récupère tous les adresses de l'utilisateur
    this.getAdr = async function(email) {
        let q = "SELECT adresse, indexAdrDefault FROM utilisateur WHERE mail = $1"
        let adr = await client.query(q, [email]);
        if(adr.rows != 0) {
            if(!adr.rows[0].adresse) {
                return { adresse:[], indexadrdefault: -1 };
            }
            return { adresse: adr.rows[0].adresse, 
                     indexadrdefault: adr.rows[0].indexadrdefault };
        }
        return { adresse:[], indexadrdefault: -1 };
    }

    // Récupère l'adresse par défaut de l'utilisateur
    this.getAdrDefault = async function(email) {
        let q = "SELECT adresse, indexAdrDefault " +
                "FROM utilisateur " + 
                "WHERE mail = $1";
        let adr = await client.query(q, [email])
        if (adr.rows.length > 0) {
            if (adr.rows[0].adresse !== undefined && 
                adr.rows[0].indexadrdefault !== undefined) {
                if (adr.rows[0].adresse != null) {
                    return adr.rows[0].adresse[adr.rows[0].indexadrdefault];
                }
            }
        }
        return {};
    }

    // change l'adresse par défaut de l'utilisateur
    this.setAdrDefault = async function(email, nv_adr) {
        let q = "UPDATE utilisateur SET indexAdrDefault = $1 WHERE mail = $2";
        await client.query(q, [nv_adr, email]);
    }

    // Mise a jour de la liste d'adresses d'un utilisateur
    // index -1 insertion d'une adresse dans la liste d'adresses
    // index >= 0 mis à jour d'une adresse déjà existant dans la liste d'adresses
    this.updateAdr = async function(email, nom, prenom, adresse, index) {
        let q1 = "SELECT adresse FROM utilisateur WHERE mail = $1";
        let res = await client.query(q1, [email]);
        let adresses = res.rows[0].adresse;
        let q2 = "";

        if(index === -1) {
            let nouveau = {"nom": nom, "prenom": prenom, "adresse": adresse};
            q2 = "UPDATE utilisateur SET adresse = " +
                "CASE WHEN adresse IS NULL " +
                "THEN jsonb_build_array($1::jsonb) " +
                "ELSE adresse::jsonb || $1::jsonb " +
                "END " +
                "WHERE mail = $2";
            await client.query(q2, [nouveau, email]);
        } else if (index >= 0 && index < adresses.length) {
            adresses[index].nom = nom;
            adresses[index].prenom = prenom;
            adresses[index].adresse = adresse;
            q2 = "UPDATE utilisateur SET adresse = $1::jsonb WHERE mail = $2";
            await client.query(q2, [JSON.stringify(adresses), email]);
        } else {
            console.log("Index invalid.");
        }
        console.log("Mis a jour adresse reussi")
    }

    // Supprime l'adresse de la liste d'adresse de l'utilisateur
    this.deleteAdr = async function(email, index) {
        const q = "UPDATE utilisateur " + 
                "SET adresse = (adresse::jsonb #- $1)::text::jsonb " +
                "WHERE mail = $2";
        await client.query(q, [[index], email]);
        console.log("Suppression reussi");
    }

    // Récupère l'id du dernier panier que l'utilisateur n'a pas encore confirmé
    this.getIdDernierPanier = async function(email) {
        const q = "SELECT id_panier "+
                "FROM Panier NATURAL JOIN utilisateur " +
                "WHERE mail = $1 AND confirmer = FALSE";
        let panier = await client.query(q, [email]);
        if(panier.rows.length === 0) {
            return 0
        }
        return panier.rows[0].id_panier;
    }

    // renvoie les produits qui sont contenu dans le panier 
    // dans un format spécifique au panier
    this.getProdFormatPanier = async function(id_panier) {
        // recupere les produits du panier non confirmé
        let query = "SELECT produit.id_produit, info, id_produit_indice, quantite " +
        "FROM panier_produit " +
        "JOIN produit " +
        "ON panier_produit.id_article = produit.id_produit " +
        "WHERE id_panier = $1 AND combinaison = FALSE";
        let panier = await client.query(query, [id_panier]);
        let tab = [];
        if (panier.rows.length > 0) {
            for(let p of panier.rows) {
                tab.push({
                    id_article: p.id_produit,
                    prix_article: p.info.prix,
                    img_article: p.info.stock[p.id_produit_indice].img,
                    id_produit: [p.id_produit],
                    produit: [p.info],
                    indiceStock: [p.id_produit_indice],
                    quantite: p.quantite,
                    quantiteMax: p.info.stock[p.id_produit_indice].quantite
                });
            }
        }
        return tab;
    }

    // renvoie les combinaisons qui sont contenu dans le panier 
    // dans un format spécifique au panier
    this.getCombiFormatPanier = async function(id_panier) {
        // récupère les combinaisons du panier non confirmé
        let query = "SELECT id_article, produit.id_produit, id_produit_indice, "+
                    "prix, quantite, produit.info, "+
                    "json_array_length(combinaison.info) as nbprod "+
                    "FROM panier_produit "+
                    "JOIN combinaison "+
                    "ON panier_produit.id_article = combinaison.num_combinaison "+
                    "JOIN produit "+
                    "ON panier_produit.id_produit = produit.id_produit "+
                    "WHERE id_panier = $1 AND combinaison = TRUE "+
                    "ORDER BY id_panier";
        let panier = await client.query(query, [id_panier]);
        let tab = [];
        let pos = 0;
        if(panier.rows != 0) {
            while(pos !== panier.rowCount) {
                let nb_prod = panier.rows[pos].nbprod;
                let idproduits = [];
                let prodStockIndices = [];
                let prodinfos = [];
                let quantiteMax = 0;
                // récupère les infos de chaque produit qui compose la combinaison
                for(let i = pos; i < pos + nb_prod; i++) {
                    let tmp = panier.rows[i];
                    idproduits.push(tmp.id_produit);
                    prodStockIndices.push(tmp.id_produit_indice);
                    prodinfos.push(tmp.info);
                    quantiteMax = Math.max(quantiteMax, tmp.info.stock[tmp.id_produit_indice].quantite);
                }
                let p = panier.rows[pos];
                tab.push({
                    id_article: p.id_article,
                    prix_article: p.prix,
                    img_article: "Produits/default.png", // TODO
                    id_produit: idproduits,
                    produit: prodinfos,
                    indiceStock: prodStockIndices,
                    quantite: p.quantite,
                    quantiteMax: quantiteMax
                })
                pos += nb_prod;
            }
        }
        return tab;
    }

    // Récupère les articles du panier que l'utilisateur n'a pas encore confirmé
    this.getPanier = async function(email) {
        let id_panier = await this.getIdDernierPanier(email);
        if(id_panier === 0) return [];

        let tab = [];
        // récupère les produits du panier non confirmé
        let prod = await this.getProdFormatPanier(id_panier);
        tab = tab.concat(prod);
  
        // récupère les combinaisons du panier non confirmé
        let combi = await this.getCombiFormatPanier(id_panier);
        tab = tab.concat(combi);

        return tab;
    }

    // récupère l'id de l'utilisateur
    this.getUserId = async function(email) {
        let q = "SELECT id_utilisateur " +
                "FROM utilisateur " + 
                "WHERE mail = $1";
        let res = await client.query(q, [email]);
        if (res.rows != 0) {
            return res.rows[0].id_utilisateur;
        } else {
            console.log("error getuserid");
        }
    }

    // récupère les mail de tous les utilisateurs
    this.getUsersEmail = async function() {
        let q = "SELECT mail FROM utilisateur";
        let res = await client.query(q);
        let tab = [];
        for(let r of res.rows) {
            tab.push(r.mail);
        }
        return tab;
    }

    // Met à jour la table User (lors de la validation du panier)
    this.updateUser = async function(email, nomArg, prenomArg, adresseArg, num_tel) {
        if (await this.mailisuser(email)) {
            // Mise à jour de l'adresse si nécessaire
            let adresseutil = await this.getAdrDefault(email);
            if (adresseutil === {}) {
                await this.updateAdr(email, nomArg, prenomArg, adresseArg, -1);
            }
            // Mise à jour du numéro de téléphone
            let q = "UPDATE utilisateur SET telephone = $1 WHERE mail = $2";
            await client.query(q, [num_tel, email]);
        } else {
            // Crée un nouveau utilisateur
            let q = "INSERT INTO utilisateur(adresse, mail, telephone) " +
                    " VALUES ($1, $2, $3)";
            let adresseQuery = {
                nom: nomArg,
                prenom: prenomArg,
                adresse: adresseArg
            }
            await client.query(q, [JSON.stringify([adresseQuery]), email, num_tel]);
        }
    }

    //ajout de combinaison
    this.addCombi = async function (idStr, description, prix) {
      let q = "INSERT INTO combinaison (info, prix, description)"
      +"VALUES ($1, $2, $3)";
      await client.query(q, [idStr, prix, description]); 
    }

    // Reinitialise le panier non confirmé de l'utilisateur avec l'id id_u
    this.resetPanier = async function(id_u) {
        let q = "SELECT * FROM utilisateur WHERE id_utilisateur = $1";
        let res = await client.query(q, [id_u]);
        if(res.rows != 0) {
            q = "DELETE FROM panier_produit " +
                    "WHERE id_panier = " +
                        "(SELECT id_panier "+
                        "FROM panier "+
                        "WHERE id_utilisateur = $1 "+
                        "AND confirmer = FALSE)";
            await client.query(q, [id_u]);
    
            q = "DELETE FROM panier " +
                    "WHERE id_utilisateur = $1 AND confirmer = FALSE";
            await client.query(q, [id_u]);
        } else {
            console.log("Utilisateur inexistant");
        }
    }

    // Insertion les articles du panier dans les tables des paniers
    this.insertArtInPanier = async function(id_u, livraison, panier) {
        let q;
        q = "INSERT INTO panier(id_utilisateur, h_livraison) VALUES($1, $2)"
        await client.query(q, [id_u, livraison]);

        // Récupérer le panier créé
        q = "SELECT MAX(id_panier) FROM panier WHERE id_utilisateur = $1";
        res = await client.query(q, [id_u]);
        let panier_id = res.rows[0].max;

        // Insérer les articles dans le panier
        for(let i = 0; i < panier.length; i++) {
            if (panier[i].id_produit.length === 1) {
                // cas où on a un produit
                q = "INSERT INTO panier_produit("+
                    "id_panier, id_article, id_produit, id_produit_indice, quantite) "+
                    "VALUES ($1, $2, $3, $4, $5)";
                await client.query(q, [
                    panier_id,
                    panier[i].id_article,
                    panier[i].id_produit[0],
                    panier[i].indiceStock[0],
                    panier[i].quantite
                ]);
            } else {
                // cas où on a une combinaison
                let longueur = panier[i].id_produit.length;
                for(let j = 0; j < longueur; j++) {
                q = "INSERT INTO panier_produit("+
                    "id_panier, id_article, id_produit, id_produit_indice, quantite) "+
                    "VALUES ($1, $2, $3, $4, $5)";
                await client.query(q, [
                    panier_id,
                    panier[i].id_article,
                    panier[i].id_produit[j],
                    panier[i].indiceStock[j],
                    panier[i].quantite
                ]);
                }
            }
        }
        console.log("Ajout des produits dans le panier");
    }

    // Insertion de l'article dans le panier quand l'utilisateur appuie sur 
    // le bouton ajouté
    this.insertArtInPanierNonConfirm = async function(id_u, id_article, id_subid, quantite) {
        let q;
        // récupérer le panier
        q = "SELECT MAX(id_panier) FROM panier WHERE id_utilisateur = $1";
        let res = await client.query(q, [id_u]);
        let panier_id = res.rows[0].max;
        let quantiteProdPanier = 0;
        let quantiteMax = 10;

        if (id_subid === undefined) {
            // cas où on essaie de rajouter une combinaison
            // on limite la quantite que l'utilisateur veut rajouter
            // on récupère la quantité de la combinaison dans le panier
            q = "SELECT "+
                    "c.num_combinaison, "+
                    "SUM(pp.quantite)/json_array_length(info) AS quantite "+
                "FROM panier_produit pp "+
                "JOIN combinaison c ON pp.id_article = c.num_combinaison "+
                "WHERE pp.id_panier = $1 AND pp.combinaison = TRUE "+
                "AND c.num_combinaison = $2" +
                "GROUP BY c.num_combinaison";
            res = await client.query(q, [panier_id, id_article.num_combinaison]);
            if (res.rows != 0) {
                quantiteProdPanier = parseInt(res.rows[0].quantite);
            }
            // on récupère les infos de chaque produit qui compose la combinaison
            q = "SELECT p.info, json_array_length(combinaison.info) AS total " +
                "FROM panier_produit pp " +
                "JOIN produit p ON pp.id_produit = p.id_produit " +
                "JOIN combinaison ON combinaison.num_combinaison = pp.id_article " +
                "WHERE pp.id_panier = $1 AND pp.combinaison = TRUE " +
                "AND pp.id_article = $2 " +
                "ORDER BY pp.id_article";

            res = await client.query(q, [panier_id, id_article.num_combinaison]);
            for(let i = 0; i < res.rows[0].total; i++) {
                quantiteMax = Math.min(quantiteMax, 
                    res.rows[i].info.stock[id_article.info[i][1]].quantite)
            }
            quantite = Math.min(
                quantiteMax - quantiteProdPanier,
                quantite
            );

            // insertion un à un des produits de la combinaison
            for(let elem of id_article.info) {
                q = "INSERT INTO panier_produit"+
                "(id_panier, id_article, id_produit, id_produit_indice, quantite, combinaison) "+
                "VALUES ($1, $2, $3, $4, $5, true)";
                res = await client.query(q, 
                    [
                        panier_id,
                        id_article.num_combinaison,
                        elem[0], 
                        elem[1],
                        quantite
                    ]);
            }
        } else {
            // cas où on essaie de rajouter un produit
            // on limite la quantite que l'utilisateur veut rajouter
            // on récupère la quantité du produit dans le panier
            q = "SELECT id_produit, SUM(pp.quantite) as quantite " +
            "FROM panier_produit pp " +
            "WHERE pp.id_panier = $1 " +
            "AND combinaison = FALSE " +
            "AND id_article = $2 " +
            "AND id_produit_indice = $3 " +
            "GROUP BY id_produit, id_produit_indice";
            res = await client.query(q, [panier_id, 
                                    parseInt(id_article), 
                                    parseInt(id_subid)]);
            if (res.rows != 0) {
                quantiteProdPanier = parseInt(res.rows[0].quantite);
            }

            // on récupère la quantité max du produit
            q = "SELECT info " +
            "FROM produit " +
            "WHERE id_produit = $1";
            res = await client.query(q, [id_article]);
            quantiteMax = res.rows[0].info.stock[id_subid].quantite;
            // on met à jour la quantité de sorte que ça ne sort pas des limites
            quantite = Math.min(
                quantiteMax - quantiteProdPanier,
                quantite
            );

            // insertion du produit dans le panier
            q = "INSERT INTO panier_produit("+
                    "id_panier, id_article, id_produit, "+
                    "id_produit_indice, quantite"+
                ") VALUES ($1, $2, $2, $3, $4)";
            res = await client.query(q, 
                [panier_id, id_article, id_subid, quantite]);
        }
    }

    this.removeStock = async function(panier) {
        for (const product of panier) {
            // Extraire le champ 'stock' du produit en tant que chaîne de caractères
            let sqlSelect = `
                SELECT info ->> 'stock' as stock
                FROM produit
                WHERE id_produit = $1
            `;
            const resSelect = await client.query(sqlSelect, [product.id_article]);
            const stockStr = resSelect.rows[0].stock;
        
            // Modifier la quantité de stock correspondante en utilisant les fonctions JavaScript
            const stock = JSON.parse(stockStr);
            stock[product.indiceStock].quantite -= product.quantite;
            if(stock[product.indiceStock].quantite < 0) {
                stock[product.indiceStock].quantite = 0;
            }
            const newStockStr = JSON.stringify(stock);
        
            // Mettre à jour le champ 'stock' du produit avec la nouvelle valeur
            let sqlUpdate = `
                UPDATE produit
                SET info = json_build_object(
                'prix', info ->> 'prix',
                'sexe', info ->> 'sexe',
                'matiere', info ->> 'matiere',
                'type', info ->> 'type',
                'description', info ->> 'description',
                'stock', $1::json
                )
                WHERE id_produit = $2
            `;
            await client.query(sqlUpdate, [newStockStr, product.id_article]);
        }
        console.log("Mise à jour du stock");
    }

    this.addStock = async function(panier) {
        for (const product of panier) {
            // Extraire le champ 'stock' du produit en tant que chaîne de caractères
            let sqlSelect = `
                SELECT info ->> 'stock' as stock
                FROM produit
                WHERE id_produit = $1
            `;
            const resSelect = await client.query(sqlSelect, [product.id_article]);
            const stockStr = resSelect.rows[0].stock;
        
            // Modifier la quantité de stock correspondante en utilisant les fonctions JavaScript
            const stock = JSON.parse(stockStr);
            stock[product.indiceStock].quantite += product.quantite;
            const newStockStr = JSON.stringify(stock);
        
            // Mettre à jour le champ 'stock' du produit avec la nouvelle valeur
            let sqlUpdate = `
                UPDATE produit
                SET info = json_build_object(
                'prix', info ->> 'prix',
                'sexe', info ->> 'sexe',
                'matiere', info ->> 'matiere',
                'type', info ->> 'type',
                'description', info ->> 'description',
                'stock', $1::json
                )
                WHERE id_produit = $2
            `;
            await client.query(sqlUpdate, [newStockStr, product.id_article]);
        }
        console.log("Mise à jour du stock");
    }

    this.makePanier = async function (id_u) {
        let q = "INSERT INTO panier(id_utilisateur, confirmer) VALUES($1, $2)"
        await client.query(q, [id_u, false]);
        console.log("Création du panier");
    }

    this.getTotalPanier = async function (email) {
        let id_panier = await this.getIdDernierPanier(email);
        if (id_panier === 0) return 0;        
        let total = 0;

        // récupère le montant des produits contenu dans le panier
        let query = "SELECT SUM((p.info->>'prix')::numeric * pp.quantite) AS total " +
          "FROM panier_produit pp " +
          "JOIN produit p ON pp.id_produit = p.id_produit " +
          "WHERE pp.id_panier = $1 AND pp.combinaison = FALSE";
        let result = await client.query(query, [id_panier]);
        if (result.rows !== undefined && result.rows[0].total !== null) {
            total += parseInt(result.rows[0].total);
        }

        // récupère le montant des combinaisons contenu dans le panier
        query = "SELECT SUM(prix * quantite) AS total "+
        "FROM combinaison, "+
        "("+
            "SELECT "+
                "c.num_combinaison, "+
                "SUM(pp.quantite)/json_array_length(info) AS quantite "+
            "FROM panier_produit pp "+
            "JOIN combinaison c ON pp.id_article = c.num_combinaison "+
            "WHERE pp.id_panier = $1 AND pp.combinaison = TRUE "+
            "GROUP BY c.num_combinaison "+
        ") AS quantitecombi " +
        "WHERE combinaison.num_combinaison = quantitecombi.num_combinaison";
        result = await client.query(query, [id_panier]);
        if (result.rows !== undefined && result.rows[0].total !== null) {
            total += parseInt(result.rows[0].total);
        }
        return total;
    }
}

module.exports = new bd();

// psql -U em -d frip_clochard
// psql -U em -W postgres -f init.sql
