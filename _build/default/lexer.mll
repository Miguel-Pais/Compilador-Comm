{
  open Lexing
}

let variable = ['_' 'a'-'z' 'A'-'Z'] ['_' 'a'-'z' 'A'-'Z' '0'-'9']*
rule token = parse
    "#" [^'\n']* '\n'   { Lexing.new_line lexbuf; token lexbuf }
  | '\n'            { Lexing.new_line lexbuf; token lexbuf }
  | [' ' '\t']      { token lexbuf }
  | '-'? ['0'-'9']* '.' ['0'-'9']*? { Parser.FLOATING (float_of_string (lexeme lexbuf)) }
  | '-'? ['0'-'9']+ { Parser.NUMERAL (int_of_string(lexeme lexbuf)) }
  | "true"          { Parser.TRUE }
  | "false"         { Parser.FALSE }
  | "skip"          { Parser.SKIP }
  | "if"            { Parser.IF }
  | "then"          { Parser.THEN }
  | "else"          { Parser.ELSE }
  | "end"           { Parser.END }
  | "while"         { Parser.WHILE }
  | "do"            { Parser.DO }
  | "done"          { Parser.DONE }
  | "print"         { Parser.PRINT }
  | "print_f"       { Parser.FPRINT }
  | "new"           { Parser.NEW }
  | "in"            { Parser.IN }
  | "and"           { Parser.AND }
  | "or"            { Parser.OR }
  | "not"           { Parser.NOT }
  | ":="            { Parser.ASSIGN }
  | ';'             { Parser.SEMICOLON }
  | '('             { Parser.LPAREN }
  | ')'             { Parser.RPAREN }
  | "+."            { Parser.FPLUS }
  | "-."            { Parser.FMINUS }
  | "*."            { Parser.FTIMES }
  | "/."            { Parser.FDIVIDE }
  | '+'             { Parser.PLUS }
  | '-'             { Parser.MINUS }
  | '*'             { Parser.TIMES }
  | '/'             { Parser.DIVIDE }
  | '%'             { Parser.REMAINDER }
  | '='             { Parser.EQUAL }
  | '<'             { Parser.LESS }
  | ','             { Parser.PARAMETERCOMMA}
  | "return"        { Parser.RETURN}
  | variable        { Parser.VARIABLE (lexeme lexbuf) }
  | eof             { Parser.EOF }

{
}
