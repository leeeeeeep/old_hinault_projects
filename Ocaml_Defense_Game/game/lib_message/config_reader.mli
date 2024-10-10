module Config_reader:
sig 

    (** [parse_file filename] lit un fichier de configuration et retourne un dictionnaire des valeurs lues. *)
val parse_file : string -> (string, int) Hashtbl.t

(** [find_value key dict default_value] recherche une valeur associée à une clé dans le dictionnaire [dict].
    Si la clé n'est pas trouvée, la valeur par défaut [default_value] est retournée. *)
val find_value : string -> (string, int) Hashtbl.t -> int -> int

end 