module M = Map.Make (
    struct
    type t = int
    let compare = compare
end)

type key = M.key
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

let rec print prio = 
    if is_empty prio then ()
    else 
        let (k,(v1,v2),r) = pop_smallest prio in
        Printf.printf "k(%d) -> v(%d * %d)\n" k v1 v2; print r;;