%{
%}

%token <float> FLOATING
%token <int> NUMERAL
%token <string> VARIABLE
%token LPAREN RPAREN
%token EQUAL LESS
%token PLUS MINUS TIMES DIVIDE REMAINDER
%token FPLUS FMINUS FTIMES FDIVIDE
%token TRUE FALSE
%token AND OR NOT
%token NEW IN
%token SKIP
%token IF THEN ELSE END
%token WHILE DO DONE
%token PRINT FPRINT
%token ASSIGN
%token SEMICOLON
%token EOF
%token PARAMETERCOMMA
%token RETURN
/* Precedence and associativity */
%nonassoc IN
%left SEMICOLON
%left OR
%left AND
%nonassoc NOT
//%right FTIMES FDIVIDE FPLUS FMINUS
%left FPLUS FMINUS
%left PLUS MINUS
%left FTIMES FDIVIDE
%left TIMES DIVIDE REMAINDER

/* Top level rule */
%start program file
%type <Syntax.command> program
%type <Syntax.command list> file

%%

/* Grammar */

file:
  | p=program { [p] }

program:
  | c=command EOF { c }

funcarg: 
  | x=VARIABLE PARAMETERCOMMA f=funcarg { Syntax.Args (x, f) }
  | x=VARIABLE                          { Syntax.Arg x }


command:
  | RETURN e=expression                                            { Syntax.Return(e,$loc)}
  | NEW x=VARIABLE p=funcarg LPAREN c=command RPAREN IN c2=command { Syntax.Func(x, p, c, c2) }
  | SKIP                                                           { Syntax.Skip }
  | NEW x=VARIABLE ASSIGN e=expression IN c=command                { Syntax.New(x, e, c) }
  | FPRINT e=expression                                            { Syntax.FPrint e }
  | PRINT e=expression                                             { Syntax.Print e }
  | x=VARIABLE ASSIGN e=expression                                 { Syntax.Assign (x, e) }
  | c1=command SEMICOLON c2=command                                { Syntax.Sequence (c1, c2) }
  | WHILE b=boolean DO c=command DONE                              { Syntax.While (b, c) }
  | IF b=boolean THEN c1=command ELSE c2=command END               { Syntax.Conditional (b, c1, c2) }
  | LPAREN c=command RPAREN                                        { c }

expression:
  | f=VARIABLE LPAREN e=expression RPAREN { Syntax.NewFunc(f, e) }
  | e1=expression PARAMETERCOMMA e2=expression { Syntax.PassArgs (e1, e2) }
  | x=VARIABLE                            { Syntax.Variable x }
  | f=FLOATING                            { Syntax.Floating f }
  | n=NUMERAL                             { Syntax.Numeral n }
  | e1=expression FTIMES  e2=expression   { Syntax.FTimes (e1, e2, $loc) }
  | e1=expression FPLUS   e2=expression   { Syntax.FPlus (e1, e2, $loc) }
  | e1=expression FMINUS  e2=expression   { Syntax.FMinus (e1, e2, $loc) }
  | e1=expression FDIVIDE e2=expression   { Syntax.FDivide (e1, e2, $loc) }
  | e1=expression TIMES  e2=expression    { Syntax.Times (e1, e2, $loc) }
  | e1=expression PLUS   e2=expression    { Syntax.Plus (e1, e2, $loc) }
  | e1=expression MINUS  e2=expression    { Syntax.Minus (e1, e2, $loc) }
  | e1=expression DIVIDE e2=expression    { Syntax.Divide (e1, e2, $loc) }
  | e1=expression REMAINDER e2=expression { Syntax.Remainder (e1, e2) }
  | LPAREN e = expression RPAREN          { e }

boolean:
  | TRUE                              { Syntax.True }
  | FALSE                             { Syntax.False }
  | e1=expression EQUAL e2=expression { Syntax.Equal (e1, e2) }
  | e1=expression LESS e2=expression  { Syntax.Less (e1, e2) }
  | b1=boolean AND b2=boolean         { Syntax.And (b1, b2) }
  | b1=boolean OR b2=boolean          { Syntax.Or (b1, b2) }
  | NOT b=boolean                     { Syntax.Not b }
  | LPAREN b=boolean RPAREN           { b }
