open Core

module Foo = struct
  type t =
    { x: string
    ; y: int
    }
  [@@deriving sexp]

  let params =
    let%map_open.Command x = flag "-x" ~doc:"" (required string)
    and y = flag "-y" ~doc:"" (required int) in
    { x ; y }

  let api ~x ~y =
    { x; y }
end

let main ({ x; y } : Foo.t) =
  printf "%s %d" x y

let flags =
  let%map_open.Command foo = Foo.params in
  fun () ->
    main foo
;;

let sexp =
  let%map_open.Command foo = flag "-sexp" ~doc:"" (required (Arg_type.create (fun str -> str |> Sexp.of_string |> Foo.t_of_sexp))) in
  fun () ->
    main foo
;;

let () = Command.run (Command.group ~summary:"" [ "flags", Command.basic ~summary:"" flags ; "sexp", Command.basic ~summary:"" sexp ])
