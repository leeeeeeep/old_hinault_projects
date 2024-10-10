open Lib_type.Board
open Lib_type.Pion
open Lib_type.Player

module Info_to_interface = struct 

  
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

  let create_empty_message () = {
    width = 0;
    height = 0;
    tiles = [||];
    players_info = [];
  }

  let get_visibility tile = tile.visibility
  let get_type_tile tile = tile.type_tile
  let get_visible_units tile = tile.visible_unit_info
  let get_visible_unit_info tile id =
    let rec get_visible_unit_message_by_id (list:visible_unit_info list) id =
      match list with
      | [] -> failwith "No unit with this id"
      | h::t -> if h.id = id then h else get_visible_unit_message_by_id t id
    in get_visible_unit_message_by_id tile.visible_unit_info id
  
  let belongs_to_player visible_unit_info player_id =
    visible_unit_info.player_id = player_id
  let get_unit_class visible_unit_info = visible_unit_info.unit_class
  let get_health visible_unit_info = visible_unit_info.health
  let get_max_health visible_unit_info = visible_unit_info.max_health
  let get_id (visible_unit_info: visible_unit_info) = visible_unit_info.id
  (* let get_id_player visible_unit_info = visible_unit_info.player_id *)
  let get_id_player_from_unit_info visible_unit_info = visible_unit_info.player_id
  let get_name player_info = player_info.name
  let get_gold player_info = player_info.gold
  let get_score player_info = player_info.score
  let get_id_player player_info = player_info.id
  
  let get_players_info id message =
    List.find_opt (fun x -> x.id = id) message.players_info
  
  let get_tiles message = message.tiles
  let get_tile x y message = message.tiles.(x).(y)
  let get_width message = message.width
  let get_height message = message.height

  let get_player_units_from_coords message id_player coords =
    let x, y = coords in
    if x < 0 || y < 0 || x >= message.width || y >= message.height then
      failwith "Coordinates out of bounds"
    else
      let tile = get_tile x y message in
      let units_on_tile = List.filter (fun unit_info -> belongs_to_player unit_info id_player) (get_visible_units tile) in
      List.map get_id units_on_tile


  let convert_tile (all_units:CombatUnit.combat_unit list) gb_tile =
    let type_tile_str = match (Game_board.get_type_tile_by_tile gb_tile) with
      | Empty -> "Empty"
      | Brick -> "Brick"
      | Grass -> "Grass"
      | Water -> "Water"
      | Throne -> "Throne"
      | Road -> "Road"
      | Forest -> "Forest"
      | Mountain -> "Mountain"
    in
    let visible_units =
      if gb_tile.visibility then
        (* let visible_units_id = List.filter (fun id -> id <> -1) (Array.to_list (Game_board.get_units gb_tile)) in 
        let _ = List.map (print_int) visible_units_id in *)
        List.map (fun id ->
          let current_unit = List.find (fun u -> CombatUnit.get_id_unit u = id) all_units in
          {
            id = CombatUnit.get_id_unit current_unit;
            player_id = CombatUnit.get_id_player current_unit;
            unit_class = CombatUnit.u_class_str current_unit;
            health = CombatUnit.get_hp_current current_unit;
            max_health = CombatUnit.get_hp_max current_unit;
          }
        ) (List.filter (fun id -> id <> -1) (Array.to_list (Game_board.get_units gb_tile)))
        
      else []
    in
    {
      type_tile = type_tile_str;
      visibility = gb_tile.visibility;
      visible_unit_info = visible_units;
    }

  let convert_players (players:Player.player list) =
    List.map (fun p ->
      {
        id = Player.get_id p;
        name = Player.get_name p;
        gold = Player.get_gold p;
        score = Player.get_score p;
      }
    ) players
  
  let convert_board (all_units:CombatUnit.combat_unit list) gb_board players =
    let width = Game_board.get_board_width gb_board in
    let height = Game_board.get_board_height gb_board in
    let tiles = Array.init width (fun x ->
      Array.init height (fun y -> convert_tile all_units (Game_board.get_tile gb_board x y))
    ) in
    {
      width = width;
      height = height;
      tiles = tiles;
      players_info = convert_players players;
    }
end;;