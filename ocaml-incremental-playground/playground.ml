open! Core
open Async
open Core_bench

module Incr = Incremental.Make ()
module Incr_map = Incr_map.Make(Incr)

module Notout = struct
  type t =
    { key: int
    ; v : int
    }
end

let t2 = Bench.Test.create_with_initialization ~name:"test" (fun `init -> 
    let map =
      List.init 1000000 ~f:(fun i ->
          let key = i in
          key, { Notout.key; v = i})
      |> Int.Map.of_alist_exn
    in
    fun () ->
      let total =
        Map.data map |> List.map ~f:(fun { Notout.key = _; v} -> v) |> List.sum (module Int) ~f:Fn.id
      in
      printf "%d\n" total;
  )

let t1 = Bench.Test.create_with_initialization ~name:"test" (fun `init -> 
    let map =
      List.init 1000000 ~f:(fun i ->
          let key = i in
          key, { Notout.key; v = i})
      |> Int.Map.of_alist_exn
    in
    let var = Incr.Var.create map in
    let inc = Incr.Var.watch var in
    let even = 
      Incr_map.filter_mapi inc ~f:(fun ~key:_ ~data:notout ->
          if notout.key % 2 = 0
          then Some notout
          else None
        )
    in
    let even_o = Incr.observe even in

    let total =
      Incr_map.unordered_fold
        even
        ~init:0
        ~add:(fun ~key:_ ~data:{Notout.key = _; v} acc -> acc + v)
        ~remove:(fun ~key:_ ~data:{Notout.key = _; v} acc -> acc - v)
    in

    let by_value =
      Incr_map.unordered_fold
        even
        ~init:Int.Map.empty
        ~add:(fun ~key:_ ~data:({Notout.key = _; v} as notout) acc ->
            Map.add_multi acc ~key:v ~data:notout
          )
        ~remove:(fun ~key:_ ~data:{Notout.key = _; v} acc ->
            Map.remove_multi acc v
          )
    in
    ignore by_value;

    let total_o = Incr.observe total in
    let by_value_o = Incr.observe by_value in

    Incr.stabilize ();

    fun () ->
      (* modify something from the map *)

      for i = 0 to 100000 do
        Incr.Var.set var (Map.set map ~key:i ~data:{Notout.key = 2; v = i + 1});
      done;
      Incr.stabilize ();

      let v = Incr.Observer.value_exn even_o  in
      let total_v = Incr.Observer.value_exn total_o  in
      let by_value_v = Incr.Observer.value_exn by_value_o  in

      printf "%d %d %d\n" (Map.length v) total_v (Map.length by_value_v);
  )


let tests = [  t1]

let command = Bench.make_command tests
let () = Command.run command
