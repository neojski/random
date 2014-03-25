(* C03 *)
(* how list in sml can be done *)
datatype IntList = Nil | Cons of (int*IntList);

fun len Nil = 0
  | len (Cons(_, tail)) = 1 + len tail;

fun addFirst l el = Cons(el, l);

fun addLast Nil el = Cons(el, Nil)
  | addLast (Cons(head, tail)) el = Cons(head, addLast tail el);

fun cat l1 Nil = l1
  | cat l1 (Cons(head, tail)) = cat (addLast l1 head) tail;

fun rev Nil = Nil
  | rev (Cons(head, tail)) = addLast (rev tail) head;

fun lFilter pred Nil = Nil
  | lFilter pred (Cons(head, tail)) = if pred head then 
    Cons(head, lFilter pred tail)
  else
    lFilter pred tail;

fun lMap map Nil = Nil
  | lMap map (Cons(head, tail)) = Cons(map head, lMap map tail);

val x = Nil;
val x = addFirst x 3;
val x = addFirst x 2;
val x = addFirst x 1;

val y = Nil;
val y = addLast y 4;
val y = addLast y 5;
val y = addLast y 6;

fun last (el::nil) = el
  | last (el::rest) = last rest;

(* linear version *)
fun rev2 l = let
  fun doRev nil res = res
    | doRev (el::rest) res = doRev rest (el::res)
in
  doRev l nil
end;
