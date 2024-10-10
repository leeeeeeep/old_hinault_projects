open XpatLib

type game = Freecell | Seahaven | Midnight | Baker

type mode =
  | Check of string (* filename of a solution file to check *)
  | Search of string (* filename where to write the solution *)

type config = { mutable game : game; mutable seed : int; mutable mode : mode }
type move = Column of Card.card | Empty | Register

exception Invalid_move of Card.card * move
exception Invalid_input of string

type state = {
  deposit : int list;
  columns : Card.card list PArray.t;
  registers : Card.card list;
  history: (Card.card * move) list;
  hash: int;
}

module State = struct
  type t = state

  let score state =
    List.fold_left (+) 0 state.deposit

  let hash s =
      PArray.fold (fun a acc -> acc + (List.fold_left2 (fun acc c i -> acc + (Card.to_num c * Card.to_num c * i)) 0 a (List.init (List.length a) (fun i -> i)))) s.columns 0 * 100000000 + (List.fold_left (fun acc a -> acc + (Card.to_num (a) * Card.to_num (a))) 0 s.registers)
end

module StateSet = Set.Make(Int)

type rules = {
  columns : int;
  registers : int;
  init : perm:int list -> state;
  is_ok : move -> Card.card -> bool;
}

let config = { game = Freecell; seed = 1; mode = Search "" }

let king_deep_in_my_column (column : Card.card list) =
  let rec aux2 acc acc2 col =
    match col with
    | [] -> List.rev acc @ acc2
    | x :: xs ->
        if fst x <> 13 then aux2 (x :: acc) acc2 xs else aux2 acc (x :: acc2) xs
  in
  aux2 [] [] column

let distrib f l =
  let split l n =
    let rec aux acc l n =
      if n = 0 then (acc, l) else
      match l with
      | [] -> (acc, [])
      | x :: xs -> aux ((Card.of_num x) :: acc) xs (n - 1)
    in aux [] l n
  in
  let rec aux acc list i = if List.length list >= (f i)
  then let h, t = split list (f i) in aux (h :: acc) t (i+1)
    else (List.rev acc, list)
  in
  aux [] l 0

let getrules gamemode =
  match gamemode with
  | Freecell ->
      {
        columns = 8;
        registers = 4;
        init =
          (fun ~perm ->
            let state = {
              deposit = List.init 4 (fun i -> 0);
              columns =
                 PArray.of_list (fst (distrib (fun a -> if a mod 2 = 0 then 7 else 6) perm));
              registers = [];
              history = [];
              hash = 0;
            } in
            {state with hash = State.hash state});
        is_ok =
          (fun move card ->
            match move with
            | Column i ->
                fst card = fst i - 1
                && ((snd card = Trefle || snd card = Pique)
                    && (snd i = Carreau || snd i = Coeur)
                   || (snd card = Carreau || snd card = Coeur)
                      && (snd i = Trefle || snd i = Pique))
            | Register -> true
            | Empty -> true);
      }
  | Seahaven ->
      {
        columns = 10;
        registers = 4;
        init =
          (fun ~perm ->
            match distrib (fun a -> 5) perm with
            | cols, [c1;c2] -> let state = {
              deposit = List.init 4 (fun i -> 0);
              columns = PArray.of_list cols;
              registers =
                  [
                     (Card.of_num (c1));
                     (Card.of_num (c2));
                  ];
              history = [];
              hash = 0;
            } in {state with hash = State.hash state}
            | _ -> failwith "never happens"
          );
        is_ok =
          (fun move card ->
            match move with
            | Column i -> fst card = fst i - 1 && snd card = snd i
            | Register -> true
            | Empty -> fst card = 13);
      }
  | Midnight ->
      {
        columns = 18;
        registers = 0;
        init =
          (fun ~perm ->
            match distrib (fun a -> 3) perm with
            | cols, [a] -> let state = {
              deposit = List.init 4 (fun i -> 0);
              columns = PArray.of_list (cols@[[(Card.of_num a)]]);
              registers = [];
              history = [];
              hash = 0;
            } in {state with hash = State.hash state}
            | _ -> failwith "never happens"
            );
        is_ok =
          (fun move card ->
            match move with
            | Column i -> fst card = fst i - 1 && snd card = snd i
            | Register -> true
            | Empty -> false);
      }
  | Baker ->
      {
        columns = 13;
        registers = 0;
        init =
          (fun ~perm ->
            let state = {
              deposit = List.init 4 (fun i -> 0);
              registers = [];
              columns = (
                let cul = PArray.of_list (fst (distrib (fun a -> 4) perm)) in
                PArray.map king_deep_in_my_column cul
              );
              history = [];
              hash = 0;
            } in {state with hash = State.hash state});
        is_ok =
          (fun move card ->
            match move with
            | Column i -> fst card = fst i - 1
            | Register -> false
            | Empty -> false);
      }

let findi l e =
  let rec aux i =
    if i = PArray.length l then None
    else if PArray.get l i = e then Some i
    else aux (i + 1)
  in
  aux 0

let get_top_card card columns =
  let rec aux i =
    if i = PArray.length columns then None
    else let col = PArray.get columns i in if List.length col > 0 && List.hd col = card then Some i
    else aux (i + 1)
  in
  aux 0

let is_in_reg card registers =
  List.mem card registers

let check_move (state : state) rules card move =
  if not (rules.is_ok move card) then false else
  let top_card = get_top_card card state.columns in
  let register_card = is_in_reg card state.registers in
  let condition_1 =
    Option.is_some top_card
    || register_card
  in
  if not condition_1 then false else
  let condition_2 =
    match move with
    | Column card2 -> Option.is_some (get_top_card card2 state.columns) && card != card2
    | Empty -> (
        match top_card with
        | Some i -> not (List.length (PArray.get state.columns i) = 1)
        | _ -> true
      ) && Option.is_some (findi state.columns [])
    | Register -> Option.is_some top_card && not register_card && List.length state.registers < rules.registers
  in
  condition_2

let print_state (state : state) =
  Printf.printf "=============================\nColumns:\n";
  PArray.iteri
    (fun i column ->
      Printf.printf "%d:%s\n" i
      (List.fold_left (fun acc card -> Printf.sprintf "%s %s" acc (Card.to_string card)) "" column))
    state.columns;
  let print_reg acc card =
    Printf.sprintf "%s %s" acc (Card.to_string (card))
  in
  Printf.printf "Registers: %s\n" (List.fold_left print_reg "" state.registers);
  Printf.printf "Deposit: %s\n%!" (List.fold_left2
    (fun s color amount -> Printf.sprintf "%s %s:%d" s (Card.suit_to_string color) amount)
    "" [Trefle; Pique; Coeur; Carreau] state.deposit)

let is_game_complete state =
  List.for_all (fun column -> column = 13) state.deposit

let remove_from_top columns card =
  let col = Option.get (get_top_card card columns) in
  PArray.set columns col (List.tl (PArray.get columns col))

let push_to_top columns card col =
  PArray.set columns col (card :: (PArray.get columns col))

let rec normalize (state : state) =
  let normalize_once state =
    let rec normalize_column column = match column with
    | [] -> []
    | h :: t -> if fst h - 1 = List.nth state.deposit (Card.num_of_suit (snd h)) then normalize_column t else column in
    let new_columns = PArray.map normalize_column state.columns
    in
    let new_registers = List.filter (fun card -> not (fst card - 1 = (List.nth state.deposit (Card.num_of_suit (snd card))))) state.registers
    in
    {
      state with
      columns = new_columns;
      registers = new_registers;
      deposit =
        List.map
          (fun i -> 13
            - (PArray.fold (fun b a -> a + (List.fold_left (fun x y -> if snd y = i then x + 1 else x) 0 b)) new_columns 0)
            - (List.fold_left (fun a b -> if snd b = i then a + 1 else a) 0 new_registers))
          [Trefle;Pique;Coeur;Carreau];
      history = state.history;
    }
    in
  let new_state = normalize_once state in
  if new_state = state then { new_state with hash = State.hash new_state }
    else normalize new_state

let is_in_history state hist = StateSet.mem state.hash hist

let execute_move (state : state) card move =
  let columns, registers =
  match move with
  | Column card2 -> (
      let col_card2 = Option.get (get_top_card card2 state.columns) in
      if is_in_reg card state.registers
      then push_to_top state.columns card col_card2, List.filter (fun c -> c <> card) state.registers
      else push_to_top (remove_from_top state.columns card) card col_card2, state.registers)
  | Empty -> (
      let find_first_empty () = Option.get (findi state.columns []) in
      if is_in_reg card state.registers
      then PArray.set state.columns (find_first_empty ()) [ card ], List.filter (fun c -> c <> card) state.registers
      else PArray.set (remove_from_top state.columns card) (find_first_empty ()) [ card ], state.registers)
  | Register -> (
      remove_from_top state.columns card, card::state.registers)
  in
  {
    state with
    columns = columns;
    registers = registers;
    history = (card, move)::state.history;
  }

let get_possible_moves (state: state) rules =
  let top_cards = List.filter_map (fun x -> x) (PArray.to_list (PArray.map (fun x -> if x <> [] then Some (List.hd x) else None) state.columns)) in
  let cards = top_cards @ state.registers in
  let rec get_possible_moves_aux acc card cards =
    if state.history <> [] && fst (List.hd state.history) = card then [] else
    match cards with
    | [] ->
        let acc = if check_move state rules card Empty then (card,Empty)::acc else acc in
        if check_move state rules card Register then (card,Register)::acc else acc
    | h::t -> if h <> card && check_move state rules card (Column h)
      then get_possible_moves_aux ((card, Column h)::acc) card t
      else get_possible_moves_aux acc card t
  in
  let all_moves = List.concat (List.map (fun card -> get_possible_moves_aux [] card top_cards) cards) in
  let states = List.map (fun x -> ((normalize (execute_move state (fst x) (snd x))))) all_moves in
  List.sort (fun x y -> State.score y - State.score x) states

let getgame = function
  | "FreeCell" | "fc" -> Freecell
  | "Seahaven" | "st" -> Seahaven
  | "MidnightOil" | "mo" -> Midnight
  | "BakersDozen" | "bd" -> Baker
  | _ -> raise Not_found

let split_on_dot name =
  match String.split_on_char '.' name with
  | [ string1; string2 ] -> (string1, string2)
  | _ -> raise Not_found

let set_game_seed name =
  try
    let sname, snum = split_on_dot name in
    config.game <- getgame sname;
    config.seed <- int_of_string snum
  with _ ->
    failwith
      ("Error: <game>.<number> expected, with <game> in "
     ^ "FreeCell Seahaven MidnightOil BakersDozen")

let getfile conf = match conf.mode with Search f -> f | Check f -> f

let str_of_move move = match move with
| Register -> "T"
| Empty -> "V"
| Column c -> string_of_int (Card.to_num c)

let rec print_history history out = match history with
| [] -> ()
| h::t -> (
  Printf.fprintf out "%d %s\n" (Card.to_num (fst h)) (str_of_move (snd h));
  print_history t out
  )

let treat_game conf =
  let permut = XpatRandom.shuffle conf.seed in
  let rules = getrules conf.game in
  let state = rules.init ~perm:permut in
  match conf.mode with
  | Check _ -> (
    let first_illegal_move = ref 0 in
    let ic = open_in (getfile conf) in
    let rec check state =
      first_illegal_move := !first_illegal_move + 1;
      let state = normalize state in
      try
        let line = input_line ic in
        let card_str, move_str =
          match String.split_on_char ' ' line with
          | [ string1; string2 ] -> (string1, string2)
          | _ -> raise (Invalid_input line)
        in
        let card = Card.of_num (int_of_string card_str) in
        match int_of_string_opt move_str with
        | Some number ->
            let move = Column (Card.of_num number) in
            if check_move state rules card move then
              check (execute_move state card move)
            else raise (Invalid_move (card, move))
        | None -> (
            match move_str with
            | "V" ->
                if check_move state rules card Empty then
                  check (execute_move state card Empty)
                else raise (Invalid_move (card, Empty))
            | "T" ->
                if check_move state rules card Register then
                  check (execute_move state card Register)
                else raise (Invalid_move (card, Register))
            | _ -> raise (Invalid_input line))
      with _ -> state
    in
    if is_game_complete (check state) then (Printf.printf "SUCCES\n%!";exit 0)
    else (Printf.printf "ECHEC %d\n%!" !first_illegal_move;exit 1)
  )
  | Search file -> (
    let hist = StateSet.empty in
    let rec search states hist = match states with
    | [] -> None
    | h::t ->
        (
          if is_game_complete h then Some (List.rev h.history)
          else
            let hist = StateSet.add h.hash hist in
            let new_states = List.filter (fun s -> not (is_in_history s hist)) (get_possible_moves h rules) in
            let hist = List.fold_left (fun acc s -> StateSet.add s.hash acc) hist new_states in
            let sorted = List.merge (fun a b -> State.score b - State.score a) t (new_states) in
            search sorted hist
          )
    in match search [state] hist with
    | None -> Printf.printf "INSOLUBLE\n%!"
    | Some h -> (print_history h (open_out file);Printf.printf "SUCCES\n%!")
  )

let main () =
  Arg.parse
    [
      ( "-check",
        String (fun filename -> config.mode <- Check filename),
        "<filename>:\tValidate a solution file" );
      ( "-search",
        String (fun filename -> config.mode <- Search filename),
        "<filename>:\tSearch a solution and write it to a solution file" );
    ]
    set_game_seed (* pour les arguments seuls, sans option devant *)
    "XpatSolver <game>.<number> : search solution for Xpat2 game <number>";

  let filename = getfile config in
  treat_game config

let _ = if not !Sys.interactive then main () else ()
