open Core

module Signature = struct
  module T = struct
  type t =
    | Base of string
    | Record of field list
  and field =
    { field_name : string
    ; signature : t
    }
  [@@deriving sexp]
  end
  include T
  include Sexpable.To_stringable (T)

  let field t field_name =
    match t with
    | Base _ -> failwith "Expected Record signature"
    | Record l ->
      List.find_map_exn l ~f:(fun { field_name = field_name'; signature } ->
          if String.equal field_name field_name'
          then (Some signature)
          else None
        )
end

module A = struct
  module Stable = struct
    module V1 = struct
      type t = int [@@deriving bin_shape]
    end
    module V2 = struct
      type t = float [@@deriving bin_shape]

      let to_v1 (t : t) : V1.t = Float.to_int t
    end
    module Latest = V2
    
    let sexp_of ~signature (t : Latest.t) =
      (* This could be derived from V1 and V2 if they are registered somehwere *)
      match (signature : Signature.t) with
      | Base "698cfa4093fe5e51523842d37b92aeac" ->
        [%sexp_of: int] (V2.to_v1 t)
      | Base "1fd923acb2dd9c5d401ad5b08b1d40cd" ->
        [%sexp_of: float] t
      | _ ->
        raise_s [%message "Unexpected signature" (signature : Signature.t)]
  end
end

module X = struct
  module Quasi_stable = struct
    module V1 = struct
      (* This is a type that was here but is not anymore and we're just modifying it.

         What do we need to know that everything will work all right?
         - the field names are are identical
         - the order is the same
         - only signatures have been changed

         These properties should be easily verifiable so (possibly) when you
         modify a type without minting a new version you should probably do:
         1. copy the type into t_v1 (if [t_v1] already exists use [t_v2])
         2. write a test

         Please note that [Signature.t]s will be derived automatically. Please note there are probably two kinds of types:
         - Stable, that we don't want to modify (like, Int that we don't want to add [@@deriving quasi_stable] to)
         - Quasi_stable, that will have [@@deriving quasi_stable]

         Then the [@@deriving quasi_stable] would generate signature:
         - if type on the rhs is Stable then use its [%bin_digest] for signature
         - if type is Quasi_stable then it has signature function
      *)
      type t_v1 =
        { a1 : A.Stable.V1.t
        }
      [@@deriving fields]

      type t =
        { a1 : A.Stable.V2.t
        }
      [@@deriving fields]

      let signature =
        let w acc field =
          { Signature.
            field_name = Field.name field
          ; signature = Signature.Base [%bin_digest: A.Stable.V2.t]
          } :: acc
        in
        Fields.fold ~init:[] ~a1:w
        |> Signature.Record
      ;;

      let signature_old =
        let w acc field =
          { Signature.
            field_name = Field.name field
          ; signature = Signature.Base [%bin_digest: A.Stable.V1.t]
          } :: acc
        in
        Fields.fold ~init:[] ~a1:w
        |> Signature.Record
      ;;
    end

    module Latest = V1

    let sexp_of ~signature t =
      let w acc field =
        let name = Field.name field in
        (name, A.Stable.sexp_of (Field.get field t) ~signature:(Signature.field signature name))
        :: acc
      in
      Latest.Fields.fold ~init:[] ~a1:w
      |> [%sexp_of: (string * Sexp.t) list]
    ;;

    let value x = { Latest.a1 = x }
  end
end

module Y = struct
  module Quasi_stable = struct
    module V1 = struct
      type t =
        { x1 : X.Quasi_stable.V1.t
        ; x2 : X.Quasi_stable.V1.t
        ; x3 : X.Quasi_stable.V1.t
        }
      [@@deriving fields]

      let signature =
        let w acc field =
          { Signature.
            field_name = Field.name field
          ; signature = X.Quasi_stable.V1.signature
          } :: acc
        in
        Fields.fold ~init:[]
          ~x1:w
          ~x2:w
          ~x3:w
        |> Signature.Record
      ;;

      (* This wouldn't exist in the current version of the program. One would
         ask the previous binary as what its signature is and use it to
         downconvert configs. *)
      let signature_old =
        let w acc field =
          { Signature.
            field_name = Field.name field
          ; signature = X.Quasi_stable.V1.signature_old
          } :: acc
        in
        Fields.fold ~init:[]
          ~x1:w
          ~x2:w
          ~x3:w
        |> Signature.Record
      ;;
    end

    module Latest = V1

    let value =
      { Latest.x1 = X.Quasi_stable.value 7.1
      ; x2 = X.Quasi_stable.value 7.2
      ; x3 = X.Quasi_stable.value 7.3
      }
    ;;

    let sexp_of ~signature t =
      let w acc field =
        let name = Field.name field in
        (name, X.Quasi_stable.sexp_of (Field.get field t) ~signature:(Signature.field signature name))
        :: acc
      in
      Latest.Fields.fold ~init:[] ~x1:w ~x2:w ~x3:w
      |> [%sexp_of: (string * Sexp.t) list]
    ;;

    let print ~signature value =
      Core.printf !"signature:\n%{Signature}:\nresult:\n%{Sexp}\n\n" signature (sexp_of ~signature value)
    ;;

    print ~signature:Latest.signature value ;;
    print ~signature:Latest.signature_old value ;;
  end
end
