open Core
open Async

let friend =
  let open Command.Let_syntax in

  let module Friend_name : sig
    include Stringable

    val key : t Univ_map.Multi.Key.t
    val arg_type : t Command.Arg_type.t
  end = struct
    include String

    let key = Univ_map.Multi.Key.create ~name:"friend_name" sexp_of_t
    let arg_type =
      let complete _ ~part =
        ["friend_a1"; "friend_a2"; "friend_b"]
      in
      Command.Arg_type.create ~complete ~key (fun x -> (x : t))
  end in

  let line =
    let complete map ~part =
      let lines = ["line1"; "line2"; "line3"] in
      match Univ_map.Multi.find map Friend_name.key with
      | [friend_name] ->
          List.map lines ~f:(fun line -> sprintf !"%{Friend_name}__%s" friend_name line)
      | _ -> failwith "Didn't expect two friends"
    in
    Command.Arg_type.create ~complete (fun x -> x)
  in

  let%map_open
    date = flag "-date" ~doc:"test" (optional_with_default (Date.today ~zone:(Lazy.force Time.Zone.local)) date)
  and
    friend_name = anon ("FRIEND_NAME" %: Friend_name.arg_type)
  and
    line = anon ("LINE" %: line)
  in
  fun () ->
    printf !"/j/prod/friend/%{Friend_name}/%s/%{Date}\n" friend_name line date;
    Deferred.unit
;;

let () =
  Command.run
    (Command.group ~summary:"cd magic" ["friend", Command.async ~summary:"friend" friend])
