open Core
open Async
open Angstrom

type token =
  | Empty_line
  | Minuses
  | Text of string

let tokenize =
  choice
    [ (take_while1 (Char.equal '-') *> end_of_line >>| fun () -> Minuses) 
    ; (end_of_line >>| fun () -> Empty_line)
    ; (take_while (fun c -> not (Char.equal c '\n')) <* end_of_line) >>| fun x -> Text x
    ]

let text =
  tokenize
  >>= function
  | Text x -> return x
  | _ -> fail "expected text"

let minuses =
  tokenize
  >>= function
  | Minuses -> return ()
  | _ -> fail "expected minuses"

let texts1 = many1 text >>| String.concat ~sep:"\n"

let header = texts1 <* minuses
let paragraph = texts1 <* end_of_line
let body = many paragraph

let section = lift2 (fun x y -> (x, y)) header body
let all = many section

let eval str =
  Buffered.parse all
  |> (fun s -> Buffered.feed s (`String (str ^ "\n")))
  |> (fun s -> Buffered.feed s `Eof)
  |> Buffered.state_to_result 

let%expect_test "_" =
  let test str =
    printf !"%{sexp: ((string * string list) list, string) Result.t}\n" (eval str)
  in
  test
    "Header\n\
     ------\n\
     Contents";
  [%expect {|(Ok ((Header ())))|}]

let command =
  let open Command.Let_syntax in
  let param =
    let%map_open test = anon ("filename" %: string) in
    fun () ->
      let open Async in
      let%map contents = Reader.file_contents test in
      printf !"%{sexp: ((string * string list) list, string) Result.t}\n" (eval contents)
  in
  Command.async ~summary:"test" param
