open! Core
open Async

let with_state f =
  let state = ref 0 in
  let%bind result = 
  Monitor.try_with_or_error (fun () ->
      f (fun () -> incr state; !state)
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
        printf "test: %d" (gen ());
        let%bind () = [%expect {| test: 1 |}] in
        if true then failwith "simulate failure";
        printf "test";
        let%bind () = [%expect {| DID NOT REACH THIS PROGRAM POINT |}] in
        Deferred.unit
      )
  in
  let%bind () = [%expect {|
    ((state 1)
     (error
      (monitor.ml.Error (Failure "simulate failure")
       ("<backtrace elided in test>" "Caught by monitor try_with_or_error"))))|}]
  in
  Deferred.unit
