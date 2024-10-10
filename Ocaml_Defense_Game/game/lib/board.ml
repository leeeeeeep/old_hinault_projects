module Game_board = struct
  
  type type_tile =
    | Empty
    | Brick
    | Grass
    | Water
    | Throne
    | Road
    | Forest
    | Mountain

  type tile = {
    mutable type_tile : type_tile;
    mutable visibility : bool;
    mutable units : int array ref;
  }

  type board = {
    width : int;
    height : int;
    mutable tiles : tile array array ref;
  }

  let create_tile tile size_pion = {
    type_tile = tile;
    visibility = true;
    units = ref (Array.make size_pion (-1));
  }

  let create_board width height size_pion =
    let create_tiles_row () =
      Array.init height (fun _ -> create_tile Grass size_pion)
    in
    let tiles =
      Array.init width (fun _ -> create_tiles_row ())
    in
    { width = width; height = height; tiles = ref tiles }

  let string_to_type_tile = function
    | "Grass" -> Grass
    | "Mountain" -> Mountain
    | "Forest" -> Forest
    | "Water" -> Water
    | "Road" -> Road
    | "Brick" -> Brick
    | "Throne" -> Throne
    | "Empty" -> Empty
    | _ -> failwith "Invalid type_tile"

  let get_tiles board = Array.map Array.copy !(!board.tiles)
  let get_tile board x y = !(!board.tiles).(x).(y)
  let set_tile board x y tile = !(!board.tiles).(x).(y) <- tile
  let get_type_tile board x y = (get_tile board x y).type_tile
  let set_type_tile board x y t = (get_tile board x y).type_tile <- t
  let build_wall board x y = (get_tile board x y).type_tile <- Brick
  let get_type_tile_by_tile tile = tile.type_tile
  let get_visibility board x y = (get_tile board x y).visibility
  let set_visibility board x y b = (get_tile board x y).visibility <- b
  let get_units tile = Array.copy !(tile.units)
  let get_board_width board = !board.width
  let get_board_height board = !board.height

  let get_units_from_zone board (coord: (int*int)) radius=
    (* let start_x = max 0 (fst coord - radius) in *)
    let start_x = if (fst coord - radius) > 0 
      then (fst coord - radius) 
      else 0 in
    (* let end_x = min (get_board_width board - 1) (fst coord + radius) in  *)
    
        let end_y = if (snd coord + radius) < (get_board_width board - 1) 
          then (snd coord + radius) 
          else (get_board_width board - 1) in
        print_string "\nY coord: ";
        print_int (end_y);
    let end_x = if (fst coord + radius) < (get_board_width board - 1) 
      then (fst coord + radius) 
      else (get_board_width board - 1) in
    
  
    let rec search_zone_units x y acc =
      print_string "\nx: ";
        print_int x;
        print_string " y: ";
        print_int y;
      if x > end_x then acc
      else if y > end_x then search_zone_units (x + 1) start_x acc
      else
        
        let units = Array.to_list (get_units (get_tile board x y)) in
        let clean_units = List.filter (fun unit_id -> unit_id <> -1) units in
        
        search_zone_units x (y + 1) (acc @ clean_units)
    in
    search_zone_units start_x start_x [];;

  module Set_coord = Set.Make (
    struct
      type t = int * int
      let compare (a1,a2) (b1,b2) = (
        if a1 > b1 then 1
        else if a1 < b1 then -1
        else if a2 > b2 then 1
        else if a2 < b2 then -1
        else 0
        )
    end
    )

  let surrounding_tile x y max_x max_y=
    let s = Set_coord.empty in

    let  c1 = if x>0 then Set_coord.add (x-1,y) s else s in
    let  c2 = if x>0 && y>0 then Set_coord.add (x-1,y-1) c1 else c1 in
    let  c3 = if x>0 && y< max_y-1 then Set_coord.add (x-1,y+1) c2 else c2 in

    let  c4 = if x<max_x-1 then Set_coord.add (x+1,y) c3 else c3 in
    let  c5 = if x<max_x-1 && y>0 then Set_coord.add (x+1,y-1) c4 else c4 in
    let  c6 = if x<max_x-1 && y< max_y-1 then Set_coord.add (x+1,y+1) c5 else c5 in

    let  c7 = if y>0 then Set_coord.add (x,y-1) c6 else c6 in
    let  c8 = if y>max_y-1 then Set_coord.add (x,y+1) c7 else c7 in

    c8

  let get_coord_in_range x y n max_x max_y =
    let rec add_up x y n s =
      if n>0
      then
        if y>0
        then add_up x (y-1) (n-1) (Set_coord.add (x,y) s)
        else Set_coord.add (x,y) s 
      else Set_coord.add (x,y) s
    in
    let rec add_low x y n max_y s =
      if n>0
      then
        if y<max_y-1
        then add_low x (y+1) (n-1) max_x (Set_coord.add (x,y) s)
        else Set_coord.add (x,y) s 
      else Set_coord.add (x,y) s
    in
    let rec add_l x y n s = 
      if n>0
      then
        if x>0
        then add_l (x-1) y (n-1) (Set_coord.add (x,y) (add_low x y n max_y (add_up x y n s)))
        else (Set_coord.add (x,y) (add_low x y n max_y (add_up x y n s))) 
      else Set_coord.add (x,y) s
    in
    let rec add_r x y n max_x s = 
      if n>0
      then
        if x<max_x-1
        then add_r (x+1) y (n-1) max_x (Set_coord.add (x,y) (add_low x y n max_y (add_up x y n s)))
        else (Set_coord.add (x,y) (add_low x y n max_y (add_up x y n s)))
      else Set_coord.add (x,y) s
    in

    add_r x y n max_x (add_l x y n (add_up x y n (add_low x y n max_y Set_coord.empty)))

    let field_travelling = function
        | Throne -> Some (-1) 
        | Road -> Some 1
        | Grass -> Some 2
        | Mountain | Forest -> Some 3
        | Brick | Water -> None
        | Empty -> failwith "Empty field" 

    let weight_path l_coord board =
      let rec aux l acc =
        match l with 
        | [] -> acc
        | (x,y)::r -> match field_travelling (get_type_tile board x y) with | None -> aux r acc | Some x -> aux r (acc + x)
      in
      aux l_coord 0
      
  let set_throne board coord = 
    let curr_tile = get_tile board (fst coord) (snd coord) in
    curr_tile.type_tile <- Throne;;

  let remove_throne board coord =
    let curr_tile = get_tile board (fst coord) (snd coord) in
    curr_tile.type_tile <- Grass;;

  
  let find_free_opt units size=
    let rec find_free idx units size=
      if idx >= size then None
      else if units.(idx) = -1 then Some idx
      else find_free (idx + 1) units size
    in
    find_free 0 units size;;
  
  let add_unit_tile board coord id =
    let t = get_tile board (fst coord) (snd coord) in
    let units = !(t.units) in
    let size = Array.length units in
    let free_idx = find_free_opt units size in
    match free_idx with
    | Some idx -> units.(idx) <- id
    | None -> raise (Invalid_argument "No more space for units on this tile")

  let remove_unit_tile board coord id =
  let t = get_tile board (fst coord) (snd coord) in
  let units = !(t.units) in
  let size = Array.length units in
  let rec remove_unit idx =
    if idx >= size then ()
    else if units.(idx) = id then begin
      units.(idx) <- -1;
      remove_unit (idx + 1)
    end
    else remove_unit (idx + 1)
  in
  remove_unit 0

  let move_unit board src dest id =
    try
    add_unit_tile board dest id;
    remove_unit_tile board src id;
    true
  with _ -> false

  let can_move_to board coord =
    let tile = get_tile board (fst coord) (snd coord) in
    let units = !(tile.units) in
    let size = Array.length (units) in
    let free = find_free_opt units size in
    match free with
    | Some _ -> true
    | None -> false

  let can_build_wall board coord =
    let tile = get_tile board (fst coord) (snd coord) in
    match tile.type_tile with
    | Brick -> false
    | _ -> 
      let units = Array.to_list (!(tile.units)) in
      let clean_units = List.filter (fun unit_id -> unit_id <> -1) units in
      if List.length clean_units > 0 then false
      else true;;
      
  
  let build_procedural_1D board type_tile size offset =
    let list_proc = Perlin.Perlin_noise.make_perlin size offset size in
    let rec build_line x l =
      match l with
      | [] -> ()
      | h::t -> 
        (* pas très logique mais contient les mêmes conditions *)
        let cond = can_build_wall board (x,h) in
        if cond = true then 
          set_type_tile board x h type_tile;
        build_line (x + 1) t
    in
    build_line 0 list_proc


  let field_to_String = function
    | Grass -> "G"
    | Mountain -> "H"
    | Forest -> "F"
    | Water -> "W"
    | Road -> "R"
    | Brick -> "B"
    | Throne -> "T"
    | Empty -> "E"


    let print_board b =
        let board = (get_tiles b) in
        let l_units = ref [] in
        let l = ref "" in
        let l1 = ref "" in
        let l2 = ref "" in
        Array.iter (fun x ->
            Array.iter (fun y ->
                l := (String.cat !l "_____");
                l1 := (String.cat !l1 (String.concat (field_to_String y.type_tile) ["   ";"  |"]));
                if y.visibility then (
                    let u = (Array.exists (fun x -> x <> -1) !(y.units)) in
                    if u then (
                        l2 := String.cat !l2 " u |";
                        Array.iter (fun u ->
                            if u <> -1 then
                                l_units := (List.append !l_units [u])
                            else ()
                        ) !(y.units)
                    )

                    else
                        l2 := String.cat !l2 "   |";
                )
                else (
                    l2 := String.cat !l2 "XXX|";)
            ) x;
            print_string !l;
            print_string "\n";
            print_string !l1;
            print_string " \n";
            print_string !l2;
            print_string "\n";
            l := "";
            l1 := "";
            l2 := "";

        ) board;
        List.iter (fun x -> Printf.printf "%d\n" x) !l_units


    
  let add_adj obj xc yc f board =
    let add_xp =
        if xc<((get_board_width board) -1) then
            match (get_type_tile board (xc+1) yc) with
            | Water | Brick -> None
            | _ -> Some (xc+1,yc)
        else
            None
    in
    let add_xm =
        if xc>0 then
            match (get_type_tile board (xc-1) yc) with
            | Water | Brick -> None
            | _ -> Some (xc-1,yc)
        else
            None
    in
    let add_yp =
        if yc<((get_board_height board) -1) then
            match (get_type_tile board xc (yc+1)) with
            | Water | Brick -> None
            | _ -> Some (xc,yc+1)
        else
            None
    in
    let add_ym =
        if yc>0 then
            match (get_type_tile board xc (yc-1)) with
            | Water | Brick -> None
            | _ -> Some (xc,yc-1)
        else
            None
    in

    let l =
        (List.map (function
            | Some x -> x
            | None -> failwith "Problem in add_adj")
        (List.filter
            (function
            | None -> false
            | _ -> true
        ) [add_xp;add_xm;add_yp;add_ym]
        ))
    in

    let rec add obj l =
        match l with
        |[] -> obj
        |x::r -> add (f x obj) r
    in
    add obj l;;
    
  let rec a_star :'a Prio_file.t -> 'b Tree.t -> int*int -> board ref -> 'b Tree.t = fun noeud_prio tree_PCC (xf,yf) board ->
    let weight, (xc,yc), temp_prio_file = Prio_file.pop_smallest noeud_prio in
    let prio_add coord prio =
        if Tree.exists (fun k _ -> k=coord) tree_PCC then prio
        else 
          match field_travelling (get_type_tile board (fst coord) (snd coord)) with
          | Some x -> Prio_file.add prio (weight + x ) coord
          | None -> prio
    in
    let tree_add : Tree.key -> 'b Tree.t -> 'b Tree.t = fun coord tree ->
        if Tree.exists (fun k _ -> k=coord) tree_PCC then tree
        else Tree.add coord (xc,yc) tree
    in
    let next_prio_file = (add_adj temp_prio_file xc yc prio_add board) in 
    let next_tree = (add_adj tree_PCC xc yc tree_add board) in 
    if ((xc,yc) = (xf,yf)) || (Prio_file.is_empty next_prio_file) then
        tree_PCC
    else
        a_star next_prio_file next_tree (xf,yf) board;;


  (*algo suppose graphe connexe*)
  let _find_path : int -> int -> int -> int -> board ref -> Tree.key list = fun xd yd xf yf board ->
    let tree_PCC = Tree.empty in
    let noeud_prio = Prio_file.empty in
    let res = a_star (Prio_file.add noeud_prio 0 (xd,yd)) (Tree.add (xd,yd) (xd,yd) tree_PCC) (xf,yf) board in
    Tree.chemin_racine res (xf,yf) []

  let all_way_to_coord board (x,y) = 
    let tree_PCC = Tree.empty in
    let noeud_prio = Prio_file.empty in
    a_star (Prio_file.add noeud_prio 0 (x,y)) (Tree.add (x,y) (x,y) tree_PCC) (4,4) board


    
  let in_the_way  xa ya xb yb xo yo =
    (*Soit le projeter hortogonal H de O sur (AB) avec R rayon du cercle de centre O, pb de vision si :
    d([OH])<R et H appartient a [AB]*)
    let square x = x *. x in
    let on_line = (0.8 > abs_float((yb-.ya)*.xo -. (xb-.xa)*.yo +. (xb*.ya-.yb*.xa)) /. Float.sqrt(square(yb-.ya) +. square(xb-.xa))) in
    let xh = ( (yb*.xa-.xb*.ya)*.(yb-.ya) +. (xo*.(xb-.xa)+.yo*.(yb-.ya))*.(xb-.xa) ) /. (square(yb-.ya)+.square(xb-.xa)) in
    let yh = ( (yb-.ya)*.(xo*.(xb-.xa)+.yo*.(yb-.ya)) -. (yb*.xa-.xb*.ya)*.(xb-.xa) ) /. (square(yb-.ya)+.square(xb-.xa)) in
    on_line && ((xa<=xh && xh<=xb) || (xa>=xh && xh>=xb)) && ((ya<=yh && yh<=yb) || (ya>=yh && yh>=yb))

  (*return true if there is an obstacle between a and b*)
  let is_hide xa ya xb yb list_o =
    List.exists(fun (xo,yo) -> 
      in_the_way (Float.of_int xa) (Float.of_int ya) (Float.of_int xb) (Float.of_int yb) (Float.of_int xo) (Float.of_int yo)
    ) list_o

  let update_vision board l_units = 
    Array.iteri (fun i x ->
      Array.iteri (fun j _ ->
        (set_visibility board i j false)
      ) x
    ) !(!(board).tiles);

    let l_s_vision = 
      List.map ( fun u ->
        let (x,y) = Pion.CombatUnit.get_coords u in
        let r = Pion.CombatUnit.get_view_range u in
        let max_x = get_board_width board in
        let max_y = get_board_height board in
        ((x,y), (get_coord_in_range x y r max_x max_y))
      )l_units 
    in
  
    let rec blocs x y acc = 
      let next = match get_type_tile board x y with |Mountain |Forest |Brick -> List.append acc [(x,y)] | _ -> acc in 
      if x < (get_board_width board) -1 then
        blocs (x+1) y next 
      else
        if y < (get_board_height board )-1 then
          blocs 0 (y+1) next 
        else 
          acc
    in

    List.iter( fun ((xa,ya),s) ->
      Set_coord.iter( fun (xb,yb) ->
        if not (get_visibility board xb yb)
        then set_visibility board xb yb (not (is_hide xa ya xb yb (blocs 0 0 [])))
      ) s
    ) l_s_vision
    
  let is_board_connex board (x,y) =
    let rec bfs q s_coord =
      match Queue.take_opt q with
      |Some (x,y) ->
        let next_s = add_adj s_coord x y (Set_coord.add) board in
        let next_q = add_adj q x y (fun (x,y) q -> match Set_coord.find_opt (x,y) s_coord with |Some(_,_) -> q |None -> (Queue.add (x,y) q); q) board in
        bfs next_q next_s
      |None -> s_coord
    in
    let rec blocs x y acc = 
      let next = 
        match get_type_tile board x y with 
        |Throne |Road |Grass |Mountain |Forest -> List.append acc [(x,y)] 
        | _ -> acc 
      in 
      if x < (get_board_width board) -1 then
        blocs (x+1) y next 
      else
        if y < (get_board_height board )-1 then
          blocs 0 (y+1) next 
        else 
          acc
    in

    let q = Queue.create () in
    Queue.add (x,y) q;
    let res = bfs q ( Set_coord.empty) in   
    (Set_coord.cardinal res) = (List.length (blocs 0 0 []))+1
    
end;;
