%{
#include "calc.tab.h"
%}

%%

"+"        { return ADD; }
"-"        { return SUB; }
"*"        { return MUL; }
"/"        { return DIV; }
"|"        { return ABS; }
"&"        { return AND; }
"("        { return OP; }
")"        { return CP; }
[0-9]+     { yylval = atoi(yytext); return NUMBER; }
"//".*     { /* ignorar comentarios */ }
[ \t]      { /* ignorar espacios */ }
\n         { return EOL; }
.          { yyerror("caracter desconocido: %c\n", *yytext); }

%%

int yywrap(void) {
    return 1;
}
