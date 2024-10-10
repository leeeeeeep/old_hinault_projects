module Tree = Map.Make (struct
                             type t = int * int
                             let compare (a1,a2) (b1,b2) = (
                                if a1 > b1 then 1
                                else if a1 < b1 then -1
                                else if a2 > b2 then 1
                                else if a2 < b2 then -1
                                else 0
                                )
                           end)

    type key = Tree.key
    type 'a t = 'a Tree.t

    let empty = Tree.empty

    let add key data m = Tree.add key data m
    let remove x m = Tree.remove x m

    let cardinal m = Tree.cardinal m
    let find x m = Tree.find x m
    let find_opt x m = Tree.find_opt x m
    let is_empty m = Tree.is_empty m
    let exists f m = Tree.exists f m
    let for_all f m =  Tree.for_all f m

    let rec chemin_racine : 'a t -> key -> (key) list -> key list = fun tree_PCC child res ->
      let p = Tree.find child tree_PCC in
      if p=child then
          List.rev res
      else
          chemin_racine tree_PCC p (List.append res [child])

    
    let print _ = Printf.printf "\n Print tree \n";