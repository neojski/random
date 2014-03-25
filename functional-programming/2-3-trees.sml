datatype 'a node = Two of 'a node * 'a * 'a node |
                   Three of 'a node * 'a * 'a node * 'a * 'a node |
                   Empty;

datatype 'a nodeType = Prop of 'a node | Good of 'a node;

fun insert cmp2 (x, T) = let
  fun cmp (x, y) = if x >= y then GREATER else LESS

  (* if we PROPagate then it's only Two *)
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
    | insert' x (Two (l, y, r)) = (case cmp (x, y) of
        LESS => fix2L (insert' x l) y r
      | GREATER => fix2R l y (insert' x r)
      )

    | insert' x (Three (t1, y, t2, z, t3)) = (case cmp (x, y) of
        LESS => fix3L (insert' x t1) y t2 z t3
      | GREATER => (case cmp (x, z) of
            LESS => fix3C t1 y (insert' x t2) z t3
          | GREATER => fix3R t1 y t2 z (insert' x t3)
          )
      )

  fun unpack (Good x) = x
    | unpack (Prop x) = x;

in unpack (insert' x T) end;









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

val tree = insert mycmp (2, insert mycmp (3, insert mycmp (4, insert mycmp (6, insert mycmp
(5, Empty)))));

fun randomList _ 0 = []
  | randomList r n = (Random.randInt r)::(randomList r (n-1))


fun fromList xs = foldl (fn (x, tr) => insert mycmp (x, tr)) Empty xs;

fun checkInOrder Empty _ _ = true
  | checkInOrder (Two (l, x, r)) a b = (a <= x) andalso (x <= b) andalso (checkInOrder l a x) andalso (checkInOrder r x b)
  | checkInOrder (Three (l, x, c, y, r)) a b = (a <= x) andalso (x <= y) andalso (y <= b) andalso (checkInOrder l a x) andalso (checkInOrder r y b);

fun test _ = let
  val r = Random.rand (12, 35)
  val xs = randomList r 100000
  val t = fromList xs
in (checkInOrder t (valOf Int.minInt) (valOf Int.maxInt)) end;

