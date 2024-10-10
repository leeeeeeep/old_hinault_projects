
module CombatUnit = struct
  type stat = {
    hp_max : int;
    atk : int;
    atk_spd : int;
    range : int;
    mv_spd : int;
    view_range : int
  }

(**  type Magicien = NOMRAL | GLACE| FEU*)
  type unit_class = Mage | Knight | Archer

  (**
  Moving : doit ignorer les attaques pour arriver à la destination
  Defending : défendre sans bouger 
  Attacking : attaque toute unité à portée, bouge vers la position, ne suit pas la cible 
  (passer à Defending la destination est a distance suffisante)
  **)
  type unit_action_state = Defending | Attacking | Moving

  type combat_unit = {
    mutable coords : int * int;
    mutable target_coords : int * int;
    mutable action_state : unit_action_state;
    id_unit : int;
    id_player : int;
    u_class : unit_class;
    mutable u_stat : stat;
    mutable hp_current : int;
    mutable path : ((int * int)) list
  }

  let next_id_unit = ref 0

  let create_stat hp_max atk atk_spd range mv_spd view_range =
    { hp_max; atk; atk_spd; range; mv_spd; view_range }

  let create_base_stat = function
    | Mage ->   create_stat 100 10 1 2 2 10
    | Knight -> create_stat 150 15 1 2 1 5
    | Archer -> create_stat 80 8 15 2 1 8

  let create_unit_class = function
    | "Mage" -> Mage
    | "Knight" -> Knight
    | "Archer" -> Archer
    | _ -> failwith "Invalid unit class"

  let create_combat_unit coords id_player u_class u_stat =
    let target_coords = (-1, -1) in 
    let action_state = Defending in
    let id_unit = !next_id_unit in
    next_id_unit := !next_id_unit + 1;
    let hp_current = u_stat.hp_max in
    {
    coords = coords;
    target_coords = target_coords;
    action_state = action_state;
    id_unit = id_unit;
    id_player = id_player;
    u_class = u_class;
    u_stat = u_stat;
    hp_current = hp_current;
    path = []
  }

  let get_id_unit u = u.id_unit
  let get_id_player u = u.id_player
  let get_unit_class u = u.u_class
  let get_stat u = u.u_stat
  let get_hp_current u = u.hp_current
  let get_hp_max u = u.u_stat.hp_max
  let get_atk_spd u = u.u_stat.atk_spd
  let get_mv_spd u = u.u_stat.mv_spd
  let get_view_range u = u.u_stat.view_range
  let get_coords u = u.coords
  let get_target_coords u = u.target_coords
  let get_range u = u.u_stat.range
  let get_action_state u = u.action_state
  let get_path u = u.path
  let set_path u new_path = u.path <- new_path
  let set_hp_current u new_hp =
    u.hp_current <- new_hp
  let set_coords u new_coords =
    u.coords <- new_coords
  let set_stat u new_stat =
    u.u_stat <- new_stat
  let set_target_coords u new_target_coords =
    u.target_coords <- new_target_coords
  let move_state u = u.action_state <- Moving
  let attack_state u = u.action_state <- Attacking
  let defend_state u = u.action_state <- Defending

(*  let atk_value current_unit range = 
    let unit_range = current_unit.u_stat.range in
    let malus_range = unit_range / 2 in 
    if range > unit_range then 0
    else let fst_malus = match current_unit.u_class with
      | Mage when range <=  malus_range -> current_unit.u_stat.atk / 3
      | Archer when range <=  malus_range -> current_unit.u_stat.atk / 2
      | _ -> current_unit.u_stat.atk
    in match current_unit.action_state with
      | Defending -> fst_malus
      | _ -> fst_malus - 5*)

  let attack attacker defender =
(*    let atk_val = atk_value 
                attacker 
                (max 
                  (abs (fst attacker.coords - fst defender.coords)) 
                  (abs (snd attacker.coords - snd defender.coords))) in
    let new_hp = defender.hp_current - atk_val in*)
    set_hp_current defender (defender.hp_current - attacker.u_stat.atk)

  let u_class_str current_unit = match current_unit.u_class with
      | Mage -> "mage"
      | Knight -> "knight"
      | Archer -> "archer"
  let print_unit current_unit =
    let u_class_str = u_class_str current_unit
    in
    let stat = current_unit.u_stat in
    Printf.printf "ID: %d, Player: %d, Class: %s\n" current_unit.id_unit current_unit.id_player u_class_str;
    Printf.printf "HP: %d/%d, ATK: %d, ATK SPD: %d, RANGE: %d, MV SPD: %d, VIEW RANGE: %d\n"
      current_unit.hp_current stat.hp_max stat.atk stat.atk_spd stat.range stat.mv_spd stat.view_range
end;;

