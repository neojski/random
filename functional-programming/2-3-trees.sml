datatype 'a node = Two of 'a node * 'a * 'a node |
                   Three of 'a node * 'a * 'a node * 'a * 'a node |
                   Empty;

datatype 'a nodeType = Prop of 'a node | Good of 'a node;

fun unpack (Good x) = x
  | unpack (Prop x) = x;

fun insert cmp (x, T) = let
  fun cmp2 (x, y) = if x >= y then GREATER else LESS

  (* if we PROPagate then we're sure that it's node of type Two *)
  fun fix2L (Good l) y r = Good (Two (l, y, r))
    | fix2L (Prop (Two (t1, a, t2))) b t3 = Good (Three (t1, a, t2, b, t3))

  fun fix2R l y (Good r) = Good (Two (l, y, r))
    | fix2R t1 a (Prop (Two (t2, b, t3))) = Good (Three (t1, a, t2, b, t3))

  fun fix3L (Good t1) x t2 y t3 = Good (Three (t1, x, t2, y, t3))
    | fix3L (Prop t1) x t2 y t3 = Prop (Two (t1, x, Two (t2, y, t3)))

  fun fix3R t1 x t2 y (Good t3) = Good (Three (t1, x, t2, y, t3))
    | fix3R t1 x t2 y (Prop t3) = Prop (Two (Two (t1, x, t2), y, t3))

  fun fix3C t1 x (Good t2) y t3 = Good (Three (t1, x, t2, y, t3))
    | fix3C t1 x (Prop (Two (t2, y, t3))) z t4 = Prop (Two (Two(t1, x, t2), y, Two(t3, z, t4)))

  fun insert' x Empty = Prop (Two (Empty, x, Empty))
    | insert' x (Two (l, y, r)) = (case cmp2 (x, y) of
        LESS => fix2L (insert' x l) y r
      | GREATER => fix2R l y (insert' x r)
    )

    | insert' x (Three (t1, y, t2, z, t3)) = (case cmp2 (x, y) of
        LESS => fix3L (insert' x t1) y t2 z t3
      | GREATER => (case cmp2 (x, z) of
            LESS => fix3C t1 y (insert' x t2) z t3
          | GREATER => fix3R t1 y t2 z (insert' x t3)
        )
    )
in unpack (insert' x T) end;

fun remove cmp (s, T) = let
  (* search by Jakub Kozik *)
  fun search cmp (x, Empty) = false |
    search cmp (x, Two (left, y, right)) =
      let val c = cmp (x, y);
      in
        if (c < 0) then
          search cmp (x, left)
        else if (c > 0) then
          search cmp (x, right)
        else true
      end |
    search cmp (x, Three (left, y, middle, z, right)) =
      let val c1 = cmp (x, y);
      in
        if (c1 < 0) then
          search cmp (x, left)
        else if (c1 > 0) then
          let val c2 = cmp (x, z)
          in
            if (c2 < 0) then
              search cmp (x, middle)
            else if (c2 > 0) then
              search cmp (x, right)
            else true
          end
        else true
      end;

  fun cmp3 (x, y) = if cmp (x, y) > 0 then GREATER else (if cmp(x, y) = 0 then EQUAL else LESS)

  fun fix2L (Good t1) x t2 = Good (Two (t1, x, t2))
    | fix2L (Prop t1) x (Two (t2, y, t3)) = Prop (Three (t1, x, t2, y, t3))
    | fix2L (Prop t1) x (Three (t2, y, t3, z, t4)) = Good (Two (Two (t1, x, t2), y, Two (t3, z, t4)))

  fun fix2R t1 x (Good t2) = Good (Two (t1, x, t2))
    | fix2R (Two (t1, x, t2)) y (Prop t3) = Prop (Three (t1, x, t2, y, t3))
    | fix2R (Three (t1, x, t2, y, t3)) z (Prop t4) = Good (Two (Two (t1, x, t2), y, Two (t3, z, t4)))

  fun fix3L (Good t1) x t2 y t3 = Good (Three (t1, x, t2, y, t3))
    | fix3L (Prop t1) x (Two (t2, y, t3)) z t4 = Good (Two (Three (t1, x, t2, y, t3), z, t4))
    | fix3L (Prop t1) x (Three (t2, y, t3, z, t4)) w t5 = Good (Three (Two (t1, x, t2), y, Two (t3, z, t4), w, t5))

  fun fix3C t1 x (Good t2) y t3 = Good (Three (t1, x, t2, y, t3))
    | fix3C (Two (t1, x, t2)) y (Prop t3) z t4 = Good (Two (Three (t1, x, t2, y, t3), z, t4))
    | fix3C (Three (t1, x, t2, y, t3)) z (Prop t4) w t5 = Good (Three (Two (t1, x, t2), y, Two (t3, z, t4), w, t5))

  fun fix3R t1 x t2 y (Good t3) = Good (Three (t1, x, t2, y, t3))
    | fix3R t1 x (Two (t2, y, t3)) z (Prop t4) = Good (Two (t1, x, Three (t2, y, t3, z, t4)))
    | fix3R t1 x (Three (t2, y, t3, z, t4)) w (Prop t5) = Good (Three (t1, x, Two (t2, y, t3), z, Two (t4, w, t5)))

  fun getLargest (Two (Empty, x, Empty)) = x
    | getLargest (Two (t1, x, t2)) = getLargest t2
    | getLargest (Three (Empty, x, Empty, y, Empty)) = y
    | getLargest (Three (t1, x, t2, y, t3)) = getLargest t3

  fun removeLargest (Two (Empty, x, Empty)) = Prop Empty
    | removeLargest (Two (t1, x, t2)) = fix2R t1 x (removeLargest t2)
    | removeLargest (Three (Empty, x, Empty, y, Empty)) = Good (Two (Empty, x, Empty))
    | removeLargest (Three (t1, x, t2, y, t3)) = fix3R t1 x t2 y (removeLargest t3)

  (* assumption: we're sure we'll find s *)
  fun remove (Two (Empty, _, Empty)) = Prop Empty
    | remove (Two (t1, x, t2)) = (case cmp3 (s, x) of
        EQUAL => fix2L (removeLargest t1) (getLargest t1) t2
      | LESS => fix2L (remove t1) x t2
      | GREATER => fix2R t1 x (remove t2)
    )
    | remove (Three (Empty, x, Empty, y, Empty)) = Good (Two (Empty, if (x = s) then y else x, Empty))
    | remove (Three (t1, x, t2, y, t3)) = (case cmp3 (s, x) of
        EQUAL => fix3L (removeLargest t1) (getLargest t1) t2 y t3
      | LESS => fix3L (remove t1) x t2 y t3
      | GREATER => (case cmp3 (s, y) of
          EQUAL => fix3C t1 x (removeLargest t2) (getLargest t2) t3
        | LESS => fix3C t1 x (remove t2) y t3
        | GREATER => fix3R t1 x t2 y (remove t3)
      )
    )
in if search cmp (s, T) then (true, unpack (remove T)) else (false, T) end;

(*
local
  fun height' (Empty, h) = h |
    height' (Two (t1, _, _), h) = height' (t1, h+1) |
    height' (Three (t1, _, _, _, _), h) = height' (t1, h+1);
in
  fun height t = height' (t, 0);
end

local
  fun height' (Empty, h) = h |
      height' (Two(t1, _, _), h) = height' (t1, h+1) |
      height' (Three(t1, _, _, _, _), h) = height' (t1, h+1);
in
  fun height t = height' (t, 0);
end

local
  fun check' (Empty, 0) = true |
      check' (Empty, h) = false |
      check' (Two(t1, _, t2), h) = check' (t1, h-1) andalso check' (t2, h-1) |
      check' (Three(t1, _, t2, _, t3), h) = check' (t1, h-1) andalso check' (t2, h-1) andalso check'(t3, h-1)
in
  fun check T = check' (T, height T)
end

fun search cmp (x, Empty) = false |
  search cmp (x, Two (left, y, right)) =
    let val c = cmp (x, y);
    in
      if (c < 0) then
        search cmp (x, left)
      else if (c > 0) then
        search cmp (x, right)
      else true
    end |
  search cmp (x, Three (left, y, middle, z, right)) =
    let val c1 = cmp (x, y);
    in
      if (c1 < 0) then
        search cmp (x, left)
      else if (c1 > 0) then
        let val c2 = cmp (x, z)
        in
          if (c2 < 0) then
            search cmp (x, middle)
          else if (c2 > 0) then
            search cmp (x, right)
          else true
        end
      else true
    end;

fun mycmp (x : int, y) = x - y;

val r = Random.rand (12, 35);
fun randInt n = (Random.randInt r) mod n;

fun randomList _ 0 = []
  | randomList r n = (randInt 100000)::(randomList r (n-1))

fun fromList xs = foldl (fn (x, tr) => insert mycmp (x, tr)) Empty xs;


fun checkInOrder t = let
  fun checkInOrder' Empty _ _ = true
    | checkInOrder' (Two (l, x, r)) a b = (a <= x) andalso (x <= b) andalso (checkInOrder' l a x) andalso (checkInOrder' r x b)
    | checkInOrder' (Three (l, x, c, y, r)) a b = (a <= x) andalso (x <= y) andalso (y <= b) andalso (checkInOrder' l a x) andalso (checkInOrder' r y b);
in checkInOrder' t (valOf Int.minInt) (valOf Int.maxInt) end;

fun checkValues t l = List.all (fn el => search mycmp (el, t)) l

fun test t l = (checkInOrder t) andalso (check t) andalso (checkValues t l);


fun doTest n = let
  val l = randomList r n;
  val t = fromList l;

  val t' = #2(remove mycmp (hd l, t))
in test t' (tl l) end;

val results = List.tabulate (100, fn n => doTest 10);
val results = List.tabulate (100, fn n => doTest (n+1));
List.all (fn x => x) results;
*)
