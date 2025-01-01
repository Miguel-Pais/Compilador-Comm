(** A simple machine with a program, RAM, program counter and a stack pointer. The program
   is an array of instructions. The stack grows downwards. Arithmetical and boolean
   operations operate on the stack. *)

(** The machine instructions. *)
type instruction =
  | NOOP (* no operation *)
  | SET of int (* pop from stack and store in the given location *)
  | GET of int (* push from given location onto stack *)
  | FPUSH of float 
  | PUSH of int (* push integer constant onto stack *)
  | FADD (* addition *)
  | FSUB (* subtraction *)
  | FMUL (* multiplication *)
  | FDIV (* division *)
  | ADD (* addition *)
  | SUB (* subtraction *)
  | MUL (* multiplication *)
  | DIV (* division *)
  | MOD (* remainder *)
  | EQ (* equal *)
  | LT (* less than *)
  | AND (* conjunction *)
  | OR (* disjunction *)
  | NOT (* negation *)
  | JMP of int (* relative jump *)
  | JMPZ of int (* relative jump if zero on the stack *)
  | PRINT (* pop from stack and print *)
  | FPRINT 
  | TYPE of string
  | FuncStart of string
  | FuncEnd of string
  | Callfunc of string
  | Return of int * int
  | PrepRet

(** Print an instruction. *)

(*let print_instruction_web instr k0 ppf =*)
let print_instruction_web instr k0 ppf =
  match instr with

  | NOOP -> Format.fprintf ppf
    "(func $noop  \n
      (nop) ;;  \n
      )"

  | GET k -> Format.fprintf ppf (*nova*)
  "(local.set $s0 (i32.add (local.get $s0) (i32.const -%d)))\n\
  (local.set $t1 (i32.load (local.get $s0)))\n\
  (local.set $s0 (i32.add (local.get $s0) (i32.const %d)))\n\
  (local.set $sp (i32.add (local.get $sp) (i32.const -4)))\n\
  (i32.store (local.get $sp) (local.get $t1))\n ;; GET " (-k) (-k)
  
  | FPUSH k -> Format.fprintf ppf (*nova*)
      "
      (f32.store (local.get $sp) (local.get $t1))\n
      (local.set $sp (f32.add (local.get $sp) (f32.const 4)));;%f  ;; FPUSH" k

  | SET k -> Format.fprintf ppf (*nova*)
    "
    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (local.set $t0 (i32.load (local.get $sp))) \n;;%d  ;; SET" k  
  
| PUSH k -> Format.fprintf ppf  (*nova*)
    "(local.set $sp (i32.add (local.get $sp) (i32.const -4)))\n\
    (local.set $t1 (i32.const %d))\n\
    (i32.store (local.get $sp) (local.get $t1)) ;; PUSH\n" k 
 
  | ADD -> Format.fprintf ppf (*nova*)
    "   
    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t0 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t2 (i32.add (local.get $t0) (local.get $t1))) \n
  "
  | SUB -> Format.fprintf ppf (*nova*)
    "
    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t0 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t2 (i32.sub (local.get $t0) (local.get $t1))) \n
  "
  | MUL -> Format.fprintf ppf (*nova*)
    "(local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t0 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t2 (i32.mul (local.get $t0) (local.get $t1))) \n
  "
  | DIV -> Format.fprintf ppf (*nova*)
    "
    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t0 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t2 (i32.div_u (local.get $t0) (local.get $t1))) \n
  "
  | MOD -> Format.fprintf ppf  (*nova*)
    "(local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t0 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t2 (i32.rem_u (local.get $t0) (local.get $t1))) \n
  "
  | AND -> Format.fprintf ppf   (*nova/por acabar*)
    "
    (local.set $t2 (i32.and (local.get $t0) (local.get $t1)))\n
    "
  | OR -> Format.fprintf ppf (*nova/por acabar*)
    "
    (local.set $t2 (i32.or (local.get $t0) (local.get $t1)))\n
    "

  | EQ -> Format.fprintf ppf (*nova*)
    "(local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (i32.sub (local.get $sp) (i32.const 4))) \n
    (i32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t0 (i32.load (local.get $sp)))              \n
    (local.set $sp (i32.add (local.get $sp) (i32.const 4))) \n

    (local.set $t2 (i32.eq (local.get $t0) (local.get $t1))) \n
    "

  | LT -> Format.fprintf ppf (*nova*)
    "(local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t0 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t2 (i32.lt_u (local.get $t0) (local.get $t1))) \n
    "

  | NOT -> Format.fprintf ppf (*nova*)
    "(local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t0 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t2 (i32.ne (local.get $t0) (local.get $t1))) \n
    "

  | FADD -> Format.fprintf ppf (*nova*)
    "(local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t0 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t2 (f32.add (local.get $t0) (local.get $t1))) \n
  "
  | FSUB -> Format.fprintf ppf (*nova*)
    "(local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t0 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t2 (f32.sub (local.get $t0) (local.get $t1))) \n
  "
  | FMUL -> Format.fprintf ppf (*nova*)
    "(local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t0 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t2 (f32.mull (local.get $t0) (local.get $t1))) \n
  "
  | FDIV -> Format.fprintf ppf (*nova*)
    "(local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t0))             \n

    (local.set $sp (f32.sub (local.get $sp) (f32.const 4))) \n
    (f32.store (local.get $sp) (local.get $t1))             \n

    (local.set $t1 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t0 (f32.load (local.get $sp)))              \n
    (local.set $sp (f32.add (local.get $sp) (f32.const 4))) \n

    (local.set $t2 (f32.div (local.get $t0) (local.get $t1))) \n
  "

    | JMP k -> Format.fprintf ppf 
    "(func $jmp (param $offset i32)
    block
      local.get $offset
      br 0          
    end
    );;%d " k
    
    | JMPZ k -> Format.fprintf ppf 
    "(func $jmpz (param $offset i32)
  
    local.get $offset
    if                
      br 0            
    end
    );;%d " k

    | PRINT ->
      Format.fprintf ppf "(call $print (local.get $t1)) ;; Print result"
    
    (*| TYPE of string
    | FuncStart of string
    | FuncEnd of string
    | Callfunc of string
    | Return of int *)


    | _ -> Format.fprintf ppf "#TEMPLATE %d" k0

let print_instruction_rv32 instr k0 ppf =
  match instr with
  | TYPE _ -> ()
  | NOOP -> Format.fprintf ppf "addi t0, t0, 0 #NOP"
  | SET k -> Format.fprintf ppf 
    "lw t1, 0(sp)\nsw t1,
    %d(s0) #SET %d \n
    addi sp, sp, 4" (k) (k)
  (*| GET k -> Format.fprintf ppf "addi sp, sp, -4\nsw s%d, 0(sp) #GET %d" k k*)
  | GET k -> Format.fprintf ppf "lw t1, %d(s0) #GET %d\n\
                                 addi sp, sp, -4\n\
                                 sw t1, 0(sp)" (k) (k)
  | FPUSH k -> Format.fprintf ppf "addi sp, sp, -4\nli t1, %s\nfmv.s.x fa1, t1\nfsw fa1, 0(sp) #FPUSH %f" (Int32.to_string(Int32.bits_of_float(k))) k
  | PUSH k -> Format.fprintf ppf 
    "addi sp, sp, -4\n
    li t1, %d\n
    sw t1, 0(sp) #PUSH %d" k k
  | ADD -> Format.fprintf ppf
        "lw t1, 0(sp)\n\
         addi sp, sp, 4\n\
         lw t0, 0(sp)\n\
         addi sp, sp, 4\n\
         add t2, t0, t1\n\
         addi sp, sp, -4\n\
         sw t2, 0(sp) # ADD"
  | SUB -> Format.fprintf ppf
        "lw t1, 0(sp)\n\
         addi sp, sp, 4\n\
         lw t0, 0(sp)\n\
         addi sp, sp, 4\n\
         sub t2, t0, t1\n\
         addi sp, sp, -4\n\
         sw t2, 0(sp) # SUB"
  | MUL -> Format.fprintf ppf
        "lw t1, 0(sp)\n\
         addi sp, sp, 4\n\
         lw t0, 0(sp)\n\
         addi sp, sp, 4\n\
         mul t2, t0, t1\n\
         addi sp, sp, -4\n\
         sw t2, 0(sp) # MUL"
  | DIV -> Format.fprintf ppf
        "lw t1, 0(sp)\n\
         addi sp, sp, 4\n\
         lw t0, 0(sp)\n\
         addi sp, sp, 4\n\
         div t2, t0, t1\n\
         addi sp, sp, -4\n\
         sw t2, 0(sp) # DIV"
  | MOD -> Format.fprintf ppf 
        "lw t1, 0(sp)\n\
        addi sp, sp, 4\n\
        lw t0, 0(sp)\n\
        addi sp, sp, 4\n\
        rem t2, t0, t1\n\
        addi sp, sp, -4\n\
        sw t2, 0(sp) # MOD"
  | FADD -> Format.fprintf ppf
        "flw fa1, 0(sp)\n\
          addi sp, sp, 4\n\
          flw fa0, 0(sp)\n\
          addi sp, sp, 4\n\
          fadd.s fa2, fa0, fa1\n\
          addi sp, sp, -4\n\
          fsw fa2, 0(sp) # FADD"
  | FSUB -> Format.fprintf ppf
        "flw fa1, 0(sp)\n\
          addi sp, sp, 4\n\
          flw fa0, 0(sp)\n\
          addi sp, sp, 4\n\
          fsub.s fa2, fa0, fa1\n\
          addi sp, sp, -4\n\
          fsw fa2, 0(sp) # FSUB"
  | FMUL ->
      Format.fprintf ppf
        "flw fa1, 0(sp)\n\
          addi sp, sp, 4\n\
          flw fa0, 0(sp)\n\
          addi sp, sp, 4\n\
          fmul.s fa2, fa0, fa1\n\
          addi sp, sp, -4\n\
          fsw fa2, 0(sp) # FMUL"
  | FDIV ->
      Format.fprintf ppf
        "flw fa1, 0(sp)\n\
          addi sp, sp, 4\n\
          flw fa0, 0(sp)\n\
          addi sp, sp, 4\n\
          fdiv.s fa2, fa0, fa1\n\
          addi sp, sp, -4\n\
          fsw fa2, 0(sp) # FDIV"
  | AND -> Format.fprintf ppf 
        "mul t3, t1, t2\n\
        sw t3, 0(sp) # AND"
  | EQ -> Format.fprintf ppf 
        "lw t2, 0(sp)\n\
        addi sp, sp, 4\n\
        lw t1, 0(sp)\n\
        addi sp, sp, 4\n\
        sub t3,t1,t2\n\
        seqz t3, t3\n\
        addi sp, sp, -4\n\
        sw t3, 0(sp) # EQ"
  | LT -> Format.fprintf ppf
        "lw t1, 0(sp)\n\
        addi sp, sp, 4\n\
        lw t0, 0(sp)\n\
        addi sp, sp, 4\n\
        slt t2, t0, t1\n\
        addi sp, sp, -4\n\
        sw t2, 0(sp) # LT"
  | OR -> Format.fprintf ppf "# OR"
  | NOT -> Format.fprintf ppf "# NOT"
  | JMP k -> Format.fprintf ppf "jal t3, l%03d # JMP" (k0 + k + 1)
  | JMPZ k -> Format.fprintf ppf "lw t3, 0(sp)\naddi sp, sp, 4\nli t1, 0\nbeq t3, t1, l%03d # JMPZ" (k0 + k + 1)
  | PRINT -> Format.fprintf ppf "lw a0, 0(sp)\naddi sp, sp, 4\nli a7, 1\necall # PRINT"
  | FPRINT -> Format.fprintf ppf "flw fa0, 0(sp)\naddi sp, sp, 4\nli a7, 2\necall # FPRINT"
  | FuncStart name -> Format.fprintf ppf 
    "j %s_end \n\
    %s: \n\
    sw ra, 4(s0) # FUNCSTART" name name
  | FuncEnd name -> Format.fprintf ppf "ret \n%s_end: # FUNCEND" name
  | Callfunc name -> Format.fprintf ppf 
    "addi sp, sp, -8 \n\
     sw s0, 0(sp) \n\
     mv s0, sp \n\
     call %s # CALLFUNC" name
  | Return (ret, sp) -> Format.fprintf ppf 
    "addi sp, sp, -4\n\
     sw t1, %d(s0)\n\
     lw ra, 4(s0)\n\
     lw s0, 0(s0)\n\
     addi sp, sp, %d #RETURN " ret sp
  | PrepRet -> Format.fprintf ppf "addi sp, sp, -4\nsw s%d, 0(sp) #RETURN %d" 0 0


(** Machine errors *)
type error = Illegal_address | Illegal_instruction | Zero_division


(** Print a machine error *)
let print_error err ppf =
  match err with
  | Illegal_address -> Format.fprintf ppf "illegal address"
  | Illegal_instruction -> Format.fprintf ppf "illegal instruction"
  | Zero_division -> Format.fprintf ppf "division by zero"

exception Error of error

(** Signal a machine error *)
let runtime_error err = raise (Error err)

(** Print the program *)
let print_code code ppf =
  Format.fprintf ppf "mv s0, sp \nsw s0, 0(sp) #START\n";
  Array.iteri
    (fun k instr ->
      Format.fprintf ppf "l%03d:\n%t@\n" k (print_instruction_rv32 instr k))
    code
let print_code_web code ppf =
  Format.fprintf ppf "(module 
  (import \"console\" \"log\" (func $print (param i32)))
  (memory 1)
  (export \"memory\" (memory 0))
  (data (i32.const 0) \"\\00\\00\\00\\00\")
  (func $main
    (local $ra i32)
    (local $sp i32)
    (local $t0 i32)
    (local $t1 i32)
    (local $t2 i32)
    (local $s0 i32)
    (local $s1 i32)
    (local $s2 i32)
    (local $s3 i32)
    (local $s4 i32)
    (local $s5 i32)
    (local $s6 i32)
    (local $pc i32)
    (local.set $sp (i32.const 100))
    (local.set $s0 (local.get $sp))\n";
  Array.iteri
    (fun k instr ->
      Format.fprintf ppf ";;l%03d:\n%t@\n" k (print_instruction_web instr k))
    code;
  Format.fprintf ppf ")(start $main))"

type state = {
  code : instruction array; (* program *)
  ram : int array; (* random-access memory *)
  mutable pc : int; (* program counter *)
  mutable sp : int; (* stack pointer *)
}
(** The state of the machine *)

(** Initialize the state with give program and RAM size *)
let make code ram_size =
  { code; ram = Array.init ram_size (fun _ -> 0); pc = 0; sp = ram_size - 1 }

(** In state [s], read from memory location [k] *)
let read s k =
  try s.ram.(k) with Invalid_argument _ -> runtime_error Illegal_address

(** In state [s], write [x] to memory location [k] *)
let write s k x =
  try s.ram.(k) <- x with Invalid_argument _ -> runtime_error Illegal_address

(** In given state [s], pop from the stack *)
let pop s =
  let x = read s s.sp in
  s.sp <- s.sp + 1;
  x

(** In given state [s], push [x] onto the stack *)
let push s x =
  s.sp <- s.sp - 1;
  write s s.sp x

(** a Execute a command in the given state. *)
exception Typemismatch of string


(** Execute a command in the given state. *)
let exec s =
  match s.code.(s.pc) with
  | TYPE k -> raise (Typemismatch (k ^ " entre int e float nao e permitido"));
  | NOOP -> ()
  | SET k ->
      let a = pop s in
      write s k a
  | GET k ->
      let a = read s k in
      push s a
  | PUSH x -> push s x
  | FPUSH x -> push s (int_of_float(x))
  | ADD ->
      let y = pop s in
      let x = pop s in
      push s (x + y)
  | SUB ->
      let y = pop s in
      let x = pop s in
      push s (x - y)
  | MUL ->
      let y = pop s in
      let x = pop s in
      push s (x * y)
  | DIV ->
      let y = pop s in
      let x = pop s in
      if y <> 0 then push s (x / y) else runtime_error Zero_division
  | MOD ->
      let y = pop s in
      let x = pop s in
      if y <> 0 then push s (x mod y) else runtime_error Zero_division
  | FADD ->
      let y = pop s in
      let x = pop s in
      push s (x + y)
  | FSUB ->
      let y = pop s in
      let x = pop s in
      push s (x - y)
  | FMUL ->
      let y = pop s in
      let x = pop s in
      push s (x * y)
  | FDIV ->
      let y = pop s in
      let x = pop s in
      if y <> 0 then push s (x / y) else runtime_error Zero_division
  | EQ ->
      let y = pop s in
      let x = pop s in
      if x = y then push s 1 else push s 0
  | LT ->
      let y = pop s in
      let x = pop s in
      if x < y then push s 1 else push s 0
  | AND ->
      let b = pop s in
      let a = pop s in
      if a <> 0 && b <> 0 then push s 1 else push s 0
  | OR ->
      let b = pop s in
      let a = pop s in
      if a <> 0 || b <> 0 then push s 1 else push s 0
  | NOT ->
      let a = pop s in
      if a <> 0 then push s 0 else push s 1
  | JMP k -> s.pc <- s.pc + k
  | JMPZ k ->
      let a = pop s in
      if a = 0 then s.pc <- s.pc + k
  | PRINT ->
      let a = pop s in
      Format.printf "%d@." a
  | FPRINT ->
      let a = pop s in
      Format.printf "%d@." a
  | FuncStart _ 
  | FuncEnd _ 
  | Callfunc _
  | Return _ -> ()
  | PrepRet -> ()

(** In given state [s], run the program. *)
let run s =
  while s.pc < Array.length s.code do
    exec s;
    s.pc <- s.pc + 1
  done
