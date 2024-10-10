# Fringues de Clochard - Projet WEB

charger les données dans la base de donnée (remplacer username par le nom de l'user)
> psql -U `username` -W postgres -f init.sql

Se connecter dans la base de donnée (remplacer username par le nom de l'user)
> psql -U `username` -d frip_clochard

ligne 5 fichier bd.js
paramètres à changer si besoin 
em -> utilisateur de base
password -> avec son mdp 
frip_clochard -> le nom de la database

Les gérants sont hardcoder dans la base de donnée.
mail : `util-gerant@gmail.com`,
mdp : `password`

Le site est sur le port 8081