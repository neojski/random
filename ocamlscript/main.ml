open Core
open Async

let main () =
  let%bind contents = Reader.contents (Lazy.force Reader.stdin) in
  printf "%s" (Test.f contents);
  return ()

let () =
  let param =
    let open Command.Let_syntax in
    let%map_open () = return () in
    main
  in
  let command =
    Command.async ~summary:"TODO" param
  in
  Command.run command

