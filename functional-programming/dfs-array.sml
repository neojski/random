fun dfs L = let
  val G = Vector.fromList L;
  val V = Array.array (length L, 0);
  val res = ref ([] : int list);
  fun dfs' v =
    if Array.sub (V, v) = 0 then (
      (*print ((Int.toString v) ^ " ");*)
      res := v :: !res;

      Array.update (V, v, 1);
      List.app dfs' (Vector.sub (G, v))
    ) else ();
    val () = List.app dfs' (List.tabulate (length L, fn x => x))
in rev (!res) end;

(*
dfs [[3,1], [], [], []];
dfs [[1], [7,2], [0], [5], [], [1,8], [7], [9], [3], [6]];
*)
