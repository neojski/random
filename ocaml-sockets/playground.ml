open! Core
open! Async

let main_server ~close_sender () =
  printf "main\n";
  let where_to_listen = Tcp.Where_to_listen.of_port 1234 in
  let%bind server = 
    Tcp.Server.create_sock
      where_to_listen
      ~on_handler_error:`Raise
      (fun address socket ->
         printf !"address: %{sexp:Socket.Address.Inet.t}\n" address;

         let fd = Socket.fd socket in 
         let reader = Reader.create fd in
         let writer = Writer.create fd in

         if close_sender
         then Socket.shutdown socket `Send
         else (

         (*
         don't_wait_for (
           let%map () = Reader.transfer (Lazy.force Reader.stdin) (Writer.pipe writer) in
           printf "stdin transfer finished\n"
         );
         *)
           Clock.every
             ~stop:(Writer.close_finished writer)
             (sec 2.)
             (fun () -> Writer.writef writer !"%{Time}\n" (Time.now ()))
         );

         let%bind () =
           Reader.transfer reader (Writer.pipe (Lazy.force Writer.stdout))
         in
         let%bind () = Writer.close writer in
         printf "incoming data transfer finished (file descriptor closed: %b)\n" (Reader.is_closed reader);
         return ()
      )
  in
  ignore server;
  Deferred.never ()

let main_client () =
  (* There's [Tcp.connect] but we use low-level functions just for fun. *)
  let socket = Socket.create Socket.Type.tcp in
  let%bind socket =
    let%bind inet_addr = Unix.Inet_addr.of_string_or_getbyname "127.0.0.8" in
    let address = Socket.Address.Inet.create inet_addr ~port:8888 in
    printf !"binding to: %{sexp: Socket.Address.Inet.t}\n" address;
    Socket.bind socket address
  in
  let%bind socket =
    let%bind inet_addr = Unix.Inet_addr.of_string_or_getbyname "127.0.0.1" in
    let address = Socket.Address.Inet.create inet_addr ~port:1234 in
    printf !"connecting to: %{sexp: Socket.Address.Inet.t}\n" address;
    Socket.connect socket address
  in
  let fd = Socket.fd socket in
  let reader = Reader.create fd in
  let writer = Writer.create fd in
  don't_wait_for (
    let%map () =
      Reader.transfer
        reader
        (Writer.pipe (Lazy.force Writer.stdout))
    in
    (* This is worth noting:

       We detect that the remote side had partially shutdown (see:
       [Socket.shutdown]) the socket by receiving EOF here. Please note that
       [Reader] does _not_ get closed becase the socket does not get closed when
       the remote site paritally shuts the connection down. I think the reason
       for that is that we have single socket (file descriptor) for reading and
       writing.
    *)
    printf "incoming data transfer finished (file descriptor closed: %b)\n" (Reader.is_closed reader)
  );
  don't_wait_for (Reader.transfer (Lazy.force Reader.stdin) (Writer.pipe writer));
  Deferred.never ()

let server =
  let open Command.Let_syntax in
  let%map_open close_sender =
    flag
      "-close-sender"
      ~doc:"BOOL half-close TCP connection from this side. Will send FIN"
      (required bool)
  in
  main_server ~close_sender
;;

let client = 
  let open Command.Let_syntax in
  let%map_open () = return () 
  in
  main_client
;;

let () =
  Command.run
    (Command.group ~summary:""
       [ "server", Command.async ~summary:"" server
       ; "client", Command.async ~summary:"" client
       ])
