%{
#include <stdio.h>
int yylex(void);
void yyerror(char *s, ...);
%}

%token NUMBER
%token ADD SUB MUL DIV ABS AND EOL OP CP

%%

calclist: /* nothing */
        | calclist exp EOL { printf("= %d\n", $2); }
        | calclist EOL     
        ;

exp:      factor
        | exp ADD factor    { $$ = $1 + $3; }
        | exp SUB factor    { $$ = $1 - $3; }
        | exp ABS factor    { $$ = $1 | $3; }   
        | exp AND factor    { $$ = $1 & $3; }
        ;

factor:   term
        | factor MUL term   { $$ = $1 * $3; }
        | factor DIV term   { $$ = $1 / $3; }
        ;

term:     NUMBER
        | ABS term           { $$ = $2 >= 0 ? $2 : -$2; }
        | OP exp CP           { $$ = $2; }
        ;

%%

int main(void) {
    yyparse();
    return 0;
}

void yyerror(char *s, ...) {
    fprintf(stderr, "error: %s\n", s);
}
