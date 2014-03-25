(* C04 *)
fun cycle_length perm = let
  val permA = Vector.fromList perm;
  fun it k = let
    val next = Vector.sub (permA, k);
  in if (next = 0) then 1 else 1 + (it next) end;
in it 0 end;

fun max_cycle_length perm = let
  val permA = Vector.fromList perm;
  val vis = Array.array(length perm, 0);

  fun max (a,b) = if a < b then b else a;

  fun cycle_len cur start = let
    val next = Vector.sub (permA, cur);
  in
    if (Array.sub (vis, start) = 1) then 0 else
      let
        val () = Array.update (vis, next, 1);
      in
        if (next = start) then 1 else 1 + (cycle_len next start)
      end
  end;

  fun cycle_len2 cur = cycle_len cur cur;
  val lengths = Vector.map cycle_len2 permA;
in Vector.foldl max 0 lengths end;

max_cycle_length [6,0,3,2,4,5,7,1];
max_cycle_length [6,0,3,8,2,4,5,7,1];
max_cycle_length [5,8,3,4,1,0,6,7,2];


