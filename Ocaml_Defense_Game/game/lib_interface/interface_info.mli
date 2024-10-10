open Lib_type.Board
open Lib_type.Pion
open Lib_type.Player

module Info_to_interface :
sig 

type visible_unit_info = {
    id : int;
    player_id : int;
    unit_class : string;
    health : int;
    max_health : int;
  }
    
  
  type tile = {
    type_tile : string;
    visibility : bool;
    visible_unit_info : visible_unit_info list;
  }

  type player_info = { 
    id : int;
    name : string;
    gold : int;
    score : int;
  }

  type message = {
    width : int;
    height : int;
    tiles : tile array array;
    players_info : player_info list;
  }

    (** Crée un message vide *)
    val create_empty_message : unit -> message

    (** Récupère la visibilité d'une case *)
    val get_visibility : tile -> bool

    (** Récupère le type d'une case *)
    val get_type_tile : tile -> string

    (** Récupère les unités visibles sur une case *)
    val get_visible_units : tile -> visible_unit_info list

    (** Récupère les informations sur une unité visible à partir de son identifiant *)
    val get_visible_unit_info : tile -> int -> visible_unit_info

    (** Vérifie si une unité appartient à un joueur *)
    val belongs_to_player : visible_unit_info -> int -> bool

    (** Récupère la classe d'une unité *)
    val get_unit_class : visible_unit_info -> string

    (** Récupère les points de vie actuels d'une unité *)
    val get_health : visible_unit_info -> int

    (** Récupère les points de vie maximum d'une unité *)
    val get_max_health : visible_unit_info -> int

    (** Récupère l'identifiant d'une unité *)
    val get_id : visible_unit_info -> int

    (** Récupère l'identifiant du joueur d'une unité *)
    val get_id_player_from_unit_info : visible_unit_info -> int

    (** Récupère le nom d'un joueur *)
    val get_name : player_info -> string

    (** Récupère la quantité d'or d'un joueur *)
    val get_gold : player_info -> int

    (** Récupère le score d'un joueur *)
    val get_score : player_info -> int

    (** Récupère l'identifiant d'un joueur *)
    val get_id_player : player_info -> int

    (** Récupère les informations sur un joueur à partir de son identifiant *)
    val get_players_info : int -> message -> player_info option

    (** Récupère les cases du plateau *)
    val get_tiles : message -> tile array array

    (** Récupère une case du plateau à partir de ses coordonnées *)
    val get_tile : int -> int -> message -> tile

    (** Récupère la largeur du plateau *)
    val get_width : message -> int

    (** Récupère la hauteur du plateau *)
    val get_height : message -> int

    (** Récupère les identifiants des unités d'un joueur à partir de coordonnées *)
    val get_player_units_from_coords : message -> int -> int * int -> int list

    (** Convertit une case de jeu en une case de l'interface *)
    val convert_tile : CombatUnit.combat_unit list -> Game_board.tile -> tile

    (** Convertit les joueurs en informations sur les joueurs *)
    val convert_players : Player.player list -> player_info list

    (** Convertit un plateau de jeu en un message pour l'interface *)
    val convert_board : Lib_type.Pion.CombatUnit.combat_unit list ->
        Lib_type.Board.Game_board.board ref ->
        Lib_type.Player.Player.player list -> message   


end 