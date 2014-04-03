(* bfs implementation according to Chris Okasaki:
http://www.cs.tufts.edu/~nr/cs257/archive/chris-okasaki/breadth-first.pdf *)

datatype 'a Tree = Leaf | Branch of 'a Tree * 'a * 'a Tree

signature QUEUE =
sig
  type 'a Queue
  val empty: 'a Queue
  val isEmpty: 'a Queue -> bool
  val enq: 'a * 'a Queue -> 'a Queue
  val deq: 'a Queue -> 'a * 'a Queue
end;

(*structure QueueSlow: QUEUE = struct
  type 'a Queue = 'a list;

  val empty = [];
  fun enq (el, xs) = el::xs;
  fun deq [] = raise Empty
    | deq [y] = (y, [])
    | deq (y::ys) = let
        val (res, ys') = deq ys;
      in (res, y::ys') end;

  fun isEmpty [] = true
    | isEmpty _ = false;
end;*)

structure Queue: QUEUE = struct
  type 'a Queue = 'a list * 'a list;

  val empty = ([], []);
  fun enq (el, (x, y)) = (el :: x, y);
  fun deq ([], []) = raise Empty
    | deq (xs, []) = deq ([], rev xs)
    | deq (xs, y::ys) = (y, (xs, ys));

  fun isEmpty ([], []) = true
    | isEmpty _ = false;
end;

fun bfnum T = let
  fun bfnum' i q =
    if Queue.isEmpty q then Queue.empty
    else case Queue.deq q of
      (Leaf, ts) => Queue.enq (Leaf, bfnum' i ts)
    | (Branch (l, x, r), ts) => let
        val q2 = Queue.enq (r, Queue.enq (l, ts))
        val q3 = bfnum' (i+1) q2
        val (r2, q4) = Queue.deq q3
        val (l2, q5) = Queue.deq q4
      in Queue.enq (Branch (l2, (x, i), r2), q5) end
  fun unpack q = let
    val (el, q') = Queue.deq q;
  in el end
in
  unpack (bfnum' 0 (Queue.enq (T, Queue.empty)))
end;

(*val res = bfnum (Branch(Branch(Branch(Leaf,10,Leaf),20,Branch(Leaf,30,Leaf)),40,Branch(Branch(
   Leaf,50,Leaf),60,Branch(Leaf,70,Leaf))));*)
