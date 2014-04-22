use "stream.sml";

(* solution *)
(* lazy flatten stream of lists *)
fun flatten s = smemo (fn _ => seval (unshiftlist (shd s) (flatten (stl s))));

val fibonacci = let
  val fws = smemo (fn str => let
    val str' = unshiftlist [[1], [0]] str;
    val res = (szipwith (fn (x, y) => x @ y) str' (stl str'))
  in seval res end);
in unshift 0 (flatten fws) end;


fun replicate (0, v) = []
  | replicate (n, v) = v::(replicate (n-1, v))
fun drop 0 s = s
  | drop n s = stl (drop (n-1) s)

val kolakoski = unshiftlist [1, 2] (smemo (fn str => let
  val str' = unshiftlist [1, 2] str;
  val res = drop 2 (flatten (szipwith replicate str' (srepeat [1, 2])))
in seval res end));

val thuemorse = unshift 0 (smemo (fn str' => let
  val str = unshift 0 str';
  val str1 = smap (fn x => 1-x) str;
  val res = sinterleave [str1, stl str];
in seval res end));
