(* 
(* open Lib_interface;; *)
(* open Game_interface;; *)
(* open Interface_info;; *)

(* Game_interface.run (Game_interface.create_config);; *)

(* open Lib_manager.Game_manager;;



Game_manager.run_solo() *)

(* open Lwt.Infix *)


let print_letter_times letter times =
  let rec loop n =
    if n > 0 then (
      print_string letter;
      (* Lwt_unix.sleep 1.0 >>= fun () -> *)
      loop (n - 1)
    ) else (
      Lwt.return_unit
    )
  in
  loop times

  (* let print_letter_times_bis letter times =
    let rec loop n =
      if n > 0 then (
        print_string letter;
        Lwt_unix.sleep 1.0 >>= fun () ->
        loop (n - 1)
      ) else (
        Lwt.return_unit
      )
    in
    loop times *)

let create_threads () =
  let thread2 = print_letter_times "b" 3 in
  let thread1 = print_letter_times "a" 3 in
  Lwt.join [thread1; thread2]

(* Utilisation de la fonction *)

let () = Lwt_main.run (create_threads ())





 *)

 open Lib_type;;

 let _ = Perlin.Perlin_noise.make_perlin 50 10.0 17

