open Lib_type.Player
open Lib_type.Pion
open Lib_type.Board
open Lib_interface
(* open Lwt *)

module Game_manager : sig
    type game_info = {
      mutable players : Player.player list;
      mutable units : CombatUnit.combat_unit list;
      mutable board : Game_board.board;
      mutable throne : (int*int*int) list;
    }
  
    val create_game : unit -> game_info
    (** [create_game ()] crée une partie vide*)

    val add_throne : int -> int -> int -> game_info -> bool
    (** [add_throne x y id_player game] ajoute un trône au joueur d'id [id_player] à la position [x][y] et renvoie un bool selon la réussite*)

    val remove_throne : int -> int -> game_info -> bool
    (** [remove_throne x y game] retire le trône à la position [x][y] et renvoie un bool selon la réussite*)

    val update_throne : game_info -> unit
    (** [update_throne game] met à jour la situation des trônes, enlève le trone si unité ennemie dessus*)

    val game_done : game_info ->
      (Game_interface.Game_interface.interface_config ref ->
       bool Lwt.t) ->
      Game_interface.Game_interface.interface_config ref ->
      unit Lwt.t
    (** [game_done game f config] vérifie si la partie est terminée et renvoie un booléen
    termine si une unité entre dans le trone ou que la limite de temps est dépassée    
    *)

    val get_unit : game_info -> int -> CombatUnit.combat_unit
    (** [get_unit game id_unit] prends l'id de l'unité et renvoie l'objet unité*)

    val condition_end_timeout : Game_interface.Game_interface.interface_config ref -> bool Lwt.t
    (** [condition_end_timeout config] renvoie true si le nombre de tick dépasse la limite de temps*)

    val get_player : int -> game_info -> Player.player
    (** [get_player id_player] prends l'id du player et renvoie l'objet player*)

    val get_unit_opt : game_info -> int -> CombatUnit.combat_unit option
    (** [get_unit_opt game id_unit] prends l'id de l'unité et renvoie l'objet unité option*)

    val add_player : Player.role -> game_info -> unit
    (** [add_player role game] ajoute un joueur de role [role] à la partie [game]*)

    val remove_player : int -> game_info -> unit
    (** [remove_player id_player game] retire le joueur d'id [id_player] de la partie [game]*)

    val add_unit : int*int -> int -> string -> game_info -> unit
    (** [add_unit (x,y) id_player unit_name game] ajoute une unité de type [unit_name] au joueur d'id [id_player] à la position [(x,y)] dans la partie [game]*)

    val standard_unit_price : string -> int
    (** [standard_unit_price unit_name] renvoie le prix standard de l'unité [unit_name]*)

    val buying : int -> Player.player -> bool
    (** [buying price player] renvoie true si le joueur peut acheter l'unité*)

    val buy_unit : int*int -> int -> string -> game_info -> int -> int -> unit
    (** [buy_unit (x,y) id_player unit_name game] ajoute une unité de type [unit_name] au joueur d'id [id_player] à la position [(x,y)] dans la partie [game] et teste le prix*)

    val buy_wall : Player.player -> game_info -> int -> int -> unit
    (** [buy_wall player game x y] ajoute un mur à la position [x][y] et prends l'argent au joueur [player]*)

    val remove_unit : int -> game_info -> unit
    (** [remove_unit id_unit game] retire l'unité d'id [id_unit] de la partie [game]*)

    val print_players : Player.player list -> unit
    val print_units : game_info -> unit
    val print_game : game_info -> unit

    val action_atk : game_info -> int -> int -> unit
    (** [action_atk game id_unit id_target] fait attaquer l'unité d'id [id_unit] les unités proches selon sa valeur atk_spd*)

    val action_move : game_info -> CombatUnit.combat_unit -> unit
    (** [action_move game current_unit] fait bouger l'unité [current_unit] selon sa destination définie*)

    val action : game_info -> unit 
    (** [action game] fait agir toutes les unités de la partie [game]*)

    val gold_regulator : game_info -> unit
    (** [gold_regulator game] ajoute de l'argent aux joueurs*)

    val tick : Game_interface.Game_interface.interface_config ref -> game_info -> unit
    (** [tick config game] exécute les derniers ordres chargés dans messages qui est dans [config]*)

    val random_spawning_ennemies : game_info -> unit
    (** [random_spawning_ennemies game] fait apparaitre des unités aux bords à des positions aléatoires*)

    val spawn_regulator: Game_interface.Game_interface.interface_config ref -> game_info -> unit Lwt.t
    (** [spawn_regulator config game] fait apparaitre des unités ennemies selon le spawn_rate et si la phase de préparation est finie*)

    val tick_regulator : Lib_interface.Game_interface.Game_interface.interface_config ref ->
      game_info -> float -> unit Lwt.t
    (** [tick_regulator config game time_per_tick] exécute les fonctions pour le déroulement du jeu comme l'incrémentation des ticks, exécution des ordres*)

    val run_solo : unit -> unit
    (** [run_solo ()] lance une partie solo avec une config de base*)
  end