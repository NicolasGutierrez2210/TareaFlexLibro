# Solución de los Ejercicios 1 y 2

En esta carpeta se encuentra la solución conjunta e integrada de los **Ejercicios 1 y 2** del Capítulo 1, construida a partir de la infraestructura de la calculadora (`calc_hex.l` y `calc_hex.y`).

---

## 📌 Ejercicio 1: Manejo de Comentarios y Errores de Sintaxis

### ❓ Pregunta del Libro:
> *¿Aceptará la calculadora una línea que contenga solo un comentario? ¿Por qué no? ¿Sería más fácil arreglar esto en el escáner (Flex) o en el analizador sintáctico (Bison)?*

### 📝 Respuestas y Análisis Técnico:

1. **¿Acepta solo un comentario?**
   **No.** En la implementación básica de la calculadora, ingresar una línea con solo un comentario genera un error de sintaxis (`syntax error`).

2. **¿Por qué no?**
   Cuando se ingresa un comentario (ejemplo: `// comentario`) seguido de la tecla *Enter*, Flex identifica el comentario y lo ignora, dejando únicamente el carácter de salto de línea (`\n`). Por lo tanto, el token enviado a Bison es un **`EOL`** aislado.

   La gramática original en Bison definía las líneas válidas como:
   ```yacc
   calclist: 
       /* vacío */
     | calclist exp EOL { printf("= %d\n", $2); }
     ;
