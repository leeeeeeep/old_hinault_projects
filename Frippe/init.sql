CREATE DATABASE frip_clochard;

\c frip_clochard 
DROP TABLE IF EXISTS utilisateur cascade;
DROP TABLE IF EXISTS panier cascade;
DROP TABLE IF EXISTS panier_produit cascade;
DROP TABLE IF EXISTS ensAccessoire cascade;
DROP TABLE IF EXISTS combinaison cascade;
DROP TABLE IF EXISTS produit cascade;

CREATE TABLE utilisateur (
    id_utilisateur SERIAL PRIMARY KEY,

    -- pour passer une commande
    adresse JSON,
    telephone TEXT,
    mail TEXT NOT NULL UNIQUE,

    -- + si inscrit
    password TEXT DEFAULT NULL,
    indexAdrDefault INTEGER DEFAULT -1,
    
    -- + si gérant
    gerant BOOLEAN DEFAULT false
);

CREATE TABLE produit (
    id_produit SERIAL PRIMARY KEY,
    info JSON NOT NULL
);

CREATE TABLE photo (
    id_photo SERIAL PRIMARY KEY,
    img TEXT NOT NULL
);
/*
info format
{
    prix: INTEGER
    sexe; STRING
    matiere: STRING
    type: STRING
    description: STRING
    stock: ARRAY OF Stock 
}
Stock = {
    taille: STRING
    couleur: STRING
    quantite: INTEGER
    img: STRING
}
*/

CREATE TABLE panier (
    id_panier SERIAL PRIMARY KEY,
    id_utilisateur INTEGER NOT NULL,
    confirmer BOOLEAN DEFAULT TRUE,
    h_livraison TIME,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur(id_utilisateur)
);

CREATE TABLE panier_produit (
    id_panier_produit SERIAL,
    id_panier INTEGER,
    id_article INTEGER,
    id_produit INTEGER,
    id_produit_indice INTEGER,
    combinaison BOOLEAN DEFAULT FALSE,
    quantite INTEGER,
    PRIMARY KEY (
        id_panier_produit, id_panier, id_produit, id_produit_indice, 
        combinaison, quantite
    )
);

CREATE TABLE ensAccessoire (
    id_ensaccessoire SERIAL,
    id_produit INTEGER,
    id_produit_accessoire INTEGER,
    PRIMARY KEY (id_ensaccessoire, id_produit, id_produit_accessoire)
);

CREATE TABLE combinaison (
    num_combinaison SERIAL PRIMARY KEY,
    info JSON NOT NULL,
    prix FLOAT NOT NULL,
    description TEXT NOT NULL
);
/* 
base : pantalon sans accessoire, chemise, veste
business : pantalon avec ceinture, chemise avec cravate, chemise
luxe : pantalon avec ceinture, chemise avec cravate, chemise avec noeud papillon
 */
\! echo "============Init Photo==================================="
INSERT INTO photo(img) VALUES ('/Produits/default.png');
INSERT INTO photo(img) VALUES ('/Produits/blazer_rose.png');
INSERT INTO photo(img) VALUES ('/Produits/cargo_blanc.png');
INSERT INTO photo(img) VALUES ('/Produits/cargo_bleu_gris.png');
INSERT INTO photo(img) VALUES ('/Produits/cargo_marron.png');
INSERT INTO photo(img) VALUES ('/Produits/cargo_navy.png');
INSERT INTO photo(img) VALUES ('/Produits/chino_blanc.png');
INSERT INTO photo(img) VALUES ('/Produits/chino_kaki.png');
INSERT INTO photo(img) VALUES ('/Produits/chino_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/debardeur_blanc.png');
INSERT INTO photo(img) VALUES ('/Produits/debardeur_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/jean_blanc.png');
INSERT INTO photo(img) VALUES ('/Produits/jean_bleu.png');
INSERT INTO photo(img) VALUES ('/Produits/jean_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/jean-troue.png');
INSERT INTO photo(img) VALUES ('/Produits/loose_pant_gris.png');
INSERT INTO photo(img) VALUES ('/Produits/loose_pant_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/p_survet_beige.png');
INSERT INTO photo(img) VALUES ('/Produits/p_survet_bleu.png');
INSERT INTO photo(img) VALUES ('/Produits/p_survet_kaki.png');
INSERT INTO photo(img) VALUES ('/Produits/p_survet_vert.png');
INSERT INTO photo(img) VALUES ('/Produits/pant_classique.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_beige_claire.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_beige.png');
INSERT INTO photo(img) VALUES ('/Produits/veste_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/veste_navy.png');
INSERT INTO photo(img) VALUES ('/Produits/tshirt_rayure.png');  
INSERT INTO photo(img) VALUES ('/Produits/tshirt_rayure_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/tshirt_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/tshirt_blanc.png');
INSERT INTO photo(img) VALUES ('/Produits/strech_chino_noir.png)');
INSERT INTO photo(img) VALUES ('/Produits/strech_chino_navy.png');
INSERT INTO photo(img) VALUES ('/Produits/strech_chino_marron.png');
INSERT INTO photo(img) VALUES ('/Produits/strech_chino_blanc.png');
INSERT INTO photo(img) VALUES ('/Produits/strech_chino_beige.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_violet.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_vert.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_noir.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_gris.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_bleu.png');
INSERT INTO photo(img) VALUES ('/Produits/pull_bleu_navy.png');





\! echo "============Insertion des utilisateurs==================="
INSERT INTO utilisateur(adresse, mail, telephone) 
VALUES (
    '[{"nom": "util", "prenom": "sans compte", "adresse": "etc"}]',
    'util-sans-compte@gmail.com', '0000000000'
);
INSERT INTO utilisateur(adresse, indexAdrDefault, mail, telephone, password) 
VALUES (
    '[
        {"nom": "util", "prenom": "avec compte", "adresse": "etc"},
        {"nom": "util", "prenom": "avec compte", "adresse": "etc"}
    ]', 0,
    'util-avec-compte@gmail.com', '0000000001',
    '$2b$10$3zoFRQlTf65oKNWPF2x1yu6ftaAnmcMkY6aWoUkB5bb/ov2RWKQhK'
    -- password2
);
INSERT INTO utilisateur(adresse, mail, telephone, password, gerant) VALUES (
    '[]',
    'util-gerant@gmail.com', '0000000002', 
    '$2b$10$Ae3tx/n99GNOsUm3D/9cqOYpI7RWYPIL03/7PygXO8Vx26Fx20MBG',true
    -- password
);
\! echo "============Insertion des produits======================="
INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"cotton",
    "type":"t-shirt",
    "description":"t-shirt",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":0,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"}, 
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"}, 
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"XS","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"cotton",
    "type":"veste",
    "description":"veste",
    "stock":[
        {"taille":"XL","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"polysthere",
    "type":"chino",
    "description":"strech chino",
    "stock":[
        {"taille":"XL","couleur":"beige","quantite":5,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"L","couleur":"beige","quantite":10,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"M","couleur":"beige","quantite":10,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"S","couleur":"beige","quantite":2,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"},
        {"taille":"L","couleur":"white","quantite":0,"img":"/Produits/strech_chino_blanc.png"}, 
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"}, 
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"},
        {"taille":"XS","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"},
        {"taille":"L","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"}, 
        {"taille":"M","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"}, 
        {"taille":"S","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"},
        {"taille":"XS","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"}, 
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"}, 
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"},
        {"taille":"XS","couleur":"navy","quantite":0,"img":"/Produits/strech_chino_navy.png"},
        {"taille":"S","couleur":"green","quantite":0,"img":"/Produits/strech_chino_navy.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"U",
    "matiere":"laine",
    "type":"pull",
    "description":"pull",
    "stock":[
        {"taille":"XL","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"L","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"M","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"S","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"L","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"}, 
        {"taille":"M","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"}, 
        {"taille":"S","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"},
        {"taille":"XS","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"},
        {"taille":"L","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"}, 
        {"taille":"M","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"}, 
        {"taille":"S","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"},
        {"taille":"XS","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"},
        {"taille":"XS","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"laine",
    "type":"pull",
    "description":"pull",
    "stock":[
        {"taille":"XL","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"M","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"S","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"},
        {"taille":"XS","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"},
        {"taille":"XS","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}
    ]}');


INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"laine",
    "type":"pull",
    "description":"pull",
    "stock":[
        {"taille":"XL","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"M","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"S","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"},
        {"taille":"XS","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"laine",
    "type":"chemise",
    "description":"chemise",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"tissu",
    "type":"short",
    "description":"short",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"tissu",
    "type":"basket",
    "description":"basket",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"cuir",
    "type":"mocassin",
    "description":"mocassin",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"cuir",
    "type":"botte",
    "description":"botte",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"tissu",
    "type":"echarpe",
    "description":"echarpe",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"U",
    "matiere":"cuir",
    "type":"ceinture",
    "description":"ceinture",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"tissu",
    "type":"gant",
    "description":"gant",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"F",
    "matiere":"tissu",
    "type":"chaussette_courte",
    "description":"chaussette_courte",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

 INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"cotton",
    "type":"t-shirt",
    "description":"t-shirt",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/tshirt_blanc.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/tshirt_noir.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"XS","couleur":"white","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"cotton",
    "type":"veste",
    "description":"veste",
    "stock":[
        {"taille":"XL","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/veste_navy.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/veste_noir.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"U",
    "matiere":"polysthere",
    "type":"chino",
    "description":"strech chino",
    "stock":[
        {"taille":"XL","couleur":"beige","quantite":10,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"L","couleur":"beige","quantite":10,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"M","couleur":"beige","quantite":10,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"S","couleur":"beige","quantite":10,"img":"/Produits/strech_chino_beige.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/strech_chino_noir.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"}, 
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"}, 
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"},
        {"taille":"XS","couleur":"white","quantite":10,"img":"/Produits/strech_chino_blanc.png"},
        {"taille":"L","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"}, 
        {"taille":"M","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"}, 
        {"taille":"S","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"},
        {"taille":"XS","couleur":"brown","quantite":10,"img":"/Produits/strech_chino_marron.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"}, 
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"}, 
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"},
        {"taille":"XS","couleur":"navy","quantite":10,"img":"/Produits/strech_chino_navy.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"U",
    "matiere":"laine",
    "type":"pull",
    "description":"pull",
    "stock":[
        {"taille":"XL","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"L","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"M","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"S","couleur":"beige","quantite":10,"img":"/Produits/pull_beige.png"},
        {"taille":"L","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"}, 
        {"taille":"M","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"}, 
        {"taille":"S","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"},
        {"taille":"XS","couleur":"violet","quantite":10,"img":"/Produits/pull_violet.png"},
        {"taille":"L","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"}, 
        {"taille":"M","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"}, 
        {"taille":"S","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"},
        {"taille":"XS","couleur":"green","quantite":10,"img":"/Produits/pull_vert.png"},
        {"taille":"L","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"}, 
        {"taille":"M","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"}, 
        {"taille":"S","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"},
        {"taille":"XS","couleur":"black","quantite":10,"img":"/Produits/pull_noir.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"},
        {"taille":"XS","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"laine",
    "type":"pull",
    "description":"pull",
    "stock":[
        {"taille":"XL","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"M","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"S","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"},
        {"taille":"XS","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"},
        {"taille":"L","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"M","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}, 
        {"taille":"S","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"},
        {"taille":"XS","couleur":"navy","quantite":10,"img":"/Produits/pull_bleu_navy.png"}
    ]}');


INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"laine",
    "type":"pull",
    "description":"pull",
    "stock":[
        {"taille":"XL","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"M","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"S","couleur":"blue","quantite":10,"img":"/Produits/pull_bleu.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"},
        {"taille":"XS","couleur":"grey","quantite":10,"img":"/Produits/pull_gris.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"laine",
    "type":"chemise",
    "description":"chemise",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"tissu",
    "type":"short_c",
    "description":"short",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"tissu",
    "type":"basket",
    "description":"basket",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"cuir",
    "type":"botte",
    "description":"botte",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"tissu",
    "type":"echarpe",
    "description":"echarpe",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"H",
    "matiere":"cuir",
    "type":"ceinture",
    "description":"ceinture",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":12,
    "sexe":"U",
    "matiere":"tissu",
    "type":"gant",
    "description":"gant",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":15,
    "sexe":"H",
    "matiere":"tissu",
    "type":"chaussette_longue",
    "description":"chaussette_longue",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":15,
    "sexe":"U",
    "matiere":"tissu",
    "type":"socquette",
    "description":"socquette",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":15,
    "sexe":"U",
    "matiere":"tissu",
    "type":"cravatte",
    "description":"cravatte",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

INSERT INTO produit(info) VALUES (
    '{"prix":15,
    "sexe":"U",
    "matiere":"tissu",
    "type":"noeud_papillon",
    "description":"noeud papillon",
    "stock":[
        {"taille":"XL","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"M","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"S","couleur":"white","quantite":10,"img":"/Produits/default.png"},
        {"taille":"L","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"M","couleur":"grey","quantite":10,"img":"/Produits/default.png"}, 
        {"taille":"S","couleur":"grey","quantite":10,"img":"/Produits/default.png"}
    ]}');

\! echo "==============Creation des combinaisons=================="

INSERT INTO combinaison(info, prix, description) 
VALUES ('[[14,3],[2,3]]', 10, 'combi1');
INSERT INTO combinaison(info, prix, description) 
VALUES ('[[28,2],[17,1],[7,2]]', 10, 'combi2');
INSERT INTO combinaison(info, prix, description) 
VALUES ('[[28,3],[2,3],[22,1]]', 10, 'combi3');
INSERT INTO combinaison(info, prix, description) 
VALUES ('[[14,3],[17,3]]', 10, 'combi4');

\! echo "===========Associe produit avec accessoires=============="
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (10, 15);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (11, 15);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (10, 31);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (25, 15);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (1, 12);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (6, 12);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (18, 27);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (19, 29);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (22, 27);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (7, 32);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (22, 33);
INSERT INTO ensAccessoire(id_produit, id_produit_accessoire) VALUES (22, 31);

\! echo "============Creation des paniers========================="
-- INSERT INTO panier(id_utilisateur, confirmer) VALUES(1, True);
-- INSERT INTO panier_produit(
--     id_panier, id_article, id_produit, id_produit_indice, combinaison, quantite
-- ) VALUES(
--     1, 1, 1, 3, FALSE, 3
-- );
-- INSERT INTO panier(id_utilisateur, confirmer) VALUES(2, False);
-- INSERT INTO panier_produit(
--     id_panier, id_article, id_produit, id_produit_indice, combinaison, quantite
-- ) VALUES(
--     2, 1, 1, 3, FALSE, 3
-- );
-- INSERT INTO panier_produit(
--     id_panier, id_article, id_produit, id_produit_indice, combinaison, quantite
-- ) VALUES(
--     2, 2, 2, 3, FALSE, 3
-- );
INSERT INTO panier(id_utilisateur, confirmer) VALUES (3, False);
