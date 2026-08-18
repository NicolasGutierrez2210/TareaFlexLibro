%{
#include <stdio.h>
#include <stdlib.h>
#include "calc_hex.tab.h"
%}

%option noyywrap

%%

"0x"[a-fA-F0-9]+ {
    yylval = strtol(yytext, NULL, 0);
    return NUMBER;
}

[0-9]+ {
    yylval = atoi(yytext);
    return NUMBER;
}

"+"     { return ADD; }
"-"     { return SUB; }
"*"     { return MUL; }
"/"     { return DIV; }
"|"     { return ABS; }
"("     { return OP; }
")"     { return CP; }
"\n"    { return EOL; }

[ \t]   { /* ignorar espacios */ }

"//".*  { /* ignorar comentarios */ }

.       { printf("Caracter no reconocido: %c\n", *yytext); }

%%


