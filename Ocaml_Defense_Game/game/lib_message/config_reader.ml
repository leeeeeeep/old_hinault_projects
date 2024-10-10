
(* open Hashtbl *)

module Config_reader =
struct 

  let parse_file filename =
    let channel = open_in filename in
    let dict = Hashtbl.create 10 in (* Crée un dictionnaire vide *)
    (* entrée de la forme key: value; *)
    let regex = Str.regexp "^\\([^:]+\\):[ \t]*\\([0-9]+\\)[ \t]*;$" in
    (* let regex = Str.regexp "\\([^:]+\\):[[:space:]]*\\([0-9]+\\)[[:space:]]*;" in *)
    try
      while true do
        let line = input_line channel in
        if Str.string_match regex line 0 then (
          let key = Str.matched_group 1 line in
          let value = int_of_string (Str.matched_group 2 line) in
          print_string key;
          print_string " ";
          print_int value;
          print_newline ();
          Hashtbl.add dict key value
        )
      done;
      dict
    with End_of_file ->
      close_in channel;
      dict;;

  let find_value key dict default_value =
    try
      (Hashtbl.find dict key)
    with Not_found ->
      default_value

end