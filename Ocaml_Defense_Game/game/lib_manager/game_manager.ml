open Lib_type.Player
open Lib_type.Pion
open Lib_type.Board
open Lib_interface.Game_interface
open Lib_message.Config_reader
open Lwt.Syntax

(* le chemin du fichier de configuration *)
let path_config = 
  let cwd = Sys.getcwd () in
  let split_root_path = Str.split (Str.regexp "/game") cwd in
  List.hd split_root_path ^ "/game/lib_manager/config_game.txt";;

(*Dictionnaire de configuration *)
let config_dict = Config_reader.parse_file path_config;;


module Game_manager  = struct
  type game_info = {
    mutable players : Player.player list;
    mutable units : CombatUnit.combat_unit list;
    mutable board : Game_board.board; 
    mutable throne : (int * int * int) list;
    (*coord*coord*id_player pour le throne*)
    (* le premier int est l'id du joueur, une liste pour les futurs types de jeu *)
  }

  (* itérateur d'id *)
  let next_id_name = ref 0;;
  (*nombre de demande de calcule par intervale tick, exprimé en ms*)
  let time_per_tick = (float_of_int (Config_reader.find_value "time_per_tick" config_dict 1000) /. 1000.);;
  (* limite de temps du jeu pour gagner, exprimé en tick *)
  (* on met un timeout de 10 minutes pour les parties solo *)
  let time_out_game = Config_reader.find_value "time_out_game" config_dict 600;;
  let standard_wall_price = Config_reader.find_value "standard_wall_price" config_dict 50;;
  (* on donne de l'argent à chaque tick*)
  let gold_per_tick = Config_reader.find_value "gold_per_tick" config_dict 100;;
  (* unité ennemie à faire apparaître tous n tick*)
  let spawn_rate = Config_reader.find_value "spawn_rate" config_dict 10;;
  (* temps avant que les unités ennemies viennent, exprimé en tick *)
  let start_to_spawn = Config_reader.find_value "start_to_spawn" config_dict 5;;
  let board_size = Config_reader.find_value "board_size" config_dict 15;;
  (* limite d'unité dans une même tile*)
  let limit_tile = Config_reader.find_value "limit_tile" config_dict 6;;

  let create_game () = {
    players = [];
    units = [];
    board = Game_board.create_board board_size board_size limit_tile; 
    throne = [];
  }

  let add_throne x y id_player game = 
    let check_throne = List.find_opt (fun (a, b, _) -> a = x && b = y) game.throne in
    if check_throne = None then
      begin
        Game_board.set_throne (ref game.board) (x, y);
        game.throne <- (x, y, id_player)::game.throne; 
        true;
      end
    else false;;
    (* else TODO MESSAGE D'ERREUR;; *)

  let remove_throne x y game =
    let check_throne = List.find_opt (fun (a, b, _) -> a = x && b = y) game.throne in
    match check_throne with
    | None -> false
    | Some (_) -> 
        begin
          Game_board.remove_throne (ref game.board) (x, y);
          game.throne <- List.filter (fun (a, b, _) -> a <> x || b <> y) game.throne;
          true;
        end;;

  let update_throne game =
    (* 
    A UTILISER SEULEMENT SI PLUSIEURS THRONES ET AVEC UNE NOUVELLE CONDITION DE FIN
    On regarde si le throne n'a pas été capturé par un autre joueur
    Il est pris seulement si il n'y a pas d'unité allié dessus et au moins une unité ennemie *)
    let rec check_units_in_throne thrones = 
      match thrones with
      | [] -> ()
      | hd::tl -> 
          let (x, y, id_player) = hd in
          let tile = Game_board.get_tile (ref game.board) x y in
          let units = Game_board.get_units tile in
          let check_ally = Array.find_opt (fun x -> x = id_player) units in
          match check_ally with
          | Some (_) -> check_units_in_throne tl
          | None -> begin 
            let check_player = Array.find_opt (fun x -> x <> id_player) units in
            let _ = match check_player with
            | None -> ()
            | Some (n) when n > 0 -> ignore (remove_throne x y game)
            | _ -> ()
            in check_units_in_throne tl;
          end;
      in check_units_in_throne game.throne;;

  let get_unit game id_unit = 
    let rec get_unit_aux id_unit units = match units with
      | [] -> failwith "Unit not found .."
      | hd::tl -> if (CombatUnit.get_id_unit hd) = id_unit then hd else get_unit_aux id_unit tl
    in get_unit_aux id_unit game.units;;

  let game_done t condition_end (config:Game_interface.interface_config ref) = 
    let (tx, ty, _) = List.hd t.throne in
    let units_in_throne = Array.to_list (Game_board.get_units (Game_board.get_tile (ref t.board) tx ty)) in
    let clean = List.filter (fun x -> x >= 0 ) units_in_throne in
    let r = List.length clean > 0 in
    let* cond_res = condition_end config in
    let result = r || cond_res in 
    if result then 
      let* _ = Game_interface.game_end_state config in 
      Lwt.return ()
    else Lwt.return();;

  let condition_end_timeout config : bool Lwt.t =
    let* tick_cpt = Game_interface.read_tick config in
    if (*!*)tick_cpt >= time_out_game then Lwt.return true
    else Lwt.return false;;

  let get_player id_player game = 
    let rec get_player_aux id_player players = match players with
      | [] -> failwith "Player not found"
      | hd::tl -> if (Player.get_id hd) = id_player then hd else get_player_aux id_player tl
    in get_player_aux id_player game.players;;

  let get_unit_opt game id_unit = 
    try Some (get_unit game id_unit) with _ -> None;;

  let add_player player_role game = 
    let id_player = !next_id_name in
    next_id_name := !next_id_name + 1;
    let new_p = Player.create_player ("player"^(string_of_int id_player)) player_role in
    game.players <- new_p::game.players;;

  let remove_player id_player game = 
    let rec remove_player_aux id_player players = match players with
      | [] -> failwith "Player not found"
      | hd::tl -> if (Player.get_id hd) = id_player then tl else hd::(remove_player_aux id_player tl)
    in game.players <- remove_player_aux id_player game.players;;
  
  let add_unit coords id_player type_unit game = 
    let player = get_player id_player game in
    let unit_class = CombatUnit.create_unit_class type_unit in
    let new_unit = CombatUnit.create_combat_unit coords id_player unit_class (CombatUnit.create_base_stat unit_class) in
    if id_player = 0 then
      begin
        let (tx,ty, _) = List.hd game.throne in
        CombatUnit.set_target_coords new_unit (tx, ty);
        CombatUnit.move_state new_unit;
        let (x, y) = CombatUnit.get_coords new_unit in 
        let path = Game_board._find_path x y tx ty (ref game.board) in
        CombatUnit.set_path new_unit path;
      end;
    game.units <- new_unit::game.units;
    Game_board.add_unit_tile (ref game.board) coords (CombatUnit.get_id_unit new_unit) ;
    Player.add_unit player (CombatUnit.get_id_unit new_unit);
  ;;

  let standard_unit_price type_unit = 
    match type_unit with
    | "Knight" -> 100
    | "Archer" -> 150
    | "Mage" -> 200
    | _ -> 0;;

  let buying price player = 
    let current_gold = Player.get_gold player in
    if current_gold < price then 
      begin
        (* AJOUTER UN MESSAGE DE RETOUR POUR L'INTERFACE DU JOUEUR *)
        print_endline "Not enough gold to buy unit.";
        false;
      end
    else
    true;;
  
  let buy_unit coords id_player type_unit game pos_x pos_y =
    let player = get_player id_player game in
    let unit_class = CombatUnit.create_unit_class type_unit in
    let price = standard_unit_price type_unit in
    if buying price player then
      let new_unit = CombatUnit.create_combat_unit 
                        coords 
                        id_player 
                        unit_class 
                        (CombatUnit.create_base_stat unit_class) in
      try
    
        Game_board.add_unit_tile (ref game.board) (pos_x, pos_y) (CombatUnit.get_id_unit new_unit) ;
        game.units <- new_unit::game.units;
        Player.add_unit player (CombatUnit.get_id_unit new_unit);
        Player.set_gold player ((Player.get_gold player) - price);
        print_endline "Unit successfully bought and added."
      with _ ->
        (* AJOUTER UN MESSAGE DE RETOUR POUR L'INTERFACE DU JOUEUR *)
        print_endline "Failed to buy and add unit."
    ;;

let buy_wall player game pos_x pos_y =
  let price = standard_wall_price in
  let (xt,yt,_) = List.hd game.throne in
  if buying price player && Game_board.can_build_wall ( ref game.board) (pos_x,pos_y) then
      let prev = Game_board.get_type_tile (ref game.board) pos_x pos_y in
      Game_board.build_wall (ref game.board) pos_x pos_y;
      if (Game_board.is_board_connex (ref game.board) (xt,yt)) then
        Player.set_gold player ((Player.get_gold player) - price)
      else
        Game_board.set_type_tile (ref game.board) pos_x pos_y prev
      (* TODO: AJOUTER UN MESSAGE DE RETOUR POUR L'INTERFACE DU JOUEUR *)
  else
    print_endline "Failed to buy and add wall.";;
    

  let remove_unit id_unit game = 
    let rec remove_unit_aux id_unit units acc = match units with
    | [] -> failwith "Unit not found"
    | hd::tl -> if CombatUnit.get_id_unit hd = id_unit then (hd, acc @ tl) 
                else remove_unit_aux id_unit tl (hd :: acc)
      in
      let (removed_unit, remaining_units) = remove_unit_aux id_unit game.units [] 
    in
    game.units <- remaining_units;
    let curr_p = get_player (CombatUnit.get_id_player removed_unit) game in
    Game_board.remove_unit_tile (ref game.board) (CombatUnit.get_coords removed_unit) id_unit;
    Player.remove_unit curr_p id_unit;;


  let rec print_players = function
| [] -> ()
| hd::tl -> Player.print_player hd; print_players tl;;

  let print_units game = 
    let rec print_units_aux units = match units with
      | [] -> ()
      | hd::tl -> CombatUnit.print_unit hd; print_units_aux tl
    in print_units_aux game.units;;

  let print_game game = 
    Printf.printf "Players : ";
    print_int (List.length game.players);
    print_endline "\n";
    print_players game.players;
    print_newline ();
    Printf.printf "Units : ";
    print_int (List.length game.units);
    print_endline "\n";
    print_units game;
    print_newline ();;

  module Prio_unit = struct
    module M = Map.Make (
      struct
      type t = int
      let compare = compare
    end)
    
    type 'a t = 'a M.t
    
    let empty = M.empty
    
    let is_empty = M.is_empty
    
    let add file k e =
        if M.mem k file
        then M.add k (List.append (M.find k file) [e]) file
        else M.add k [e] file
    
    let pop_smallest file =
        let (k,v) = M.min_binding file in
        if  List.compare_length_with (List.tl v) 0 = 0  then (k, List.hd v, M.remove k file) (*List.empty ne marche pas ..?*)
        else (k, List.hd v, M.add k (List.tl v) file)
  end

  let action_atk game id_unit atk_spd = 
    if get_unit_opt game id_unit = None then () else
    let current_unit = get_unit game id_unit in
    let player_id = CombatUnit.get_id_player current_unit in

    let get_enemies_in_range : Game_board.board ref -> int*int -> int -> 'a Prio_unit.t = fun board (x,y) range ->
      let (near_coord : Game_board.Set_coord.t) = Game_board.get_coord_in_range x y range (Game_board.get_board_height board) (Game_board.get_board_width board) in 
      let rec get_enemies : CombatUnit.combat_unit list -> Game_board.Set_coord.t -> CombatUnit.combat_unit list = fun list_e near_coord ->
        match Game_board.Set_coord.choose_opt near_coord with
        | None -> print_endline "None"; list_e
        | Some (xi,yi) -> 
          print_endline "Some";
          let inter = Array.to_list (Game_board.get_units (Game_board.get_tile board xi yi)) in
          print_endline "test1";
          List.iter (fun i -> Printf.printf "id(%d) " i) inter;
          let (l_inter : CombatUnit.combat_unit list) = 
            List.map (function | Some x -> x | None -> failwith "wtf")
            (List.filter (function | Some _ -> true | None -> false)
            (List.map (fun id -> get_unit_opt game id) inter))
          in
          let (l : CombatUnit.combat_unit list) =  List.filter 
            (fun u -> (CombatUnit.get_id_player u != player_id) && (Game_board.get_visibility (ref game.board) xi yi)) 
            l_inter
          in
          get_enemies (List.append list_e l) (Game_board.Set_coord.remove (xi,yi) near_coord)
      in
      let rec find_prio_target : 'a Prio_unit.t -> CombatUnit.combat_unit list -> 'a Prio_unit.t = fun prio_target list_e -> 
        match list_e with 
        | [] -> prio_target
        | x::t -> find_prio_target (Prio_unit.add prio_target (Game_board.weight_path (CombatUnit.get_path x) (ref game.board)) x) t
      in      
      find_prio_target Prio_unit.empty (get_enemies [] near_coord)
    in

    let prio_target = get_enemies_in_range (ref game.board) (CombatUnit.get_coords current_unit) (CombatUnit.get_range current_unit)in

    print_string "id unit : ";
    print_int id_unit;
    (*print_string " all targets : ";
    Prio_file.print prio_target;*)
    
    print_endline "before attacking";

    let rec attacking prio_targets current_unit atk_spd = 
      if not (Prio_unit.is_empty prio_targets) then
        let _, (target : CombatUnit.combat_unit), (next_prio_target : 'a Prio_unit.t) = Prio_unit.pop_smallest prio_targets in
        match atk_spd with
        | 0 -> ()
        | _ -> 
            begin
              CombatUnit.attack current_unit target;
              print_string "\nattacker : ";
              print_int (CombatUnit.get_id_player current_unit);
              print_string "\ntarget : ";
              print_int (CombatUnit.get_id_player target);
              print_string "hp left : ";
              print_int (CombatUnit.get_hp_current target);
              if (CombatUnit.get_hp_current target) <= 0 then 
                begin
                remove_unit (CombatUnit.get_id_unit target) game;
                attacking next_prio_target current_unit (atk_spd - 1);
                end
              else attacking prio_targets current_unit (atk_spd - 1);
            end
    in

    attacking prio_target current_unit atk_spd;;

  (* let nearest_point game origin_coord dest_coord range =
    let dist_squared (x1, y1) (x2, y2) =
      let dx = x2 - x1 in
      let dy = y2 - y1 in
      dx * dx + dy * dy
    in
    let rec find_nearest_point candidate_coords =
      match candidate_coords with
      | [] -> (-1, -1)
      | coord :: tl ->
          if Game_board.can_move_to (ref game.board) coord then coord
          else find_nearest_point tl
    in
    let rec find_closest_point x y closest_point min_dist =
      if x > range then find_closest_point (-range) (y + 1) closest_point min_dist
      else if y > range then closest_point
      else
        let new_coord = (fst origin_coord + x, snd origin_coord + y) in
        let new_dist_squared = dist_squared new_coord dest_coord in
        if new_dist_squared <= min_dist then
          let new_closest_point =
            if new_dist_squared < min_dist then new_coord
            else closest_point
          in
          find_closest_point (x + 1) y new_closest_point new_dist_squared
        else
          find_closest_point (x + 1) y closest_point min_dist
    in
    let closest_point =
      find_closest_point (-range) (-range) origin_coord (dist_squared origin_coord dest_coord)
    in
    find_nearest_point [closest_point] *)

  let action_move game curr_unit  = 
    let rec sub_path n list acc = 
      if n = 0 then (acc, list)
      else match list with
      | [] -> (acc, list)
      | hd::tl -> sub_path (n-1) tl (hd::acc)
    in 
    let next_moves = sub_path (CombatUnit.get_mv_spd curr_unit) (CombatUnit.get_path curr_unit) [] in
    let rec best_move list = 
      match list with
      | [] -> ((-1,-1), [])
      | hd::tl -> 
          if Game_board.can_move_to (ref game.board) hd then (hd,tl)
          else best_move tl
    in let r = best_move (fst next_moves) in
    if r = ((-1,-1), []) then 
      begin
        CombatUnit.defend_state curr_unit;
        print_endline "stopped moving";
      end
    else
    match fst r with
    | (-1, -1) -> ()
    | k -> 
        let (x, y) = CombatUnit.get_coords curr_unit in
        ignore(Game_board.move_unit (ref game.board) (x, y) (k) (CombatUnit.get_id_unit curr_unit));
        CombatUnit.set_coords curr_unit k;
        CombatUnit.set_path curr_unit (snd next_moves);;


    
(* 
--TODO quand on construit un mur il faut vérifier que :
--le graphe est connexe,
--recalculer tous les chemin qui contentais la case ou le mur a ete construit   *)

    
  let action game = 
    print_endline "start action";
    let units = game.units in
    let action_unit current_unit =
      let atk_spd = (CombatUnit.get_atk_spd current_unit) in
      let aux current_unit atk_spd= 
        match CombatUnit.get_action_state current_unit with
        | Defending -> action_atk game (CombatUnit.get_id_unit current_unit) atk_spd
        (*TODO: SI IA: ARRETER DE BOUGER SI ENNEMI SUR LA MEME CASE*)
        | Moving -> action_move game current_unit;
        | _ -> ();
      in aux current_unit atk_spd;
    in List.iter action_unit units;;
        
  open Lib_message.Game_message
  open Lib_interface.Interface_info

  let gold_regulator game = 
    let players = game.players in
    let rec gold_regulator_aux players = 
      match players with
      | [] -> ()
      | hd::tl -> 
          let gold = Player.get_gold hd in
          print_string "\nGold : ";
          print_int (gold);
          Player.set_gold hd (gold + gold_per_tick);
          gold_regulator_aux tl;
    in gold_regulator_aux players;;

  let tick config (game:game_info) =
    let rec read_message messages game = 
      match messages with
      | [] -> ()
      | hd::tl -> 
          let current_player = List.hd game.players in
          (* LE JOUEUR 1 EST TOUJOURS LE JOUEUR CONTROLABLE EN SOLO*)
          let units = Game_message.get_units_id hd in
          let dest = Game_message.get_tiles hd in
          begin
            match Game_message.get_order hd with
            | Move -> 
                List.iter (fun x -> 
                  let curr_unit = get_unit game x in 
                  let unit_player_id = CombatUnit.get_id_player curr_unit in
                  if Player.get_id current_player = unit_player_id then
                    begin
                      let coords = List.hd dest in 
                      CombatUnit.set_target_coords curr_unit (coords);
                      CombatUnit.move_state curr_unit;
                      let (x, y) = CombatUnit.get_coords curr_unit in 
                      let path = Game_board._find_path x y (fst coords) (snd coords) (ref game.board) in
                      CombatUnit.set_path curr_unit path;
                    end
                  ) units;
                read_message tl game;
            | Build -> 
              List.iter (
                fun (x,y) ->
                  buy_wall current_player game x y
              ) dest 
              (* if is_board_connex board 
              then let add_brick (x, y) = Game_board.set_type_tile (ref game.board) (x, y) Brick in
              List.iter add_brick dest; *)
            | RecruitArcher 
            | RecruitKnight
            | RecruitMage -> 
                let unit_type = match Game_message.get_order hd with
                | RecruitArcher -> "Archer"
                | RecruitKnight -> "Knight"
                | RecruitMage -> "Mage"
                | _ -> ""
                in
                let (x, y) = List.hd dest in
                let player_id = Player.get_id current_player in
                let _ = buy_unit (x, y) player_id unit_type game x y in
                read_message tl game;
            | _ -> read_message tl game;
          end
        in let messages = ref [] in
        let _ = Game_interface.get_messages config messages in 
        if !messages <> [] then
        read_message !messages game;; 
        
  let random_spawning_ennemies game = 
    let width = Game_board.get_board_width (ref game.board) in
    let height = Game_board.get_board_height (ref game.board) in
    let rec random_spawning_ennemies_aux game = 
      let border = Random.int 4 in
      (* 0 - seulement la bordure du haut
      1 - seulement la bordure de droite
      2 - seulement la bordure du bas
      3 - seulement la bordure de gauche *)
      let (x, y) = match border with
      | 0 -> (Random.int width, 0)
      | 1 -> (width - 1, Random.int height)
      | 2 -> (Random.int width, height - 1)
      | 3 -> (0, Random.int height)
      | _ -> (0, 0)
      in
      let unit = match (Random.int 3) with
      | 0 -> "Knight"
      | 1 -> "Archer"
      | _ -> "Mage"
      in
      if Game_board.can_move_to (ref game.board) (x, y) then
        begin
          add_unit (x, y) (Player.get_id (List.hd (List.tl game.players))) unit game;

        end
      else random_spawning_ennemies_aux game;
    in
    random_spawning_ennemies_aux game;;
    (*
    module Tree_ia = Map.Make (struct
      type t = int * int * int
      let compare (n1,x1,y1) (n2,x2,y2) = (
        if n1 > n2 then 1
        else if n1 < n2 then -1
        else if x1 > x2 then 1
        else if x1 < x2 then -1
        else if y1 > y2 then 1
        else if y1 < y2 then -1
        else 0
        )
    end)

    
  let tree_spawn game =
    (*let game_cp = todo faire la fonction de copiein*)
    let board = game.board in
    let (_,_,id_ia) = List.hd game.throne in

    let rec aux n (prev_x,prev_y) prev_l_u t =
      let width = Game_board.get_board_width (ref board) -1 in
      let height = Game_board.get_board_height (ref board) -1 in
      let board_c = () in
      let rec next list x y= 
        match y with 
        | 0 -> if x=width then next (List.append list [(x,y)]) 0 (y+1) else next (List.append list [(x,y)]) (x+1) y
        | _ when y=height -> if x=width then (List.append list [(x,y)]) else next (List.append list [(x,y)]) (x+1) height
        | _ ->  next (List.append list [(0,y);(width,y)]) 0 (y+1)
      in
      let get_dist_to_throne l_u board = List.hd 
                                          (List.sort 
                                            (fun a b -> (Game_board.weight_path (CombatUnit.get_path a) board) - (Game_board.weight_path (CombatUnit.get_path b) board))

                                            (List.filter 
                                              (fun u -> (CombatUnit.get_id_player u) = id_ia)
                                              l_u
                                            )
                                          ) 
    in

      let rec add_to_tree t l = 
        match l with
        | [] -> t
        | (x,y)::r ->
          add_to_tree 
            (Tree_ia.add
              ((n,x,y), get_dist_to_throne (List.add prev_l_u [] ) board)
              (n-1,prev_x,prev_y, get_units)
              t
            ) 
            r
      in

      if n<5 then (*5 est la hauteur de l'arbre -> on joue en voyant 5 coup a l'avance*)
        let rec dfs list t =
          match list with 
          | [] -> t
          | x::r -> dfs r (aux (n+1) x prev_l_u) (*jouer un tick et ajouter l'unite*) 
        in
        dfs (next prev_l_u x y) t
      else
        add_to_tree t (next prev_l_u x y)
    in
    aux 0 (-1,-1) game.units Tree_ia.empty
    (*a faire a chaque tic : 
        action game;
        *)

(*
      let new_unit = CombatUnit.create_combat_unit 
                        coords 
                        id_player 
                        unit_class 
                        (CombatUnit.create_base_stat unit_class) in
      try
    
        Game_board.add_unit_tile (ref game.board) (pos_x, pos_y) (CombatUnit.get_id_unit new_unit) ;
        game.units <- new_unit::game.units;
        Player.add_unit player (CombatUnit.get_id_unit new_unit);
        Player.set_gold player ((Player.get_gold player) - price);
        print_endline "Unit successfully bought and added."
      with _ ->
        (* AJOUTER UN MESSAGE DE RETOUR POUR L'INTERFACE DU JOUEUR *)
        print_endline "Failed to buy and add unit."   
*)
  let gess_best_spawn = Map.min_binding (tree_spawn game n (prev_x,prev_y)) 
*)
  

  let spawn_regulator (config:Game_interface.interface_config ref) game =
    let* tick = Game_interface.read_tick config in
    if tick <> 0 && tick > start_to_spawn then begin
      if tick mod spawn_rate = 0 then
        begin 
          random_spawning_ennemies game;
          Lwt.return ()
        end
      else Lwt.return ()
    end
  else Lwt.return();;

  
  open Lwt;;
  (*FONCTION EXCLUSIVE POUR LE SOLO*)
  let rec tick_regulator config game time_per_tick =
    
    let state = Game_interface.get_state config in
    if state = DISCONNECTED then Lwt.return ()
    else if state = GAME then
      begin
        ignore(Game_interface.add_tick config);
        tick config game;
        Game_board.update_vision (ref game.board) (List.filter ( fun u -> let (_,_,i) = List.hd game.throne in (CombatUnit.get_id_player u) = i) game.units);
        action game;
        gold_regulator game;
        let* _ = spawn_regulator config game in
        let board = Info_to_interface.convert_board game.units (ref game.board) game.players in
        ignore(Game_interface.update_info config board);
        update_throne game;
        let* _ = game_done game condition_end_timeout config in
        if Game_interface.get_state config = GAME_END then tick_regulator config game time_per_tick
        else
        (Lwt_unix.sleep (time_per_tick) >>= fun () ->
        tick_regulator config game time_per_tick)
    end
    else 
      Lwt_unix.sleep 1. >>= fun () ->
      tick_regulator config game time_per_tick;;

  
  let run_solo () = begin 
    print_endline "Running solo";
    let game = create_game () in
    let role_def = Player.create_role "defender" in
    let role_atk = Player.create_role "attacker" in
    add_player role_atk game;
    add_player role_def game;
    let players = game.players in
    (* PAR LA REGLE AU DEBUT, EN SOLO LE JOUEUR 1 EST CELUI QU'ON CONTROLE *)
    let controled_player = List.hd players in
    let _ = List.hd (List.tl players) in
    
    add_unit (6,6) (Player.get_id controled_player) "Knight" game;
    (*add_unit (4,9) (Player.get_id computer_player) "Knight" game;*)
    (* add_unit (0,0) (Player.get_id controled_player) "Mage" game; *)
    ignore(add_throne 7 7 (Player.get_id controled_player) game);
    let _ = Game_board.build_procedural_1D 
              (ref game.board)
              (Game_board.string_to_type_tile "Road")  
              board_size
              7. in


    (* add_unit (5,9) (Player.get_id controled_player) "Knight" game; *)
    (* add_unit (3,9) (Player.get_id computer_player) "Knight" game; *)
    (* add_unit (0,0) (Player.get_id controled_player) "Mage" game; *)
    (* print_endline (string_of_int (List.length game.throne)); *)
    
  let board = Info_to_interface.convert_board game.units (ref game.board) game.players in
  let gui_config = ref (Game_interface.create_config (Player.get_id controled_player)) in 
  let _ = 
    Game_interface.update_info gui_config board 
  in
  let thread_game_manager =(tick_regulator gui_config game time_per_tick) in
  let thread_interface =  (Game_interface.run gui_config) in 
  Lwt_main.run (Lwt.join [thread_game_manager; thread_interface])


    
  end;;



end
