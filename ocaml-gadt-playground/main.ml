open! Core
open! Async

module To_string = struct
  type partial = [ `partial ]
  type full = [ `full ]

  type ('a, _) t =
    | None : (_, partial) t
    | Some : ('a -> string) -> ('a, full) t
end

type 'a full = { of_string : string -> 'a ; to_string : 'a -> string }
type 'a partial = { of_string : string -> 'a }

type ('a, _) t =
  | Full :    'a full -> ('a, To_string.full) t
  | Partial : 'a partial -> ('a, To_string.partial) t

let create (type a) ~(of_string :(string -> 'a)) ~(to_string: ('a, a) To_string.t) : ('a, a) t =
  match to_string with
  | None -> Partial { of_string }
  | Some to_string -> Full {of_string; to_string}

let requires_full (t : (_, To_string.full) t) =
  match t with
  | Full _ -> ()

let x = create ~of_string:Int.of_string ~to_string:None
let y = create ~of_string:Int.of_string ~to_string:(Some Int.to_string)
