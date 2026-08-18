%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

%token NUMBER
%token ADD SUB MUL DIV ABS
%token OP CP
%token EOL

%left ADD SUB
%left MUL DIV
%nonassoc ABS

%%

calclist:
    /* vacío */
    | calclist exp EOL { printf("= %d (0x%X)\n> ", $2, $2); }
    | calclist EOL     { printf("> "); }
    ;

exp:
    factor
    | exp ADD factor { $$ = $1 + $3; }
    | exp SUB factor { $$ = $1 - $3; }
    ;

factor:
    term
    | factor MUL term { $$ = $1 * $3; }
    | factor DIV term { 
        if ($3 == 0) {
            yyerror("Error: Division por cero");
            $$ = 0;
        } else {
            $$ = $1 / $3; 
        }
      }
    ;

term:
    NUMBER
    | ABS term  { $$ = $2 >= 0 ? $2 : -$2; }
    | OP exp CP { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    printf("> ");
    yyparse();
    return 0;
}
