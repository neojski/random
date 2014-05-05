type name = char list
datatype term = Fun of name * term list | Var of name
type substitution = (name * term) list

exception UnifException

fun zip (x::xs, y::ys) = (x, y) :: (zip (xs, ys))
  | zip ([], []) = [];

fun applySub (name, term) (Var n) = if name <> n then Var n else term
  | applySub (name, term) (Fun (n, ts)) = Fun (n, List.map (fn t => applySub (name, term) t) ts)

fun applySubs subs t = List.foldl (fn (sub, t) => applySub sub t) t subs;

fun unify t1 t2 = let
  fun unifyArgs [] subs = subs
    | unifyArgs (p :: ps) subs = let
      val p1 = #1 p;
      val p2 = #2 p;

      val subs2 = unify p1 p2;
      val psTransformed = map (fn (p1, p2) => (applySubs subs2 p1, applySubs
      subs2 p2)) ps;
  in unifyArgs psTransformed (subs @ subs2) end;

  fun unify' (Var n1) (Var n2) = [(n1, (Var n2))]
    | unify' (Var n1) (Fun t2) = [(n1, (Fun t2))]
    | unify' (Fun t1) (Var n2) = [(n2, (Fun t1))]
    | unify' (Fun (n1, l1)) (Fun (n2, l2)) = if n1 <> n2 orelse List.length l1 <> List.length l2 then
      raise UnifException
    else
      unifyArgs (zip (l1, l2)) []

in unify' t1 t2 end;


val t1 = Fun ([#"f"],[Var [#"x"],Fun ([#"g"],[Var [#"x"],Var [#"y"]])])
val t2 = Fun ([#"f"],[Fun ([#"h"],[Var [#"y"]]),Var [#"z"]])
val t3 = Fun ([#"f"],[Fun ([#"h"],[Var [#"z"]]),Var [#"z"]])
