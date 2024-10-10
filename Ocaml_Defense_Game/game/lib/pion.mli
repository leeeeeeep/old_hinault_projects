module CombatUnit : sig
    type stat 
  
    type unit_class = Mage | Knight | Archer

    type unit_action_state = Defending | Attacking | Moving
  
    type combat_unit

    val attack : combat_unit -> combat_unit -> unit
  
    val create_stat : int -> int -> int -> int -> int -> int -> stat
    val create_base_stat : unit_class -> stat
    val create_unit_class : string -> unit_class
    val create_combat_unit : int*int -> int -> unit_class -> stat -> combat_unit

  
    val get_id_unit : combat_unit -> int
    val get_id_player : combat_unit -> int
    val get_unit_class : combat_unit -> unit_class
    val get_stat : combat_unit -> stat
    val get_hp_current : combat_unit -> int
    val get_hp_max : combat_unit -> int
    val get_atk_spd : combat_unit -> int
    val get_mv_spd : combat_unit -> int
    val get_view_range : combat_unit -> int
    val get_coords : combat_unit -> int*int
    val get_target_coords : combat_unit -> int*int
    val get_range : combat_unit -> int
    val get_action_state : combat_unit -> unit_action_state
    val get_path : combat_unit -> ((int*int)) list
    val set_path : combat_unit -> ((int*int)) list -> unit
    val set_hp_current : combat_unit -> int -> unit
    val set_coords : combat_unit -> int*int -> unit
    val set_stat : combat_unit -> stat -> unit
    val set_target_coords : combat_unit -> int*int -> unit
    val move_state : combat_unit -> unit
    val attack_state : combat_unit -> unit
    val defend_state : combat_unit -> unit

    val u_class_str : combat_unit -> string
  
    val print_unit : combat_unit -> unit
  end
  