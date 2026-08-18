# Solución Integrada: Ejercicios 1 y 2 (Capítulo 1)

Este directorio contiene la solución completa e integrada para los **Ejercicios 1 y 2** del libro de Flex & Bison, implementados sobre la calculadora (`calc_hex.l` y `calc_hex.y`).

---

##  EJERCICIO 1: Manejo de Comentarios y Errores Sintácticos

### Preguntas del Enunciado:
1. ¿Aceptará la calculadora una línea que contenga solo un comentario?
2. ¿Por qué no?
3. ¿Sería más fácil arreglar esto en el escáner (Flex) o en el analizador sintáctico (Bison)?

### Respuestas y Solución Técnica:

1. **¿Acepta la calculadora una línea que contenga solo un comentario?**
   **No.** En la versión original de la calculadora (`fb1-5`), ingresar un comentario solo y presionar Enter arroja un error de sintaxis (`syntax error`).

2. **¿Por qué no?**
   Porque cuando escribes un comentario (ej. `// mi comentario`) y presionas Enter, Flex ignora el texto del comentario y solo le envía a Bison el salto de línea (el token `EOL`). 
   La gramática original en Bison exige que antes de cada `EOL` exista obligatoriamente una expresión matemática (`calclist exp EOL`). Al no encontrar ninguna expresión antes del Enter, Bison detecta una estructura inválida y se rompe.

3. **¿Dónde es más fácil solucionarlo y cómo se hizo?**
   Es mucho más fácil arreglarlo en el **analizador sintáctico (Bison)**.
   
   - **En Flex (`calc_hex.l`):** Añadimos la regla léxica `"//".* { /* ignorar */ }` para que el escáner reconozca los comentarios y no haga nada con ellos.
   - **En Bison (`calc_hex.y`):** Agregamos una nueva regla a la gramática:
     ```yacc
     calclist: 
         /* vacío */
       | calclist exp EOL { printf("= %d (0x%X)\n> ", $2, $2); }
       | calclist EOL     { printf("> "); } /* <--- SOLUCIÓN: Permite líneas vacías o de comentarios */
       ;
     ```
     Con esto, si llega un `EOL` aislado, el programa no hace nada, no arroja error y vuelve a mostrar el prompt `>`.

---

## EJERCICIO 2: Calculadora Hexadecimal

### Requisito del Enunciado:
Convertir la calculadora en una calculadora hexadecimal que acepte números tanto hexadecimales como decimales. En el escáner agregar un patrón como `0x[a-f0-9]+` para reconocer un número hexadecimal y utilizar `strtol` para convertir la cadena a un número que se guarda en `yylval`; luego retornar el token `NUMBER`. Ajustar el `printf` de salida para imprimir el resultado tanto en decimal como en hexadecimal.

### Interpretación Técnica y Solución Implementada:

#### 1. Modificación en el Escáner (Flex)
Le enseñamos a la calculadora a reconocer números en base 16 y a traducirlos internamente a base 10 para que Bison pueda operar con ellos sin darse cuenta del cambio:
- Se añadió la expresión regular `"0x"[a-fA-F0-9]+` para detectar el formato hexadecimal (con soporte para letras mayúsculas y minúsculas).
- Se usó la función estándar de C `strtol(yytext, NULL, 0)`. Esta función toma el texto (ej. `0x1A`), reconoce automáticamente que está en base 16 por el prefijo `0x`, y lo convierte a un valor entero nativo.
- Este valor entero convertido se almacena en `yylval` y se retorna el token `NUMBER` hacia Bison.

#### 2. Modificación en el Parser (Bison)
Se ajustó la forma en la que la calculadora imprime el resultado final tras realizar las operaciones matemáticas:
- En la regla principal de `calclist`, se modificó el `printf`:
  ```yacc
  printf("= %d (0x%X)\n> ", $2, $2);
