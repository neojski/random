open Core
open Async

let main () =
  (* ~50MB/s. Slow because [In_channel.input_line] allocates. *)
  (* let rec aux () =
   *   match In_channel.input_line_exn In_channel.stdin with
   *   | line ->
   *     print_endline (Int.to_string (String.length line + 1));
   *     aux ()
   *   | exception End_of_file ->
   *     (\* This is ~10% faster than using [input_line]. *\)
   *     ()
   * in
   * aux () *)

  (* ~80MB/s, same as Rust.

     Sadly, ocaml doesn't seem to have non-allocating fast method to read lines
     from stdin so we need to mess with [Iobuf]. *)
  let len = 65000 in
  let buf = Iobuf.create ~len in
  Iobuf.flip_lo buf;

  let rec aux ~read_more =
    match Iobuf.Peek.index buf '\n' with
    | None ->
      if read_more then (
        Iobuf.compact buf; (* this could potentially be faster with some kind of circular buffer *)
        let read_more =
          match Iobuf.input buf In_channel.stdin with
          | Eof -> false
          | Ok -> true
        in
        Iobuf.flip_lo buf;
        aux ~read_more
      ) else ()
    | Some i ->
      print_endline (Int.to_string i); (* please note this is Async, hence buffered *)
      Iobuf.advance buf (i + 1);
      aux ~read_more
  in
  aux ~read_more:true;
  Deferred.unit

let command =
  let open Command.Let_syntax in
  let%map_open () = return ()
  in
  main
;;

let () =
  Command.run (Command.async ~summary:"" command)
