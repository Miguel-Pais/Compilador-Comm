
(* The type of tokens. *)

type token = 
  | WHILE
  | VARIABLE of (string)
  | TRUE
  | TIMES
  | THEN
  | SKIP
  | SEMICOLON
  | RPAREN
  | RETURN
  | REMAINDER
  | PRINT
  | PLUS
  | PARAMETERCOMMA
  | OR
  | NUMERAL of (int)
  | NOT
  | NEW
  | MINUS
  | LPAREN
  | LESS
  | IN
  | IF
  | FTIMES
  | FPRINT
  | FPLUS
  | FMINUS
  | FLOATING of (float)
  | FDIVIDE
  | FALSE
  | EQUAL
  | EOF
  | END
  | ELSE
  | DONE
  | DO
  | DIVIDE
  | ASSIGN
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Syntax.command)

val file: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Syntax.command list)
