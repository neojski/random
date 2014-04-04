datatype 'a node = Two of 'a node * 'a * 'a node
                 | Three of 'a node * 'a * 'a node * 'a * 'a node
                 | Empty;

signature COMPARABLE = sig
  type t;
  val cmp: t*t -> order
end;

signature DICT = sig
  structure Key:COMPARABLE;

  type 'vt dict;

  val empty: 'vt dict;
  val insert: (Key.t * 'vt) * 'vt dict -> 'vt dict;
  val lookup: (Key.t * 'vt dict) -> 'vt option;
end;

signature OSET = sig
  structure Key:COMPARABLE;

  type oset;

  val empty: oset;
  val insert: Key.t * oset -> oset;
  val member: Key.t * oset -> bool;
end;

datatype 'b Propagate = Good of 'b | PropagateUp of 'b;

signature SPEC = sig
  structure Key:COMPARABLE;
  type 'vT entryT;
  type 'vT resultT;

  val extractKey: 'vT entryT -> Key.t;
  val updateE: 'vT entryT node * 'vT entryT -> 'vT entryT node Propagate;
  val lookupE: 'vT entryT option -> 'vT resultT;
end;

functor TFrame(structure Spec:SPEC) = struct
  type 'vt frame = 'vt Spec.entryT node;
  val empty = Empty
  val cmp3 = Spec.Key.cmp;

  fun lookup (key,  tree) = let
    fun lookup' Empty = Spec.lookupE NONE
      | lookup' (Two (t1, e, t2)) = (case cmp3 (key, Spec.extractKey e) of
          LESS => lookup' t1
        | EQUAL => Spec.lookupE (SOME e)
        | GREATER => lookup' t2
      )
      | lookup' (Three (t1, e, t2, f, t3)) = lookup' (Two (t1, e, Two (t2, f, t3)))
  in lookup' tree end;

  fun insert (entry,  tree) = let
    fun unpack (Good x) = x
      | unpack (PropagateUp x) = x;

    fun fix2L (Good l) y r = Good (Two (l, y, r))
      | fix2L (PropagateUp (Two (t1, a, t2))) b t3 = Good (Three (t1, a, t2, b, t3))

    fun fix2R l y (Good r) = Good (Two (l, y, r))
      | fix2R t1 a (PropagateUp (Two (t2, b, t3))) = Good (Three (t1, a, t2, b, t3))

    fun fix3L (Good t1) x t2 y t3 = Good (Three (t1, x, t2, y, t3))
      | fix3L (PropagateUp t1) x t2 y t3 = PropagateUp (Two (t1, x, Two (t2, y, t3)))

    fun fix3R t1 x t2 y (Good t3) = Good (Three (t1, x, t2, y, t3))
      | fix3R t1 x t2 y (PropagateUp t3) = PropagateUp (Two (Two (t1, x, t2), y, t3))

    fun fix3C t1 x (Good t2) y t3 = Good (Three (t1, x, t2, y, t3))
      | fix3C t1 x (PropagateUp (Two (t2, y, t3))) z t4 = PropagateUp (Two (Two(t1, x, t2), y, Two(t3, z, t4)))

    fun insert' x Empty = Spec.updateE (Empty, entry)
      | insert' x (Two (l, y, r)) = (case cmp3 (Spec.extractKey x, Spec.extractKey y) of
          LESS => fix2L (insert' x l) y r
        | EQUAL => Spec.updateE ((Two (l, y, r)), entry)
        | GREATER => fix2R l y (insert' x r)
      )

      | insert' x (Three (t1, y, t2, z, t3)) = (case cmp3 (Spec.extractKey x, Spec.extractKey y) of
          LESS => fix3L (insert' x t1) y t2 z t3
        | EQUAL => Spec.updateE ((Three (t1, y, t2, z, t3)), entry)
        | GREATER => (case cmp3 (Spec.extractKey x, Spec.extractKey z) of
              LESS => fix3C t1 y (insert' x t2) z t3
            | EQUAL => Spec.updateE ((Three (t1, y, t2, z, t3)), entry)
            | GREATER => fix3R t1 y t2 z (insert' x t3)
          )
      )
  in unpack (insert' entry tree) end;
end;

functor DSpec (structure KeyS:COMPARABLE):SPEC = struct
  structure Key = KeyS;

  type 'vT entryT = KeyS.t * 'vT
  type 'vT resultT = 'vT option

  val empty = Empty
  fun extractKey (key, value) = key
  fun updateE (Empty, entry) = PropagateUp (Two (Empty, entry, Empty))
    | updateE (Two (t1, x, t2), entry) = Good (Two (t1, entry, t2))
    | updateE (Three (t1, x, t2, y, t3), entry) = (case KeyS.cmp (extractKey x, extractKey entry) of
        EQUAL => Good (Three (t1, entry, t2, y, t3))
      | otherwise => Good (Three (t1, x, t2, entry, t3))
    )
  fun lookupE NONE = NONE
    | lookupE (SOME (key, value)) = SOME value
end;

functor SSpec (structure KeyS:COMPARABLE):SPEC = struct
  structure Key = KeyS;

  type 'vT entryT = KeyS.t
  type 'vT resultT = bool

  val empty = Empty
  fun extractKey key = key
  fun updateE (Empty, entry) = PropagateUp (Two (Empty, entry, Empty))
    | updateE (Two (t1, x, t2), entry) = Good (Two (t1, entry, t2))
    | updateE (Three (t1, x, t2, y, t3), entry) = (case KeyS.cmp (extractKey x, extractKey entry) of
        EQUAL => Good (Three (t1, entry, t2, y, t3))
      | otherwise => Good (Three (t1, x, t2, entry, t3))
    )
  fun lookupE NONE = false
    | lookupE (SOME key) = true
end;

(* example *)
(*
functor TDict(structure KeyS:COMPARABLE):>DICT where type Key.t=KeyS.t = struct
  structure Spec:SPEC=DSpec(structure KeyS=KeyS);
  structure Frame= TFrame(structure Spec= Spec);

  structure Key:COMPARABLE=KeyS;
  type 'vt dict= 'vt Frame.frame;

  val empty= Frame.empty;
  val insert= Frame.insert;
  val lookup= Frame.lookup;
end;

functor TSet(structure KeyS:COMPARABLE):>OSET where type Key.t=KeyS.t = struct
  structure Spec:SPEC=SSpec(structure KeyS=KeyS);
  structure Frame= TFrame(structure Spec= Spec);

  structure Key:COMPARABLE=KeyS;
  type oset= unit Frame.frame;

  val empty= Frame.empty;
  val insert= Frame.insert;
  val member= Frame.lookup;
end;

structure cInt: COMPARABLE = struct
  type t = int;
  val cmp = Int.compare;
end;

structure TD = TDict(structure KeyS = cInt);
structure TS = TSet(structure KeyS = cInt);
*)
