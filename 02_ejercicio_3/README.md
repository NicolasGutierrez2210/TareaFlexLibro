# Ejercicio 3 - Capítulo 1 (Flex & Bison)

## Enunciado

> Add bit operators such as AND and OR to the calculator. The obvious operator to
> use for OR is a vertical bar, but that's already the unary absolute value
> operator. What happens if you also use it as a binary OR operator, for
> example, `exp ABS factor`?

## Solución

Se parte de la calculadora final del capítulo 1 (`fb1-5`, la que ya soporta
paréntesis y comentarios) y se le agregan dos operadores:

- **AND** (`&`): token nuevo, sin conflicto con nada existente.
- **OR** (`|`): se reutiliza el mismo carácter que ya usaba `ABS` (valor
  absoluto unario), tal como pide el enunciado.

### Cambios en el parser (`calc.y`)

Se agregan dos reglas nuevas al mismo nivel que `ADD`/`SUB`:

```c
exp:      factor
        | exp ADD factor    { $$ = $1 + $3; }
        | exp SUB factor    { $$ = $1 - $3; }
        | exp ABS factor    { $$ = $1 | $3; }   /* OR */
        | exp AND factor    { $$ = $1 & $3; }
        ;
```

La regla de `term` (donde vive el absoluto unario) no cambia:

```c
term:     NUMBER
        | ABS term           { $$ = $2 >= 0 ? $2 : -$2; }
        | OP exp CP
        ;
```

### Cambios en el scanner (`calc.l`)

Solo se agrega el patrón para `&`. El patrón de `|` ya existía y se deja igual,
porque ahora representa dos cosas distintas según el contexto:

```c
"|"        { return ABS; }
"&"        { return AND; }
```

## ¿Qué pasa al compilarlo?

Al correr `bison -d -v calc.y` aparece:

```
calc.y: conflicts: 1 shift/reduce
```

Esto ocurre porque el token `ABS` (`|`) cumple dos roles en la gramática:

- **Prefijo**: `term: ABS term` (valor absoluto, ej. `|-5|`)
- **Infijo**: `exp: exp ABS factor` (OR, ej. `3 | 5`)

Es el mismo tipo de ambigüedad que el clásico "menos unario vs. menos
binario". Bison resuelve el conflicto por defecto haciendo **shift**, lo cual
en la práctica da el resultado esperado: `3 | |5` se interpreta como
`3 OR abs(5)`.

El detalle exacto del estado donde ocurre el conflicto queda documentado en
`calc.output` (generado con la bandera `-v`).

## Compilar y probar

```bash
bison -d -v calc.y
flex calc.l
gcc lex.yy.c calc.tab.c -o calc -lfl
./calc
```

Ejemplos de entrada:

```
5 | 3       # -> 7  (OR)
6 & 3       # -> 2  (AND)
|-5         # -> 5  (absoluto)
3 | |5      # -> 7  (OR entre 3 y abs(5))
```
