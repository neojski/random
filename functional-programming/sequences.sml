fun rl () = use "stream.sml";

local
  datatype 'a memo_cell = Value of 'a | Computation of unit -> 'a
  exception CellInvalid
  fun make_memo () =
  let
    val cell = ref (Computation (fn _ => raise CellInvalid))
    fun res () =
        case !cell of
          Computation h => (
            let val r = h () in
              cell := Value r;
              r
            end)
        | Value y => y
  in
    (cell, res) (* (miejsce w pamięci albo z wartością albo z obliczeniem, zwraca wartość) *)
  end
in
  (* fn : ((unit -> 'a) -> 'b * (unit -> 'a)) -> 'b
   * smemo pozwala spamiętywać obliczenia oraz pełni rolę operatora
   * punktu stałego (ze względu na brak rekursji na wartościach
   * w SMLu).
   * Zadaniem 'f' jest skonstruować obliczenie do spamiętania
   * oraz dowolną wartość, którą zwraca memo.
   * Argumentem funkcji 'f' jest to samo obliczenie, które
   * 'f' skonstruuje - ale w opakowanej wersji ze spamiętaniem.
   *)
  fun memo f =
  let
    val (mcell, memoized_computation) = make_memo ()
    val (result, computation) = f memoized_computation (*f bierze syf [() -> 'a, memoized_computation] i zwraca jakiś tam wynik [zwrócony przez memo] oraz obliczenie *)
  in
    mcell := Computation computation;
    result
  end
end

(* Strumień to funkcja zeroargumentowa zwracająca
 * głowę strumienia oraz ogon. Ze względu na rekursywny
 * typ, funkcja opakowana jest w konstruktor Stream
 *)
datatype 'a stream = Stream of unit -> 'a * 'a stream
fun seval (Stream f) = f ();
fun shd s = #1 (seval s);
fun stl s = #2 (seval s);

(* fn : ('a stream -> 'a * 'a stream) -> 'a stream
 * smemo tworzy spamiętany strumień. Ten strumień jest
 * przekazywany do funkcji 'f' jako argument oraz
 * zwracany przez smemo. Funkcja 'f' konstruuje
 * początek strumienia - głowę oraz ogon.
 *)
fun smemo f = memo (fn the_stream =>
  let val wrapped_stream = Stream the_stream
      in (wrapped_stream, fn () => f wrapped_stream)
  end
)

(* MY HELPER FUNCTIONS, lazy shift, lazy unshift *)
fun sshift s = Stream (fn () => seval (stl s));
fun unshift v s = smemo (fn _ => (v, s));
fun unshiftlist [] s = s
  | unshiftlist (x::xs) s = smemo (fn _ => (x, unshiftlist xs s));

fun sconst v = smemo (fn s => (v, s));

fun snth 0 s = shd s
  | snth n s = snth (n-1) (stl s);

fun stake n s = let
  fun stake' 0 s acc = acc
    | stake' n s acc = let val (v, vs) = seval s in stake' (n-1) vs (v::acc) end
in rev (stake' n s []) end;

fun smap f s = smemo (fn _ => let val (v, vs) = seval s in (f v, smap f vs) end);

fun smap1 f s = smemo (fn _ => let val (v, vs) = seval s in (f v, vs) end);

fun snat s z = smemo (fn str => (z, smap s str));

fun stab f = let
  fun inc x = x+1;
  val sint = snat inc 0;
in smap f sint end;

fun szip s1 s2 = smemo (fn _ => let val (v1, v1s) = seval s1; val (v2, v2s) = seval s2 in ((v1, v2), szip v1s v2s) end);

fun szipwith f s1 s2 = smap f (szip s1 s2);

fun sfoldl f init s = unshift init (smemo (fn _ => let val (v, vs) = seval s in seval (sfoldl f (f (init, v)) vs) end));

fun srev s = let
  fun srev' s acc = smemo (fn _ => let val (v, vs) = seval s in (v::acc, srev' vs (v::acc)) end);
in srev' s [] end;

fun sfilter f s = let
  fun find f s = let val (v, vs) = seval s in if f v then (v, vs) else find f vs end;
in smemo (fn _ => let val (v, vs) = find f s in (v, sfilter f vs) end) end;

fun stakewhile f s = let
  fun take f s acc = let val (v, vs) = seval s in if f v then take f vs (v::acc) else acc end;
in rev (take f s []) end;

fun srepeat l = smemo (fn start => seval (unshiftlist l start));

fun ssplitn n str = let
  fun stln 0 str = str
    | stln n str = stln (n-1) (stl str);
  fun modN str = snat (stln n) str;
in stake n (smap (smap shd) (snat (smap stl) (modN str))) end;

fun sinterleave l = smap shd (smemo (fn str => seval (unshiftlist l (smap stl str))));

fun spairs s = smemo (fn _ => let val (v1, vs1) = seval s; val (v2, vs) = seval vs1 in ((v1, v2), spairs vs) end);

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
