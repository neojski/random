(* C04 *)
datatype 'a Tree = Empty | Two of 'a Tree * 'a * 'a Tree;

fun insert cmp x Empty = Two (Empty, x, Empty)
  | insert cmp x (Two (l,y,r)) = if cmp (x,y) < 0 then
      Two (insert cmp x l, y, r)
    else
      Two (l, y, insert cmp x r);

fun fromList cmp xs = foldl (fn (x, tr) => insert cmp x tr) Empty xs

fun mcmp (x,y) = x-y;

fun dfs Empty = []
  | dfs (Two (l, x, r)) = (dfs l) @ [x] @ (dfs r);

val tr1 = fromList mcmp [6,5,4,1,9,3,5];

dfs tr1;
