module Perlin_noise =
struct

  let generate_permutation () =
    let perm = Array.init 256 (fun i -> i) in
    let rec shuffle_array arr n =
      if n <= 0 then arr
      else
        let j = Random.int (n + 1)
      in
        let temp = arr.(n) in
        arr.(n) <- arr.(j);
        arr.(j) <- temp;
        shuffle_array arr (n - 1)
    in
    shuffle_array perm (Array.length perm - 1)

  let p = generate_permutation ()

  let fade t =
    t *. t *. t *. (t *. (t *. 6. -. 15.) +. 10.)

  let lerp t a b =
    a +. t *. (b -. a)

  let grad hash x y z =
    let h = hash land 15 in
    let u = if h < 8 then x else y in
    let v = if h < 4 then y else if h = 12 || h = 14 then x else z in
    if (h land 1) = 0 then u else -.u +. v

  let perlin_noise x y z =
    let xf = int_of_float (floor x) land 255 in
    let yf = int_of_float (floor y) land 255 in
    let zf = int_of_float (floor z) land 255 in
    let u = fade (x -. floor x) in
    let v = fade (y -. floor y) in
    let w = fade (z -. floor z) in
    let a = p.(xf) + yf in
    let aa = p.(a) + zf in
    let ab = p.(a + 1) + zf in
    let b = p.(xf + 1) + yf in
    let ba = p.(b) + zf in
    let bb = p.(b + 1) + zf in
    lerp w
      (lerp v
        (lerp u (grad p.(aa) x y z) (grad p.(ba) (x -. 1.) y z))
        (lerp u (grad p.(ab) x (y -. 1.) z) (grad p.(bb) (x -. 1.) (y -. 1.) z)))
      (lerp v
        (lerp u (grad p.(aa + 1) x y (z -. 1.)) (grad p.(ba + 1) (x -. 1.) y (z -. 1.)))
        (lerp u (grad p.(ab + 1) x (y -. 1.) (z -. 1.)) (grad p.(bb + 1) (x -. 1.) (y -. 1.) (z -. 1.))))

  let make_perlin size offset bounds= 
    let res = [] in 
    let rec aux counter res = 
      if counter = size then res
      else 
        let perlin_value = perlin_noise (float_of_int counter /. float_of_int size) 0.0 0.0 in
        let perlin_decimal = perlin_value *. 10.0 in 
        let perlin_offset = perlin_decimal +. offset in
        let perlin_neg = if perlin_offset < 0.0 then 0.0 else perlin_offset in
        let perlin_int = 
          let round = if ((perlin_neg *. 10.) > 5.) then 1 else 0 in
          int_of_float perlin_neg + round in
        let perlin_bounds = if perlin_int > bounds then bounds - 1 else perlin_int in
        Printf.printf "%d " perlin_bounds;
        aux (counter + 1) (perlin_bounds :: res)
    in aux 0 res


end