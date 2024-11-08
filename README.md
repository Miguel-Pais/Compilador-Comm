
# Comm programming language

A simple procedural language with integer arithmetic `+,-,*,/`, boolean expressions `and,or,not`, local variables, conditional statements, `while` loops and printing `print`.
Comm programs are compiled for RV32IM ISA.

## Abstract syntax

Integer expression `e`:

* variable (a string of letters)
* integer constant
* addition `e₁ + e₂`
* subtraction `e₁ - e₂`
* multiplication `e₁ * e₂`
* integer division `e₁ / e₂`
* remainder `e₁ % e₂`

Boolean expression `b`:

* boolean constants `true` and `false`
* conjunction `b₁ and b₂`
* disjunction `b₁ or b₂` 
* negation `not b`

Command `c`:

* no operation `skip`
* local variable declaration `new x := e in c`
* print expression `print e`
* assign a varible `x := e`
* sequence commands `c₁ ; c₂`
* loop `while b do c done`
* conditional statement `if b then c₁ else c₂ end`

## Build compiler


```
dune build
```

`dune` is a build system commonly used in OCaml projects. `dune build` command instructs the build system to compile the project's source code and generate the executable files.


## Compilation to RV32 ISA

The language is compiled to RV32 machine code. Use the `--code` command-line option to see the compiled code.

Try

```
_build/default/comm.exe --code examples/example1.comm
```

The underlying code runs in RARS. The stack grows upwards, from the bottom of RAM to the top.

## Emulation

The language is also compiled into simplified machine code with the pseudo-instructions

* `NOOP` no operation
* `SET k` pop from stack and store in the `k` location
* `GET k` push from `k` location onto stack
* `PUSH i` push integer constant onto stack
* `ADD` addition
* `SUB` subtraction
* `MUL` multiplication
* `DIV` division
* `MOD` remainder
* `EQ` equal
* `LT` less than
* `AND` conjunction
* `OR` disjunction
* `NOT` negation
* `JMP ln` relative jump to `ln`
* `JMPZ ln` relative jump to `ln` if zero on the stack
* `PRINT` pop from stack and print

Try

```
_build/default/comm.exe --execute examples/example1.comm
```

The underlying machine has a fixed amount of RAM (configurable `--ram` command-line option), a program, the program counter, and a stack pointer.
The stack grows downards, from the top of RAM towards the bottom.
