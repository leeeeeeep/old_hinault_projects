module Perlin_noise :
sig
  
    (** [generate_permutation ()] génère une permutation aléatoire de 256 entiers. *)
    val generate_permutation : unit -> int array

    (** [fade t] applique la fonction de lissage de Perlin sur [t]. *)
    val fade : float -> float

    (** [lerp t a b] effectue une interpolation linéaire entre [a] et [b] avec le paramètre [t]. *)
    val lerp : float -> float -> float -> float

    (** [grad hash x y z] calcule le produit scalaire entre un vecteur de gradient basé sur [hash]
        et le vecteur ([x], [y], [z]). *)
    val grad : int -> float -> float -> float -> float

    (** [perlin_noise x y z] génère un bruit de Perlin à partir des coordonnées ([x], [y], [z]). *)
    val perlin_noise : float -> float -> float -> float

    (** [make_perlin size offset bounds] génère une liste de valeurs de bruit de Perlin de longueur [size].
        Chaque valeur est modifiée par [offset] et contrainte par [bounds]. *)
    val make_perlin : int -> float -> int -> int list

end