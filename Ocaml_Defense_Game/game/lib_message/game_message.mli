module Game_message : sig
    type order = Move | Attack | Build | RecruitArcher | RecruitKnight | RecruitMage | Quit

    type message
    
    val create_order : string -> order
    (** [create_order ord] crée une valeur de type [order] à partir d'une chaîne de caractères. *)
    
    val create_message :
      string -> int -> (int * int) list -> int list -> message
    (** [create_message ord player_id tiles u_ids] crée un message à partir des données fournies. *)
    
    val order_to_string : order -> string
    (** [order_to_string ord] convertit une valeur de type [order] en une chaîne de caractères. *)
    
    val order_of_string : string -> order
    (** [order_of_string s] convertit une chaîne de caractères en une valeur de type [order]. *)
    
    val message_to_json : message ->
                                    [> `Assoc of
                                        (string *
                                        [> `Int of int
                                        | `List of [> `Int of int | `List of [> `Int of int ] list ] list
                                        | `String of string ])
                                        list ]
    (** [message_to_json msg] convertit un message en une valeur JSON. *)
    
    val json_to_message : [> `Assoc of
                            (string *
                            [> `Int of int
                            | `List of [> `Int of int | `List of [> `Int of int ] list ] list
                            | `String of string ])
                            list ] ->
                        message
    (** [json_to_message json] convertit une valeur JSON en un message. *)
    
    val message_to_string : message -> string
    (** [message_to_string msg] convertit un message en une chaîne de caractères JSON. *)
    
    val string_to_message : string -> message
    (** [string_to_message str] convertit une chaîne de caractères JSON en un message. *)

    val get_order : message -> order
    (** [get_order msg] retourne l'ordre contenu dans le message. *)

    val get_player_id : message -> int
    (** [get_player_id msg] retourne l'identifiant du joueur contenu dans le message. *)

    val get_tiles : message -> (int * int) list
    (** [get_tiles msg] retourne la liste des coordonnées des tuiles contenues dans le message. *)

    val get_units_id : message -> int list
    (** [get_units_id msg] retourne la liste des identifiants des unités contenues dans le message. *)

    
end