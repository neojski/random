open! Core
open Async

let with_state f =
  let state = ref 1 in
  let%bind result =
  Monitor.try_with_or_error (fun () ->
        f (fun () ->
            let x = !state in
            incr state;
            incr state;
            x)
    )
  in
  match result with
  | Ok () -> Deferred.unit
  | Error error ->
    printf !"%{Sexp#hum}" [%message "" ~state:(!state : int) (error : Error.t)];
    Deferred.unit

let%expect_test "test" =
  let%bind () =
    with_state (fun gen ->
        let num = gen () in
        printf "test: %d" num;
        let%bind () = [%expect {| test: 1 |}] in
        let num = gen () in
        assert (num = 2); (* simulate some complex function that needs num to be 2 and fails *)
        printf "test: %d" (gen ());
        let%bind () = [%expect {| DID NOT REACH THIS PROGRAM POINT |}] in
        Deferred.unit
      )
  in
  (* The test failed, print extra internal state to ease debugging. *)
  let%bind () = [%expect {|
    ((state 5)
     (error
      (monitor.ml.Error "Assert_failure playground.ml:28:8"
       ("<backtrace elided in test>" "Caught by monitor try_with_or_error"))))|}]
  in
  Deferred.unit
