open Raylib
let cwd = Sys.getcwd ();;
let path_images =
  let split_root_path = Str.split (Str.regexp "/game") cwd in
  List.hd split_root_path ^ "/game/lib_interface/images/";;

let path_config = 
  let split_root_path = Str.split (Str.regexp "/game") cwd in
  List.hd split_root_path ^ "/game/lib_interface/config_interface.txt";;

open Lib_message.Config_reader

let config_dict = Config_reader.parse_file path_config;;


let default_tile_size = Config_reader.find_value "default_tile_size" config_dict 100;;
let default_unit_length = Config_reader.find_value "default_unit_length" config_dict 6;; 
let unit_icon_size = int_of_float (float_of_int default_tile_size /. (float_of_int default_unit_length *. 0.75))

module Texture_pack = struct
 
  let create_texture texture_path size = 
    let image = load_image (path_images ^ texture_path) in
    image_resize (addr image) size size;
    let copy = image_copy image in
    image_color_grayscale (addr copy);
    (load_texture_from_image image, load_texture_from_image copy);;

  type texture_versions = {
    mutable texture : Texture.t;
    mutable texture_gray : Texture.t;
  }

  type texture_pack = {
    brick : texture_versions;
    grass : texture_versions;
    water : texture_versions;
    throne : texture_versions;
    road : texture_versions;
    forest : texture_versions;
    mountain : texture_versions;
    empty : texture_versions;
    knight : Texture.t;
    archer : Texture.t;
    mage : Texture.t;
  }

  let create_unit_texture_pack texture_path = 
      let image = load_image (path_images ^ texture_path) in
      image_resize (addr image) unit_icon_size unit_icon_size;
      load_texture_from_image image;;

  let create_texture_pack () = 
    let create_texture_pack_aux texture_path = 
      let texture, texture_gray = create_texture texture_path default_tile_size in
      {texture = texture; texture_gray = texture_gray}
    in
    let brick = create_texture_pack_aux "brick.png" in
    let grass = create_texture_pack_aux "grass.png" in
    let water = create_texture_pack_aux "water.png" in
    let throne = create_texture_pack_aux "throne.png" in
    let road = create_texture_pack_aux "road.png" in
    let forest = create_texture_pack_aux "forest.png" in
    let mountain = create_texture_pack_aux "mountain.png" in
    let empty = create_texture_pack_aux "empty.png" in
    let knight = create_unit_texture_pack "knight.png" in
    let archer = create_unit_texture_pack "archer.png" in
    let mage = create_unit_texture_pack "mage.png" in 
    {brick = brick; grass = grass; water = water; throne = throne; road = road; forest = forest; mountain = mountain; empty = empty; knight = knight; archer = archer; mage = mage}

  let get_pack texture_pack texture_name = 
    match texture_name with 
    | "brick" -> texture_pack.brick
    | "grass" -> texture_pack.grass
    | "water" -> texture_pack.water
    | "throne" -> texture_pack.throne
    | "road" -> texture_pack.road
    | "forest" -> texture_pack.forest
    | "mountain" -> texture_pack.mountain
    | "knight" -> {texture = texture_pack.knight; texture_gray = texture_pack.knight}
    | "archer" -> {texture = texture_pack.archer; texture_gray = texture_pack.archer}
    | "mage" -> {texture = texture_pack.mage; texture_gray = texture_pack.mage}
    | _ -> texture_pack.empty;;
      

  let get_texture texture_pack texture_name = 
    let texture = get_pack texture_pack texture_name in
    texture.texture;;
  
  let get_texture_gray texture_pack texture_name = 
    let texture = get_pack texture_pack texture_name in
    texture.texture_gray;;
end

open Interface_info
open Lwt
open Lib_message.Game_message


module Game_interface = struct 
  
  type state = DISCONNECTED | TITLE_SCREEN | GAME | GAME_END

  let screen_width = 1280
  let screen_height = 720
  let font_size = 50
  
  type interface_config = {
    mutable current_state : state;
    current_player : int;
    mutable info : Info_to_interface.message;
    mutable target : Vector2.t;
    mutable offset : Vector2.t;
    mutable zoom : float;
    mutable rotation : float;
    mutable tile_size : int;
    mutable selected_target : (int*int);
    mutable first_selection : float * float;
    mutable selected_square : Rectangle.t;
    mutable collison_rectangles : Rectangle.t list;
    mutable selected_tiles : (int * int) list;
    mutable messages : Game_message.message list;
    message_lock : Lwt_mutex.t;
    lock : Lwt_mutex.t;
    mutable tick_counter : int;
  }

  
  let create_config player_id = {
    current_state = TITLE_SCREEN;
    current_player = player_id;
    info = Info_to_interface.create_empty_message ();
    target = Vector2.create 0.0 0.0;
    offset = Vector2.create 0.0 0.0;
    zoom = 1.0;
    rotation = 0.0;
    tile_size = default_tile_size;
    selected_target = (-1,-1);
    first_selection = (-1.,-1.);
    selected_square = Rectangle.create 0. 0. 0. 0.;
    collison_rectangles = [];
    selected_tiles = [];
    messages = [];
    message_lock = Lwt_mutex.create ();
    lock = Lwt_mutex.create ();
    tick_counter = 0;
  }

  let get_state config = !config.current_state

  let game_end_state config = 
    !config.current_state <- GAME_END;
    Lwt.return ();;


  let add_tick config =
     Lwt_mutex.with_lock !config.lock (fun () ->
    !config.tick_counter <- !config.tick_counter + 1;
    Lwt.return ()
  )

  let read_tick config (*res*) = 
    Lwt_mutex.with_lock !config.lock (fun () ->
    Lwt.return !config.tick_counter)
     (*
    Lwt_mutex.with_lock !config.lock (fun () ->
    res := !config.tick_counter;
    Lwt.return ()
  )*)

  let navigation config camera =
    if is_mouse_button_down MouseButton.Left then begin
      let delta = get_mouse_delta () in 
        let delta_aux = Vector2.scale delta (0.5 /. !config.zoom) in
        !config.target <- Vector2.add !config.target delta_aux;
    end;

    let wheel = get_mouse_wheel_move () in

    if wheel <> 0. then begin
      let mouse_world_pos = get_screen_to_world_2d (get_mouse_position()) camera in
      !config.offset <- get_mouse_position();
      !config.target <- mouse_world_pos;
      let zoom_increment = 0.125 in 
      !config.zoom <- !config.zoom +. (wheel *. zoom_increment);
        if !config.zoom < zoom_increment then !config.zoom <- zoom_increment;
        if !config.zoom < 0.2  || !config.zoom > 7.0 then 
          (!config.zoom <- 1.0; !config.offset <- Vector2.create 0.0 0.0; !config.target <- Vector2.create 0.0 0.0;);

      if is_key_down Key.Left_shift then begin
        !config.zoom <- 1.0;
        !config.offset <- Vector2.create 0.0 0.0;
        !config.target <- Vector2.create 0.0 0.0;
      end;
    end;;

  let selection_square config = 
    if is_key_down Key.S then begin 
      let mouse_pos = get_mouse_position() in 
      if fst !config.first_selection = -1. then begin 
        !config.first_selection <- (Vector2.x mouse_pos, Vector2.y mouse_pos)

      end
      else begin 
          
          let rectangle_x = (fst !config.first_selection -. Vector2.x !config.target  +. Vector2.x !config.offset ) /. !config.zoom in 
          let rectangle_y = (snd !config.first_selection -. Vector2.y !config.target +. Vector2.y !config.offset) /. !config.zoom in
          let rectangle_width =  (Vector2.x mouse_pos -. fst !config.first_selection)  in
          let rectangle_height = (Vector2.y mouse_pos -. snd !config.first_selection) /. !config.zoom in 

          let rec update_selected_tiles acc rectangles = 
            match rectangles with
            | [] -> acc 
            | hd::tl -> if Raylib.check_collision_recs hd !config.selected_square 
              then let convert_coord rectangle = 
                let x = int_of_float (Rectangle.x rectangle) / !config.tile_size in
                let y = int_of_float (Rectangle.y rectangle) / !config.tile_size in
                update_selected_tiles ((x,y)::acc) tl
              in convert_coord hd
              else update_selected_tiles acc tl
          in

          draw_rectangle_lines 
            (int_of_float rectangle_x) 
            (int_of_float rectangle_y) 
            (int_of_float rectangle_width) 
            (int_of_float rectangle_height) 
            Color.darkpurple;
          
          !config.selected_square <- Rectangle.create rectangle_x rectangle_y rectangle_width rectangle_height;

          !config.selected_tiles <- update_selected_tiles [] !config.collison_rectangles;


      end
    end
    else 
      !config.first_selection <- (-1., -1.);;

  let make_empty_selection config =
    if is_key_down Key.E then begin
      !config.selected_tiles <- [];
      !config.selected_target <- (-1,-1);
    end;;

  let target_selection config = 
    let pos = !config.selected_target in 
    if pos <> (-1,-1) then
      draw_rectangle_lines (fst pos * !config.tile_size) (snd pos * !config.tile_size) !config.tile_size !config.tile_size Color.red;
    if is_key_down Key.Space then begin
      draw_text "Move" 10 70 200 Color.red;
      let mouse_pos = get_mouse_position() in 
      let mouse_offset = Vector2.create 
      ((Vector2.x mouse_pos -. Vector2.x !config.target  +. Vector2.x !config.offset ) /. !config.zoom)
      ((Vector2.y mouse_pos -. Vector2.y !config.target +. Vector2.y !config.offset) /. !config.zoom) in

      let rec find_coord_rectangle rectangles = 
        match rectangles with
        | [] -> (-1,-1)
        | hd::tl -> if Raylib.check_collision_point_rec mouse_offset hd then 
          let convert_coord rectangle = 
            let x = int_of_float (Rectangle.x rectangle) / !config.tile_size in
            let y = int_of_float (Rectangle.y rectangle) / !config.tile_size in
            (x,y)
          in convert_coord hd
          else find_coord_rectangle tl
      in !config.selected_target <- find_coord_rectangle !config.collison_rectangles;
    end

  let selected_units_id config = 
    let tiles = !config.selected_tiles in
    let rec get_units acc tiles = 
      match tiles with
      | [] -> acc
      | (x,y)::tl -> let tile = Info_to_interface.get_tile x y !config.info in
        let units = Info_to_interface.get_visible_units tile in
        let rec convert_to_id = function
          | [] -> []
          | hd::tl -> (Info_to_interface.get_id hd)::(convert_to_id tl)
        in get_units (convert_to_id units @ acc) tl 
    in get_units [] tiles;;

  let draw_game_texture texture_pack config =
    Lwt_mutex.with_lock !config.lock (fun () ->
      let tile_size = !config.tile_size in 
      let rec draw_texture_aux x y =
        if x < Info_to_interface.get_width !config.info && y < Info_to_interface.get_height !config.info then begin
          let tile = Info_to_interface.get_tile x y !config.info in
          let tile_type = Info_to_interface.get_type_tile tile in
          let texture_name =
            match tile_type with
            | "Empty" -> "empty"
            | "Brick" -> "brick"
            | "Grass" -> "grass"
            | "Water" -> "water"
            | "Throne" -> "throne"
            | "Road" -> "road"
            | "Forest" -> "forest"
            | "Mountain" -> "mountain"
            | _ -> failwith "Unknown tile type"
          in

          let draw_unit_icon () =
            let units = Info_to_interface.get_visible_units (Info_to_interface.get_tile x y !config.info) in
            let max_units_length = 6 in
            let draw_health_bar curr_unit x y = 
              let health = Info_to_interface.get_health curr_unit in
              let max_health = Info_to_interface.get_max_health curr_unit in
              let health_ratio = float_of_int health /. float_of_int max_health in
              let health_bar_width = unit_icon_size in
              let health_bar_height = unit_icon_size / 5 in
              let health_bar_x = x + unit_icon_size in
              let health_bar_y = y + unit_icon_size + health_bar_height in
              draw_rectangle health_bar_x health_bar_y (int_of_float (float_of_int health_bar_width *. health_ratio)) health_bar_height Color.green;
              draw_rectangle_lines health_bar_x health_bar_y health_bar_width health_bar_height Color.black;
            in
            let draw_unit_color curr_unit x y = 
              let color = match Info_to_interface.get_id_player_from_unit_info curr_unit with
                | 0 -> Color.red
                | 1 -> Color.blue
                | 2 -> Color.green
                | 3 -> Color.yellow
                | _ -> Color.black
              in
              draw_circle (x + (unit_icon_size + unit_icon_size/2)) (y - unit_icon_size/2) (5.) color
            in
            let rec draw_unit_icon_aux offset_x offset_y index =
              if index >= List.length units then ()
              else
                try 
                    let current_unit = List.nth units index in
                    let texture = Texture_pack.get_texture texture_pack (Info_to_interface.get_unit_class current_unit)
                    in
                    draw_health_bar current_unit (x + offset_x) (y + offset_y);
                    draw_unit_color current_unit (x + offset_x) (y + offset_y);
                    draw_texture texture (x + unit_icon_size + offset_x) (y + offset_y) Color.white;
                    if index + 1 = max_units_length / 2
                      then draw_unit_icon_aux (x) (offset_y + unit_icon_size) (index + 1)
                      else draw_unit_icon_aux (offset_x + unit_icon_size) (offset_y) (index + 1)
                with _ -> ()
            in draw_unit_icon_aux
                    (x * tile_size + tile_size/2 - ( (max_units_length /2) * unit_icon_size)) 
                    (y * tile_size + tile_size/2 -  unit_icon_size) 0 ;
          in 
  
          let texture_x = x * tile_size in
          let texture_y = y * tile_size in

          let visibility = Info_to_interface.get_visibility tile in
          if visibility then begin 
            draw_texture (Texture_pack.get_texture texture_pack texture_name) texture_x texture_y Color.white;
            (* draw_text (string_of_bool visibility) (x * tile_size) (y * tile_size) 10 Color.black; *)
            draw_unit_icon ();
          end else begin
            draw_texture (Texture_pack.get_texture_gray texture_pack texture_name) texture_x texture_y Color.white;
            (* draw_text (string_of_bool visibility) (x * tile_size) (y * tile_size) 10 Color.black; *)
          end;
          
          let rec search_selected_tiles tiles x y = 
            match tiles with
            | [] -> false
            | (x_tile, y_tile)::tl -> if x_tile = x && y_tile = y then true else search_selected_tiles tl x y 
          in let selected = search_selected_tiles !config.selected_tiles x y in
          if selected then
            draw_rectangle_lines texture_x texture_y tile_size tile_size Color.violet
          else
            draw_rectangle_lines texture_x texture_y tile_size tile_size Color.black;
  
          if x + 1 < Info_to_interface.get_width !config.info then draw_texture_aux (x + 1) y
          else draw_texture_aux 0 (y + 1)
        end
      in
      draw_texture_aux 0 0;
      Lwt.return ()
    )
  let get_messages config result = 
    Lwt_mutex.with_lock !config.message_lock (fun () ->
      result := !config.messages;
      !config.messages <- [];
      Lwt.return ();
    )
  
  let create_move_message config = 
    let pos = !config.selected_target in
    let selected_units = selected_units_id config in
    if pos <> (-1, -1) && List.length selected_units > 0 then 
      let message = Game_message.create_message "Move" !config.current_player (pos::[]) selected_units in
      Lwt_mutex.with_lock !config.message_lock (fun () ->
        !config.messages <- message :: !config.messages;
        Lwt.return ()
      ) >>= fun () ->
      !config.selected_target <- (-1,-1);
      Lwt.return ()
    else
      Lwt.return ();;

  let available_buy_option config = 
    let selected_units = selected_units_id config in
    let pos = !config.selected_target in
    if List.length selected_units = 0 && pos <> (-1,-1) then 
      true
    else false;;

  let available_move_option config = 
    let selected_units = selected_units_id config in
    let pos = !config.selected_target in
    if List.length selected_units > 0 && pos <> (-1,-1) then 
      true
    else false;;
       
  let create_buy_message order_name config  = 
    let pos = !config.selected_target in
    if pos <> (-1, -1) then 
      let message = Game_message.create_message order_name !config.current_player (pos::[]) []
      in
      Lwt_mutex.with_lock !config.message_lock (fun () ->
        !config.messages <- message :: !config.messages;
        Lwt.return ()
      ) >>= fun () -> 
      !config.selected_target <- (-1,-1);
      Lwt.return ()
    else
      Lwt.return ();;

  let create_build_message selected_coords config =
    let message = Game_message.create_message "Build" !config.current_player selected_coords []
    in
    Lwt_mutex.with_lock !config.message_lock (fun () ->
      !config.messages <- message :: !config.messages;
      Lwt.return ()
    ) >>= fun () ->
    !config.selected_tiles <- [];
    Lwt.return ();;

  let make_button (config:interface_config ref ) coord width height text (action: interface_config ref -> unit Lwt.t)  = 
    let mouse_pos = get_mouse_position() in
    let rectrangle = Rectangle.create (float_of_int (fst coord)) (float_of_int (snd coord)) (float_of_int width) (float_of_int height) in
    draw_rectangle (fst coord) (snd coord) width height Color.red;
    draw_text text (fst coord + 10) (snd coord + 10) 20 Color.black;
    if check_collision_point_rec mouse_pos rectrangle then begin
      draw_rectangle (fst coord) (snd coord) width height Color.green;
      draw_text text (fst coord + 10) (snd coord + 10) 20 Color.black;
      if is_mouse_button_down MouseButton.Left then ignore(action config);
    end;;

  let button_manager config = 
    begin 
      make_empty_selection config;
      let selected_tiles = !config.selected_tiles in
      let selected_units = selected_units_id config in
      let pos = !config.selected_target in
      if pos <> (-1,-1) then
        begin
          if List.length selected_units > 0 then begin
            make_button config (10, 600) 80 40 "Move" create_move_message;
          end
          else if List.length selected_units = 0 && ((List.length selected_tiles) = 0 ) then begin
            make_button config (110, 600) 140 40 "Buy Mage" (create_buy_message "RecruitMage");
            make_button config (260, 600) 140 40 "Buy Archer" (create_buy_message "RecruitArcher");
            make_button config (410, 600) 140 40 "Buy Knight" (create_buy_message "RecruitKnight");
            make_button config (560, 600) 140 40 "Build" (create_buy_message "Build");
          end
        end
      else if List.length selected_tiles > 0 && List.length selected_units = 0 then
        make_button config (10, 600) 80 40 "Build" (create_build_message selected_tiles)
    end 

  let draw_messages_ready_text config =
    let open Lwt.Syntax in

    draw_text "Gold: " 330 650 15 Color.gold;
    let current_player_info = Info_to_interface.get_players_info !config.current_player !config.info in
    let gold = if current_player_info = None then 0 else Info_to_interface.get_gold (Option.get current_player_info) in
    draw_text (string_of_int gold) 380 650 15 Color.gold;
    draw_text "tick counter: " 170 650 15 Color.red;
    (*let current_tick = ref 0 in*)

    let* current_tick = read_tick config in
    (*ignore(read_tick config current_tick); *)

    draw_text (string_of_int (*!*)current_tick) 270 650 15 Color.red;
    draw_text "messages_ready: " 10 670 15 Color.red;
    let cpt_messages = ref 0 in
    Lwt_mutex.with_lock !config.message_lock (fun () ->
      List.length !config.messages |> Lwt.return
    ) >>= fun messages_length ->

    cpt_messages := messages_length;

    draw_text (string_of_int !cpt_messages) 150 670 15 Color.red;

    Lwt.return ();;

  let screen_game (texture_pack:Texture_pack.texture_pack) config =
    let camera = Camera2D.create !config.target !config.offset !config.rotation !config.zoom
    in
    begin_mode_2d camera;

    (* JE SAIS PAS POURQUOI J'AI ECRIT CA MAIS CA MARCHE*)
    let _ = draw_game_texture texture_pack config in 

    make_empty_selection config;
    target_selection config;
    selection_square config;

    end_mode_2d ();

    button_manager config;
    navigation config camera;
    
    draw_text "zoom: " 10 10 20 Color.red;
    draw_text (string_of_float !config.zoom) 70 10 20 Color.red;
    
    let mouse_pos = get_mouse_position() in 
    draw_text (string_of_float (Vector2.x mouse_pos))10 30 20 Color.red;
    draw_text (string_of_float (Vector2.y mouse_pos))10 50 20 Color.red; 

    let s = "selected tiles: " in
    draw_text s 10 650 15 Color.red;
    let cpt_selected_square = List.length !config.selected_tiles in
    draw_text (string_of_int cpt_selected_square) (String.length s * 10) 650 15 Color.red;

    ignore(draw_messages_ready_text config);

    if is_key_pressed Key.Enter then !config.current_state <- GAME_END;;

  let screen_title config = 
    draw_text "Title Screen" 10 10 font_size Color.red;
    draw_text "GAME" (screen_width/2 - font_size ) (screen_height/2 -  150) font_size Color.red;
    draw_rectangle (screen_width/2 - 100 ) (screen_height/2) 250 100 Color.red;
    draw_text "Start" (screen_width/2 - font_size) (screen_height/2 + font_size/2) font_size Color.black;
    draw_rectangle (screen_width/2 - 100 ) (screen_height/2 + 150) 250 100 Color.red;
    draw_text "Quit" (screen_width/2 - font_size) (screen_height/2 + 150 + font_size/2) font_size Color.black;
    let mouse_pos = get_mouse_position() in 
      if check_collision_point_rec mouse_pos (Rectangle.create (float_of_int(screen_width/2 - 100)) (float_of_int(screen_height/2)) 250. 100.) then begin
        draw_rectangle (screen_width/2 - 100 ) (screen_height/2) 250 100 Color.green;
        draw_text "Start" (screen_width/2 - font_size) (screen_height/2 + font_size/2) font_size Color.black;
        if is_mouse_button_down MouseButton.Left then !config.current_state <- GAME;
      end
      else if check_collision_point_rec mouse_pos (Rectangle.create (float_of_int(screen_width/2 - 100)) (float_of_int(screen_height/2 + 150)) 250. 100.) then begin
        draw_rectangle (screen_width/2 - 100 ) (screen_height/2 + 150) 250 100 Color.green;
        draw_text "Quit" (screen_width/2 - font_size) (screen_height/2 + 150 + font_size/2) font_size Color.black;
        if is_mouse_button_down MouseButton.Left then close_window ();
      end;;


  let generate_rectangle_list config =
    let tile_size = !config.tile_size in
    let board_width = !config.info.width in
    let board_height = !config.info.height in
    let rec generate_rectangles acc x y =
      if y >= board_height then
        acc
      else if x >= board_width then
        generate_rectangles acc 0 (y + 1)
      else begin
        let tile_x = x * tile_size in
        let tile_y = y * tile_size in
        let rectangle = Rectangle.create
          (float_of_int tile_x)
          (float_of_int tile_y)
          (float_of_int tile_size)
          (float_of_int tile_size) in
        generate_rectangles (rectangle :: acc) (x + 1) y
      end
    in
    generate_rectangles [] 0 0

  let update_info (config: interface_config ref ) info =
    Lwt_mutex.with_lock !config.lock (fun () ->
      !config.info <- info;
      Lwt.return ()
    ) >>= fun () ->
    if List.length !config.collison_rectangles = 0 then begin
      !config.collison_rectangles <- generate_rectangle_list config;
      Lwt.return ()
    end else
      Lwt.return ();;

let config_copy config copy = 
  Lwt_mutex.with_lock !config.lock (fun () ->
    !copy.current_state <- !config.current_state;
    !copy.info <- !config.info;
    !copy.target <- !config.target;
    !copy.offset <- !config.offset;
    !copy.zoom <- !config.zoom;
    !copy.rotation <- !config.rotation;
    !copy.tile_size <- !config.tile_size;
    !copy.selected_target <- !config.selected_target;
    !copy.first_selection <- !config.first_selection;
    !copy.selected_square <- !config.selected_square;
    !copy.collison_rectangles <- !config.collison_rectangles;
    !copy.selected_tiles <- !config.selected_tiles;
    !copy.messages <- !config.messages;
    !copy.tick_counter <- !config.tick_counter;
    Lwt.return ()
  )
  
  
  let rec loop texture_pack (config: interface_config ref) cpt=
    let open Lwt.Syntax in
    let* () = return () in

    if window_should_close () then close_window ()
    else

      begin_drawing ();
      clear_background Color.white;
 
      (*LE PATERN MATCHING NE MARCHE PAS ET JE SAIS PAS POURQUOI *)
      if !config.current_state = TITLE_SCREEN then begin
        screen_title config;
      end
      else if !config.current_state = GAME then begin
        screen_game texture_pack config;
      end
      else if !config.current_state = GAME_END then begin
        draw_text "Game End" 10 10 50 Color.red;
        if is_key_pressed Key.Enter then !config.current_state <- TITLE_SCREEN;
      end
      else if  is_key_pressed Key.Escape then begin !config.current_state <- TITLE_SCREEN;
      end;
    
      draw_text (string_of_int cpt) 300 10 20 Color.red;  
      end_drawing ();
      if cpt mod 10 = 0 then 
        Lwt_unix.sleep 0.016 >>= fun () -> 
        loop texture_pack config (1)
      else loop texture_pack config (cpt+1);;


    let run (config: interface_config ref ) = 
      let setup = 
        print_endline "setup";
        init_window screen_width screen_height "hello game";
        set_target_fps 60;
        Texture_pack.create_texture_pack
    in 
    loop (setup ()) config 1;;
  
  
end 


