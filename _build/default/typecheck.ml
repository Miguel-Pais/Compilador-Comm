open Machine
(** Compilation to machine code. *)

(** Compile the given command. *)



type declaration_type = 
  V of string * bool * int * bool
 | F of string * int * int


let rec print_dec_type_list list =
  match list with
  | [] -> Printf.printf "\n"
  | V(x,ispar, stackpos, isfloat) :: tail -> (Printf.printf "Variable %s at stack frame offset %d is argument %b of type %s\n" x stackpos ispar (if isfloat then "float" else "int")); print_dec_type_list tail
  | F(x,a, stackpos) :: tail -> (Printf.printf "Function %s at stack frame offset %d has %d arguments\n" x stackpos a); print_dec_type_list tail


let print_type_error_at_pos (x : Lexing.position)=
  Printf.printf "Type error in file %s, row: %d | column: %d\n" x.pos_fname x.pos_lnum (x.pos_cnum-x.pos_bol) 


let compile cmd =
  (* We keep around a context, which is a list of currently valid variables,
     with more recently declared variables at the beginning of the list. *)

  (* Compute the RAM location where variable [x] is stored, given the context [ctx].
     The location of a variable is its de Bruijn level: the first declared variable
     is at location 0, the second at location 1, etc.
  *)


  let rec numCallArgs = function
  | Syntax.PassArgs (_, e1) -> 1 + numCallArgs e1
  | _ -> 1
  in

  let rec numAvailableArgsInFunc funcname ctx =
    match ctx with
    | [] -> 0
    | F(funcn,numargs,_) :: tail-> if funcn = funcname then numargs else numAvailableArgsInFunc funcname tail
    | _ :: tail -> numAvailableArgsInFunc funcname tail
  in

  let rec numargs = function
  | Syntax.Args (_, f) -> 1 + numargs f
  | Syntax.Arg (_) -> 1
  in

  let rec funcargs numargs = function 
    | Syntax.Arg (x) -> [ V(x,true, numargs * 4 + 4, false) ]
    | Syntax.Args (x, f) -> V(x,true, numargs * + 4 + 4, false) :: funcargs (numargs-1) f
  in 

  let rec lastVarLocation ctx counter =
    match ctx with
    | V(_, false, _, _) :: tail -> lastVarLocation tail (counter - 4)
    | _ -> counter - 4
  in 

  let rec locationWithStackFrame ctx x =
    match ctx with
    | V(varName, _, loc, _) :: tail -> if x = varName then loc else locationWithStackFrame tail x
    | _ -> 0
  in
  let rec getRetLocation ctx max =
    match ctx with
    | [] -> max + 4
    | V(_,true, k, _) :: tail -> if k > max then getRetLocation tail k else getRetLocation tail max
    | _ :: tail -> getRetLocation tail max
  in

  (*
  let location ctx x =
    (*print_dec_type_list ctx;*)
    let rec index k = function
      | [] -> Helper.error ~kind:"compilation error" "unknown variable %s" x
      | V(y,true,_) :: ys -> if x = y then k else index (k - 1) ys
      | V(y,false,_) :: ys -> if x = y then k else index (k - 1) ys
      | F(y,_,_) :: ys -> if x = y then k else index (k - 1) ys
      
    in
    index (List.length ctx - 1) ctx
  in
  *)
  let rec getVarType ctx varName =
    match ctx with
    | [] -> false
    | V(varN,_,_,varT) :: tail -> if varN = varName then varT else getVarType tail varName
    | _ :: tail -> getVarType tail varName
  in

  (* Compile an expression in the given context [ctx]. *)
  let rec expression ctx = function
    | Syntax.NewFunc(a, e) -> 
      let numArgsInFunc = numAvailableArgsInFunc a ctx in 
      let numCallArgsInFunc = numCallArgs e in
      let _ = (
        if numArgsInFunc <> numCallArgsInFunc 
        then (Printf.printf "This function expected %d arguments but received %d instead\n" numArgsInFunc numCallArgsInFunc) 
        else ()) 
      in [ PrepRet ] @ expression ctx e @ [ Callfunc a ]
    | Syntax.PassArgs (e1,e2) -> expression ctx e1 @ expression ctx e2
    (*| Syntax.Variable x -> let k = location ctx x in [ GET k ]*)
    | Syntax.Variable x -> let k = locationWithStackFrame ctx x in [ GET k ]
    | Syntax.Floating k -> [ FPUSH k ]
    | Syntax.Numeral k -> [ PUSH k ]
    
    (*
    | Syntax.FPlus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FADD ]
    | Syntax.FMinus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FSUB ]
    | Syntax.FTimes (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FMUL ]
    | Syntax.FDivide (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ FDIV ]
    | Syntax.Plus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ ADD ]
    | Syntax.Minus (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ SUB ]
    | Syntax.Times (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ MUL ]
    | Syntax.Divide (e1, e2) -> expression ctx e1 @ expression ctx e2 @ [ DIV ]
    *)

    
    | Syntax.FPlus (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with
      | Syntax.Variable _ , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ FADD ])
      | Syntax.Variable k , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable k  -> if not (getVarType (ctx) (k)) then (print_type_error_at_pos x; [ FADD ]) else [ FADD ] 
      | Syntax.Variable k , Syntax.Variable k2  -> if not (getVarType (ctx) (k)) || not (getVarType (ctx) (k2)) then (print_type_error_at_pos x; [ FADD ]) else [ FADD ]
      | _ -> [ FADD ]
      )
    | Syntax.FMinus (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ FSUB ])
      | Syntax.Variable k , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable k  -> if not (getVarType (ctx) (k)) then (print_type_error_at_pos x; [ FSUB ]) else [ FSUB ] 
      | Syntax.Variable k , Syntax.Variable k2  -> if not (getVarType (ctx) (k)) || not (getVarType (ctx) (k2)) then (print_type_error_at_pos x; [ FSUB ]) else [ FSUB ]
      | _ -> [ FSUB ]
    )
    | Syntax.FTimes (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ FMUL ])
      | Syntax.Variable k , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable k  -> if not (getVarType (ctx) (k)) then (print_type_error_at_pos x; [ FMUL ]) else [ FMUL ] 
      | Syntax.Variable k , Syntax.Variable k2  -> if not (getVarType (ctx) (k)) || not (getVarType (ctx) (k2)) then (print_type_error_at_pos x; [ FMUL ]) else [ FMUL ]
      | _ -> [ FMUL ]
    )
    | Syntax.FDivide (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ FDIV ])
      | Syntax.Variable k , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable k  -> if not (getVarType (ctx) (k)) then (print_type_error_at_pos x; [ FDIV ]) else [ FDIV ] 
      | Syntax.Variable k , Syntax.Variable k2  -> if not (getVarType (ctx) (k)) || not (getVarType (ctx) (k2)) then (print_type_error_at_pos x; [ FDIV ]) else [ FDIV ]
      | _ -> [ FDIV ]
    )
    | Syntax.Plus (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ ADD ])
      | Syntax.Variable k , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable k  -> if getVarType (ctx) (k) then (print_type_error_at_pos x; [ ADD ]) else [ ADD ] 
      | Syntax.Variable k , Syntax.Variable k2  -> if getVarType (ctx) (k) || getVarType (ctx) (k2) then (print_type_error_at_pos x; [ ADD ]) else [ ADD ]
      | _ -> [ ADD ]
    )
    | Syntax.Minus (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ SUB ])
      | Syntax.Variable k , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable k  -> if getVarType (ctx) (k) then (print_type_error_at_pos x; [ SUB ]) else [ SUB ] 
      | Syntax.Variable k , Syntax.Variable k2  -> if getVarType (ctx) (k) || getVarType (ctx) (k2) then (print_type_error_at_pos x; [ SUB ]) else [ SUB ]
      | _ -> [ SUB ]
    )
    | Syntax.Times (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ MUL ])
      | Syntax.Variable k , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable k  -> if getVarType (ctx) (k) then (print_type_error_at_pos x; [ MUL ]) else [ MUL ]
      | Syntax.Variable k , Syntax.Variable k2  -> if getVarType (ctx) (k) || getVarType (ctx) (k2) then (print_type_error_at_pos x; [ MUL ]) else [ MUL ]
      | _ -> [ MUL ]
    )
    | Syntax.Divide (e1, e2, (x,_)) -> expression ctx e1 @ expression ctx e2 @ 
    (
      match e1, e2 with 
      | Syntax.Variable _ , Syntax.Floating _
      | Syntax.Floating _ , Syntax.Variable _ -> (print_type_error_at_pos x; [ DIV ])
      | Syntax.Variable k , Syntax.Numeral _
      | Syntax.Numeral _ , Syntax.Variable k  -> if getVarType (ctx) (k) then (print_type_error_at_pos x; [ DIV ]) else [ DIV ]
      | Syntax.Variable k , Syntax.Variable k2  -> if getVarType (ctx) (k) || getVarType (ctx) (k2) then (print_type_error_at_pos x; [ DIV ]) else [ DIV ]
      | _ -> [ DIV ]
    )
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

  (* Compile the given command in the given context [ctx]. *)
  let rec command ctx = function
    | Syntax.Return (e, _) ->
      (*let x,y = a in Printf.printf "%d, %d" x.pos_lnum y.pos_lnum;*)
      let retLoc = getRetLocation ctx 0 in 
      let lastVarLoc = lastVarLocation ctx 0 in
      expression ctx e @ [ Return (retLoc, retLoc - lastVarLoc + 4) ]
    | Syntax.Func (x, a, c, c2) ->
      let ctx = (funcargs (numargs a) a) @ F(x, numargs a, 4) :: ctx in
      let c' = command ctx c in
      let c2' = command ctx c2 in
      [ FuncStart x ] @ c' @ [ FuncEnd x ] @ c2'

    | Syntax.New (x, e, c) ->
      let e' = expression ctx e in
      let ctx = V(x, false, lastVarLocation ctx 0,
      (
      match e with
      | Syntax.Floating _ -> true
      | _ -> false
      )
      ) :: ctx in
      let c' = command ctx c in
      (*let k = location ctx x in*)
      e' (*@ [ SET k ]*) @ c'


    | Syntax.Skip -> [ NOOP ]
    | Syntax.Print e -> 
      expression ctx e @ [ PRINT ]
    | Syntax.FPrint e -> expression ctx e @ [ FPRINT ]
    (*| Syntax.Assign (x, e) -> expression ctx e @ [ SET (location ctx x) ]*)
    | Syntax.Assign (x, e) -> expression ctx e @ [ SET (locationWithStackFrame ctx x) ]
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
