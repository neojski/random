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

fun sconst v = smemo (fn s => (v, s));

fun snth 0 s = shd s
  | snth n s = snth (n-1) s;

fun stake n s = let
  fun stake' 0 s acc = acc
    | stake' n s acc = let val (v, vs) = seval s in stake' (n-1) vs (v::acc) end
in rev (stake' n s []) end;

fun smap f s = smemo (fn _ => let val (v, vs) = seval s in (f v, smap f vs) end);

fun smap1 f s = smemo (fn _ => let val (v, vs) = seval s in (v, vs) end);

fun snat s z = smemo (fn str => (z, smap s str));

fun stab f = let
  fun inc x = x+1;
  val sint = snat inc 0;
in smap f sint end;

fun szip s1 s2 = smemo (fn _ => let val (v1, v1s) = seval s1; val (v2, v2s) = seval s2 in ((v1, v2), szip v1s v2s) end);

fun szipwith f s1 s2 = smap f (szip s1 s2);

fun sfoldl f init s = smemo (fn _ => let val (v, vs) = seval s in (init, sfoldl f (f (init, v)) vs) end);

fun srev s = let
  fun srev' s acc = smemo (fn _ => let val (v, vs) = seval s in (v::acc, srev' vs (v::acc)) end);
in srev' s [] end;

fun sfilter f s = let
  fun find f s = let val (v, vs) = seval s in if f v then (v, vs) else find f vs end;
in smemo (fn _ => let val (v, vs) = find f s in (v, sfilter f vs) end) end;

fun stakewhile f s = let
  fun take f s acc = let val (v, vs) = seval s in if f v then take f vs (v::acc) else acc end;
in rev (take f s []) end;


val s1 = stab (fn x => x);
val s2 = stab (fn x => x*x);
