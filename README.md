
# Comm programming language

A simple procedural language with integer arithmetic `+,-,*,/`, boolean expressions `and,or,not`, simple expression comparison using `=,<`, local variables, conditional statements, `while` loops, printing `print` and `print_f` and functions. 
Comm programs are compiled for RV32IM ISA.

## Abstract syntax

Expression `e`:

* variable (a string of letters)
* integer constant
* floating constant
* integer addition `e₁ + e₂`
* integer subtraction `e₁ - e₂`
* integer multiplication `e₁ * e₂`
* integer division `e₁ / e₂`
* floating addition `e₁ +. e₂`
* floating subtraction `e₁ -. e₂`
* floating multiplication `e₁ *. e₂`
* floating division `e₁ /. e₂`
* remainder `e₁ % e₂`

Boolean expression `b`:

* boolean constants `true` and `false`
* conjunction `b₁ and b₂`
* disjunction `b₁ or b₂` 
* negation `not b`
* equal expressions `e1 = e2`
* less than `e1 < e2`

Command `c`:

* no operation `skip`
* local variable declaration `new x := e in c`
* print expression `print e`
* print float expression `print_f e`
* assign a varible `x := e`
* sequence commands `c₁ ; c₂`
* loop `while b do c done`
* conditional statement `if b then c₁ else c₂ end`
* declare a function `new func par1, par2 ( command in return expression ) in command`
* call a function `new var := func (par1, par2) in command`

## Build compiler


```
dune build
```

`dune` is a build system commonly used in OCaml projects. `dune build` command instructs the build system to compile the project's source code and generate the executable files.


## Compilation to RV32 ISA

The language is compiled to RV32 machine code. Use the `--code` command-line option to see the compiled code.
The language can be compiled to web-assembly code. Use the `--web` command-line option to see the web-assembly compiled code.

Try

```
_build/default/comm.exe --code examples/example1.comm
```

The underlying code runs in RARS. The stack grows upwards, from the bottom of RAM to the top.


OR

```
_build/default/comm.exe --web examples/example1.comm
```
for a web-assembly version


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

### Tasks

- [x] Estender os operadores %, e, = (dificuldade baixa) extension-operators.comm

- [x] Extensão de floats (dificuldade média) extension-floats.comm

- [x] Implementar a verificação do tipo para variáveis inteiras e floats num módulo à parte (dificuldade baixa)

- [x] | POR REVER | Compilar a linguagem comm para a linguagem de WebAssembly (dificuldade média) extension-target-language

- [ ] Estender a linguagem comm com records utilizando a noção de endereço e de campos - como vimos na aula teórica 4 (dificuldade média)

- [x] Estender a linguagem comm com funções - como vimos na aula teórica 5 (dificuldade baixa)

- [ ] Estender a linguagem comm com funções anónimas e fecho lexical (dificuldade alta)

- [x] Implementar a geração de código de funções (dificuldade média)

- [ ] Implementar os tipos de dados abstrato (módulo) para ajuda na geração de código assembly - RV32IMF e WebAssembly (dificuldade média)

- [ ] Formalizar o sistema de tipos da linguagem resultante comm++ (dificuldade média ou alta consoante as extensões)

- [ ] Utilizando a semântica formal do webassembly, mostrar a preservação semântica da linguagem comm ou comm++ (dificuldade alta)*
