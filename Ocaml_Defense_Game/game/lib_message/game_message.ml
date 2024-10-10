module Game_message = struct 
  type order = Move | Attack | Build | RecruitArcher | RecruitKnight | RecruitMage | Quit 

  type message = {
    order : order;
    player_id : int;
    tiles : (int * int) list;
    units_id : int list;
  }

  let order_of_string = function
    | "Move" -> Move
    | "Attack" -> Attack
    | "Build" -> Build
    | "RecruitKnight" -> RecruitKnight
    | "RecruitMage" -> RecruitMage
    | "RecruitArcher" -> RecruitArcher
    | "Quit" -> Quit
    | _ -> failwith "Invalid order string"
  let create_order ord = order_of_string ord;;

  let create_message ord player_id tiles u_ids = {
    order = create_order ord;
    player_id;
    tiles;
    units_id = u_ids;
  }

  let order_to_string = function
    | Move -> "Move"
    | Attack -> "Attack"
    | Build -> "Build"
    | RecruitArcher -> "RecruitArcher"
    | RecruitKnight -> "RecruitKnight"
    | RecruitMage -> "RecruitMage"
    | Quit -> "Quit"

  

  let message_to_json msg =
    `Assoc [
      "order", `String (order_to_string msg.order);
      "player_id", `Int msg.player_id;
      "tiles", `List (List.map (fun (x, y) -> `List [`Int x; `Int y]) msg.tiles);
      "units_id", `List (List.map (fun id -> `Int id) msg.units_id)
    ]

  let json_to_message json =
    match json with
    | `Assoc fields ->
      let order = List.assoc "order" fields |> function `String s -> order_of_string s | _ -> failwith "Invalid JSON format for order" in
      let player_id = List.assoc "player_id" fields |> function `Int i -> i | _ -> failwith "Invalid JSON format for player_id" in
      let tiles = List.assoc "tiles" fields |> function `List ts -> List.map (function `List [`Int x; `Int y] -> (x, y) | _ -> failwith "Invalid JSON format for tiles") ts | _ -> failwith "Invalid JSON format for tiles" in
      let units_id = List.assoc "units_id" fields |> function `List ids -> List.map (function `Int id -> id | _ -> failwith "Invalid JSON format for units_id") ids | _ -> failwith "Invalid JSON format for units_id" in
      { order; player_id; tiles; units_id }
    | _ -> failwith "Invalid JSON format for message"

  let message_to_string msg =
    message_to_json msg |> Yojson.Basic.to_string

  let string_to_message str =
    Yojson.Basic.from_string str |> json_to_message

  let get_order msg = msg.order
  let get_player_id msg = msg.player_id
  let get_tiles msg = msg.tiles
  let get_units_id msg = msg.units_id
  
end;;

