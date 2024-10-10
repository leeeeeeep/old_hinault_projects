module Player : sig
    type role
    type player
  
    val create_player : string -> role -> player
    val create_role : string -> role
    val get_name : player -> string
    val get_score : player -> int
    val get_gold : player -> int
    val get_id : player -> int
    val get_units : player -> int list
    val set_gold: player -> int -> unit
    val add_score : player -> int -> unit
    val add_unit : player -> int -> unit
    val remove_unit : player -> int -> unit
    val get_role : player -> role
    val string_of_role : role -> string
    val print_player : player -> unit
end