open Core

module A = struct

end

let y = { hello }
let x = [ hello]

module A = String_id.Make (struct let module_name = "A" end) ()
module B = String_id.Make (struct let module_name = "B" end) ()
module C = String_id.Make (struct let module_name = "C" end) ()

module Path = struct
  type t =
    | A of A.t
    | B of A.t * B.t
    | C of A.t * B.t * C.t
  [@@deriving sexp]

  let parse x =
    let aux x f return =
      match String.lsplit2 ~on:'/' x with
      | None -> return (f x)
      | Some (x, rest) -> f x, rest
    in
    With_return.with_return (fun { return } ->
        let (a, rest) = aux x A.of_string (fun a -> return (A a)) in
        let (b, rest) = aux rest B.of_string (fun b -> return (B (a, b))) in
        let (c, rest) = aux rest C.of_string (fun c -> return (C (a, b, c))) in
        ignore (c, rest);
        assert false
      )

  let parse x =
    let aux of_string return (str, acc) =
      match String.lsplit2 ~on:'/' str with
      | None -> return (acc, of_string str)
      | Some (x, rest) -> rest, (acc, of_string x)
    in
    With_return.with_return (fun { return } ->
        let () =
          (x, ())
          |> aux A.of_string (fun ((), a) -> return (A a))
          |> aux B.of_string (fun (((), a), b) -> return (B (a, b)))
          |> aux C.of_string (fun ((((), a), b), c) -> return (C (a, b, c)))
          |> ignore (* we throw away the partially parsed values here *)
        in
        raise_s [%message "Failed to parse" (x : string)]
      )
end

let command =
  let open Command.Let_syntax in
  let%map_open () = return ()
  in
  fun () ->
    printf !"%{sexp:Path.t}\n" (Path.parse "a");
    printf !"%{sexp:Path.t}\n" (Path.parse "a/b");
    printf !"%{sexp:Path.t}\n" (Path.parse "a/b/c");
    printf !"%{sexp:Path.t}\n" (Path.parse "a/b/c/d");
  ;;

let () = Command.run (Command.basic ~summary:"" command)

let n x =
match x with
  | Test ->
    let x = in
    1 + ( match x with
        | X -> 1
        | Y -> 2)

