open Core
open Async

let main () =
  let test ~debug reader writer =
    let debug x = ksprintf (fun str -> printf "%s: %s" debug str) x in
    let pipe_w = Writer.pipe writer in
    don't_wait_for (
      let%map () = Pipe.closed pipe_w in
      debug "[Pipe.closed] done, pipe is closed: %b\n%!" (Pipe.is_closed pipe_w));
    don't_wait_for (
      let%map () = Reader.transfer reader pipe_w in
      debug "[Reader.transfer] done\n%!");
    don't_wait_for (
      let%map () = Writer.close_finished writer in
      debug "[Writer.close_finished] done\n%!");
    let%bind () =
      debug "[Writer.close] about to be called\n%!";
      let%map () = Writer.close writer in
      debug "[Writer.close] done\n%!";
    in
    return ()
  in
  (* I think these should be the same but are not. *)
  let%bind () =
    let%bind reader = Reader.open_file "/tmp/reader" in
    let%bind writer = Writer.open_file "/tmp/writer" in
    test ~debug:"files" reader writer
  in
  let%bind () =
    let%bind writer = Writer.open_file "/tmp/writer" in
    test ~debug:"stdin" (Lazy.force Reader.stdin) writer
  in
  return ()
  
let command = 
  let open Command.Let_syntax in
  let%map_open () = return () 
  in
  main
;;

let () =
  Command.run (Command.async ~summary:"" command)
