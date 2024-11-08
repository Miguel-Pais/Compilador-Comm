open Machine
(** Compilation to machine code. *)

(** Compile the given command. *)


type declaration_type = 
  V of string
 | F of string * int

let rec print_dec_type_list list =
  match list with
  | [] -> Printf.printf "\n"
  | V(x) :: tail
  | F(x,_) :: tail -> (Printf.printf "%s\n" x); print_dec_type_list tail
let compile cmd =
  (* We keep around a context, which is a list of currently valid variables,
     with more recently declared variables at the beginning of the list. *)

  (* Compute the RAM location where variable [x] is stored, given the context [ctx].
     The location of a variable is its de Bruijn level: the first declared variable
     is at location 0, the second at location 1, etc.
  *)
  let location ctx x =
    (*print_dec_type_list ctx;*)
    let rec index k = function
      | [] -> Helper.error ~kind:"compilation error" "unknown variable %s" x
      | V(y) :: ys
      | F(y,_) :: ys -> if x = y then k else index (k - 1) ys
    in
    index (List.length ctx - 1) ctx
  in

  (* Compile an expression in the given context [ctx]. *)
  let rec expression ctx = function
    | Syntax.NewFunc(a, e) -> expression ctx e @ [ Callfunc a ]
    | Syntax.PassArgs (e1,e2)-> expression ctx e2 @ expression ctx e1
    | Syntax.Variable x -> let k = location ctx x in [ GET k ]
    | Syntax.Floating k -> [ FPUSH k ]
    | Syntax.Numeral k -> [ PUSH k ]
    
    | Syntax.FPlus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FADD ]
    | Syntax.FMinus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FSUB ]
    | Syntax.FTimes (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FMUL ]
    | Syntax.FDivide (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FDIV ]
    | Syntax.Plus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ ADD ]
    | Syntax.Minus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ SUB ]
    | Syntax.Times (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ MUL ]
    | Syntax.Divide (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ DIV ]
    (*
    | Syntax.FPlus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> FADD |_ -> (TYPE "adicao") ]
    | Syntax.FMinus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> FSUB |_ -> TYPE "subtracao"]
    | Syntax.FTimes (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> FMUL |_ -> TYPE "multiplicacao"]
    | Syntax.FDivide (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> FDIV |_ -> TYPE "divisao"]
    | Syntax.Plus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> ADD |_ -> TYPE "adicao"]
    | Syntax.Minus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> SUB |_ -> TYPE "subtracao"]
    | Syntax.Times (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> MUL |_ -> TYPE "multiplicacao"]
    | Syntax.Divide (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ match e1, e2 with | Syntax.Floating _, Syntax.Floating _-> DIV |_ -> TYPE "divisao"]
    
    *)
    | Syntax.Remainder (e1, e2) ->
        expression ctx e1 @ expression ctx e2 @ [ MOD ]
  in


  (* Compile a boolean expression in the given context. *)
  let rec boolean ctx = function
    | Syntax.True -> [ PUSH 1 ]
    | Syntax.False -> [ PUSH 0 ]
    | Syntax.Equal (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ EQ ]
    | Syntax.Less (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ LT ]
    | Syntax.And (b1, b2) -> boolean ctx b1 @ boolean ctx b2 @ [ AND ]
    | Syntax.Or (b1, b2) -> boolean ctx b1 @ boolean ctx b2 @ [ OR ]
    | Syntax.Not b -> boolean ctx b @ [ NOT ]
  in


  let rec numargs = function
    | Syntax.Args (_, f) -> 1 + numargs f
    | Syntax.Arg (_) -> 1
  in


  let rec funcargs = function
    | Syntax.Arg (x) -> [ V(x) ]
    | Syntax.Args (x, f) -> V(x) :: funcargs (f)
  in

  (* Compile the given command in the given context [ctx]. *)
  let rec command ctx = function
    | Syntax.Func (x, a, c, c2, ret) ->
      let ctx = V(ret) :: (funcargs a) @ F(x, numargs a) :: ctx in
      let c' = command ctx c in
      let c2' = command ctx c2 in
      [ FuncStart x ] @ c' @ [ Return(x,location (ctx) (ret))] @ c2'

    | Syntax.New (x, e, c) ->
      let e' = expression ctx e in
      let ctx = V(x) :: ctx in
      let c' = command ctx c in
      let k = location ctx x in
      e' @ [ SET k ] @ c'

    | Syntax.Skip -> [ NOOP ]
    | Syntax.Print e -> expression ctx e @ [ PRINT ]
    | Syntax.FPrint e -> expression ctx e @ [ FPRINT ]
    | Syntax.Assign (x, e) -> expression ctx e @ [ SET (location ctx x) ]
    | Syntax.Sequence (c1, c2) -> command ctx c1 @ command ctx c2
    | Syntax.Conditional (b, c1, c2) ->
        let c1' = command ctx c1 in
        let c2' = command ctx c2 in
        boolean ctx b
        @ [ JMPZ (List.length c1' + 1) ]
        @ c1'
        @ [ JMP (List.length c2') ]
        @ c2'
    | Syntax.While (b, c) ->
        let c' = command ctx c in
        let b' = boolean ctx b in
        let n = List.length c' in
        b' @ [ JMPZ (n + 1) ] @ c' @ [ JMP (-(List.length b' + 2 + n)) ]
  in

  Array.of_list (command [] cmd)
