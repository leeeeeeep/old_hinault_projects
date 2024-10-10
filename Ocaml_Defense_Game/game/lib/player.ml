
module Player = struct
  type role = Attacker | Defender

  type player = {
    name : string;
    mutable score : int;
    mutable gold : int;
    id : int;
    role : role;
    mutable units : int list;
  }

  let next_id = ref 0

  let create_player name role = 
    let id = !next_id in
    next_id := !next_id + 1;
    { name; score = 0; id; role = role; gold = 0; units = [] }

  let create_role = function
    | "attacker" -> Attacker
    | "defender" -> Defender
    | _ -> failwith "Invalid role"
  
  let get_name p = p.name
  let get_score p = p.score
  let get_gold p = p.gold
  let get_id p = p.id
  let get_units p = p.units
  let set_gold p g = p.gold <- g
  let add_score p s = p.score <- p.score + s
  let add_unit p u = p.units <- u :: p.units
  let remove_unit p u = p.units <- List.filter (fun x -> x <> u) p.units
  let get_role p = p.role
  let string_of_role = function
    | Attacker -> "attacker"
    | Defender -> "defender"
  let print_player p = 
    Printf.printf "id: %s Name: %s Role: %s Score: %d Units:%s\n"
      (string_of_int p.id) p.name (string_of_role p.role) p.score (List.fold_left (fun acc x -> acc ^ " " ^ string_of_int x) " " p.units);;

end