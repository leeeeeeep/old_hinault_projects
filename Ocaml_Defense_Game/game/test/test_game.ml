
(*TEST PION______________________________________________*)

open Lib_type.Pion.CombatUnit


(* Ne marche pas car next_id encapsulé   *)
(* let s = next_id_unit;;
print_int !s;;
print_newline ();; *)

let unit_1 = create_combat_unit (0,2)1 (create_unit_class "Mage") (create_stat 100 20 5 10 3 10) ;;
let unit_2 = create_combat_unit (0,5) 2 (create_unit_class "Knight") (create_stat 120 25 6 12 4 12);;
  
print_unit unit_1;;
print_unit unit_2;;

print_endline "Test unité de combat";;
print_endline "Test attaque";;
print_endline "unit_1 attaque unit_2";;
print_endline "hp unit_2 avant attaque : ";;
let hp = get_hp_current unit_2;;
print_int hp;;
print_newline ();;
attack unit_1 unit_2;;
print_endline "hp unit_2 après attaque : ";;
let hp = get_hp_current unit_2;;
print_int hp;;
print_newline ();;


print_endline "Test player \n";;

(*TEST PLAYER______________________________________________*)


open Lib_type.Player.Player

let player_1 = create_player "player_1" (create_role "attacker");;
let player_2 = create_player "player_2" (create_role "defender");;
print_player player_1;;
print_player player_2;;

print_endline "Test add_unit";;

add_unit player_1 (get_id_unit unit_1);;
add_unit player_1 (get_id_unit unit_2);;
print_player player_1;; 

print_endline "Test remove_unit";;

remove_unit player_1 (get_id_unit unit_1);;
print_player player_1;;

print_newline ();;
print_endline "Test game_manager \n";;

(*TEST GAME_MANAGER______________________________________________*)


open Lib_manager.Game_manager
let game = Game_manager.create_game();;
(* Game_manager.print_game game;; *)
Game_manager.add_player (create_role "attacker") game;;
Game_manager.add_player (create_role "defender") game;;
Game_manager.add_unit (6,8) 2 "Mage" game;;
print_endline "Add Mage to Player 2";;
Game_manager.add_unit (7,0) 3 "Knight" game;;
print_endline "Add Knight to Player 3";;
Game_manager.add_unit (6,0) 2 "Knight" game;;
print_endline "Add Knight to Player 2";;
Game_manager.add_unit (3,0) 3 "Mage" game;;
print_endline "Add Mage to Player 3";;
Game_manager.print_game game;;

print_newline ();;
print_endline "Test remove_unit\n";;

print_endline "Remove Knight to Player 2";;
print_endline "Remove Knight to Player 3";;
Game_manager.remove_unit 5 game;;
Game_manager.remove_unit 4 game;;
Game_manager.print_game game;;


(* Test encapsulation next_id_name avec le mli *)
(* let k = Game_manager.next_id_name;;
print_int !k;; *)

(*TEST MESSAGE _______________________________________________*)
print_endline "Test message \n";;
open Lib_message.Game_message

let message = Game_message.create_message "Move" 1 [(0, 0); (1, 1)] [100; 101; 102];;

(* Conversion du message en chaine JSON *)

let json_string = Game_message.message_to_string message;;
print_endline "Message to string:";;
print_string json_string;;
print_newline ();;

(* Conversion de la chaine JSON en message *)
let deserialized_message = Game_message.string_to_message json_string;;
print_string "String to message: ";;
let ord = Game_message.get_order deserialized_message;;
print_string (Game_message.order_to_string ord);;


