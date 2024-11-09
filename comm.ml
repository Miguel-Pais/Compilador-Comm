(** The main program. *)

module CalcVar = Helper.Main (struct
  let name = "comm"

  type command = Syntax.command

  type environment = unit
  (** There is no top-level environment as all variables are local *)

  (** Should we show compiled code? *)
  let show_code = ref false
  let show_code_web = ref false


  (** RAM size *)
  let ram_size = ref 64

  (** Execute code *)
  let execute_code = ref false

  let options =
    [
      ( "--ram",
        Arg.Set_int ram_size,
        Format.sprintf "<size> RAM size (default: %d)" !ram_size );
      ("--execute", Arg.Set execute_code, " Execute compiled code");
      ("--code", Arg.Set show_code, " Print compiled code");
      ("--web", Arg.Set show_code_web, "Print compiled code in web assembly")
    ]

  (** At the beginning no variables are defined. *)
  let initial_environment = ()

  let file_parser = Some (fun _ -> Parser.file Lexer.token)
  let toplevel_parser = Some (fun _ -> Parser.program Lexer.token)

  (** The command that actually executes a command. It accepts an argument which we can
      ignore, a flag indicating whether we are in ineractive mode, an environment, and a
      command to be excuted. *)
  let exec _ cmd =
    let code = Compile.compile cmd in
    if !show_code then Format.printf "%t@." (Machine.print_code code);
    if !show_code then Format.printf "%t@." (Machine.print_code_web code);
    if !execute_code then
      let state = Machine.make code !ram_size in
      try Machine.run state
      with Machine.Error err ->
        Helper.error ~kind:"runtime error" "%t" (Machine.print_error err)
end)
;;

CalcVar.main ()
