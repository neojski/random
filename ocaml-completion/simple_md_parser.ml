open Core

module Token = struct
  type t =
    | Minuses of { pos : int }
    | Whitespace of { pos : int }
    | Text of { pos : int ; data : string }
  [@@deriving sexp]

  let is_text = function
    | Text _ -> true
    | _ -> false
end

module Paragraph = struct
  type t =
    | Header of string
    | Text of string
  [@@deriving sexp]

  let is_header = function
    | Header _ -> true
    | _ -> false

  let is_text = function
    | Text _ -> true
    | _ -> false
end

let tokenize s =
  List.mapi (String.split s ~on:'\n') ~f:(fun pos line ->
      if String.is_empty (String.strip line)
      then Token.Whitespace { pos }
      else if String.is_empty (String.strip line ~drop:(fun c -> c = '-'))
      then Minuses { pos }
      else Text { pos; data = line }
    )

let parse_paragraph tokens =
  let p, rest = List.split_while tokens ~f:Token.is_text in
  let text =
    List.map p ~f:(function
        | Text { pos = _; data } -> data
        | _ -> assert false
      )
    |> String.concat ~sep:"\n"
  in
  match rest with
  | [] -> Paragraph.Text text, []
  | x :: xs ->
    match x with
    | Minuses { pos } ->
      (* CR-tkolodziejski: Test this *)
      (if String.is_empty text
      then raise_s [%message "Header has no contents" (pos : int)]);
      Header text, xs
    | Whitespace _ -> Text text, xs
    | Text _ -> assert false
;;

let parse_paragraphs tokens =
  let rec aux acc tokens =
    match tokens with
    | [] -> acc
    | _ ->
      let p, rest = parse_paragraph tokens in
      aux (p :: acc) rest
  in
  aux [] tokens |> List.rev
;;

let parse s =
  let tokens = tokenize s in
  let paragraphs = parse_paragraphs tokens in
  (* Invariant: first elemnt of paragraphs is a header. *)
  let rec aux acc paragraphs =
    match paragraphs with
    | [] -> List.rev acc
    | p :: rest ->
      match p with
      | Paragraph.Text _ -> assert false
      | Header header ->
        let contents, rest = List.split_while rest ~f:Paragraph.is_text in
        aux ((header, contents) :: acc) rest
  in
  let paragraphs = List.drop_while paragraphs ~f:(fun x -> not (Paragraph.is_header x)) in
  aux [] paragraphs


  
let%expect_test _ =
  let s =
    {|Test1
---
Something

Test2
-----
Test3
----

Data
---
Multi
Line

Contents
|}
  in
  let tokens = tokenize s in
  printf !"%{sexp:Token.t list}\n" tokens;
  [%expect {||}];
  
  printf !"%{sexp:(string * Paragraph.t list) list}\n" (parse s);
  [%expect {||}]

