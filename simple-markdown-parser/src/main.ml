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
let all = many1 section

let eval str =
  let result =
    Buffered.parse all
    |> (fun s -> Buffered.feed s (`String (str ^ "\n\n")))
    |> (fun s -> Buffered.feed s `Eof)
  in
  match result with
  | Partial _ -> Or_error.error_s [%message "Partial result"]
  | Done (_, v) -> Ok v
  | Fail (u, _, msg) ->
    Or_error.error_s [%message "Failed to parse"
        (msg : string)
        (* TODO: this is probably silly *)
        ~buffer:(Bigstringaf.substring u.buf ~off:0 ~len:u.off : string)
        ~off:(u.off : int)
        ~len:(u.len : int)]

let%test_module _ =
  (module struct
    open Core
    let%expect_test "_" =
      let test str =
        printf !"%{sexp: (string * string list) list Or_error.t}\n" (eval str)
      in
      test
{|Header
------
Contents|};
      [%expect {| (Ok ((Header (Contents)))) |}];
      test
{|Header
------
Content

With

Multiple
Lines|};
      [%expect {|
        (Ok ((Header (Content With  "Multiple\
                                   \nLines")))) |}];
      test
{|Multi
line
header
------
And some contents|};
      [%expect {|
        (Ok (( "Multi\
              \nline\
              \nheader" ("And some contents")))) |}];
      test
{|Header
---
List:
- item1
- item2|};
      [%expect {|
        (Ok ((Header ( "List:\
                      \n- item1\
                      \n- item2")))) |}];
      test
        {|Error|};
      [%expect {|
        (Error
         ("Failed to parse" (msg "expected minuses") (buffer  "Error\
                                                             \n\
                                                             \n")
          (off 7) (len 0))) |}]
  end)


let command =
  let open Command.Let_syntax in
  let param =
    let%map_open test = anon ("filename" %: string) in
    fun () ->
      let open Async in
      let%map contents = Reader.file_contents test in
      printf !"%{sexp: (string * string list) list Or_error.t}\n" (eval contents)
  in
  Command.async ~summary:"test" param
