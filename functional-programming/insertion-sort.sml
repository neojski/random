(* C04 *)
(* http://en.literateprograms.org/Insertion_sort_(Standard_ML)#Sorting_in_place *)
fun insertion_sort cmp a = let
  fun insert (i, v) = let
    val j = ref (i-1)
  in
    while !j >= 0 andalso cmp (Array.sub (a, !j), v) = GREATER do (
      Array.update (a, !j + 1, Array.sub (a, !j));
      j := !j - 1
    );
    Array.update (a, !j + 1, v)
  end
in (Array.appi insert a) end;

val a = Array.fromList [3,2,4,1,5];
insertion_sort Int.compare a;
a;
