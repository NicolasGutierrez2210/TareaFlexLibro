# Ejercicio 5: Lenguajes donde Flex no es una buena opcion para escribir un escaner

## Planteamiento
La pregunta nos plantea analizar para que tipos de lenguajes de programacion la herramienta Flex no resultaria adecuada o conveniente al momento de construir su analizador lexico (escaner).

---

## Analisis y Explicacion

Flex funciona convirtiendo expresiones regulares en automatas finitos deterministas (DFA). Este modelo es rapido y eficiente para lenguajes donde cada token se reconoce observando unicamente el patron actual y a lo sumo unos pocos caracteres de contexto inmediato. 

Sin embargo, cuando las reglas de un lenguaje dependen de contextos externos, memoria de estados complejos o analisis hacia adelante sin limite, Flex deja de ser una solucion practica. Los casos principales son los siguientes:

---

### 1. Lenguajes basados en indentacion (Python, Nim, YAML)
En lenguajes como Python, los bloques de codigo no se delimitan con llaves `{ }` ni con palabras como `begin`/`end`, sino con la cantidad de espacios o tabulaciones al inicio de cada linea.

* **El problema para Flex:** El analizador lexico debe generar tokens especiales virtuales como `INDENT` (cuando aumenta la sangria) y `DEDENT` (cuando disminuye).
* **Por que Flex se queda corto:** Flex por si solo no mantiene una estructura de datos (como una pila) para comparar si la linea actual tiene 4, 8 o 2 espacios respecto a las lineas anteriores. Aunque se podria agregar codigo en C para llevar esta cuenta, se pierde la ventaja declarativa de Flex y resulta mucho mas comodo escribir el escaner a mano o con un preprocesador.

---

### 2. Fortran (Fortran 77 y anteriores)
El diseno de Fortran clasico tiene dos caracteristicas muy particulares: no tiene palabras reservadas y el compilador ignora completamente todos los espacios en blanco, incluso dentro de nombres y palabras clave.

* **El problema para Flex:** Consideremos estas dos lineas casi identicas:
  * `DO 10 I = 1.10`
  * `DO 10 I = 1,10`
* **La diferencia:**
  * La primera linea es una asignacion a una variable llamada `DO10I` del valor flotante `1.10`.
  * La segunda linea es la cabecera de un bucle `DO` hasta la etiqueta 10 con la variable `I` yendo de 1 a 10.
* **Por que Flex se queda corto:** Cuando el escaner lee las letras `D` y `O`, no puede saber si se trata de la palabra clave `DO` o del inicio de una variable hasta que examina la linea completa buscando si contiene una coma `,` o un punto `.`. Flex esta disenado para mirar como maximo un caracter hacia adelante en su flujo normal, no para escanear lineas enteras de forma anticipada y arbitraria.

---

### 3. Lenguajes con alta sensibilidad al contexto (C++ moderno)
En C++, el significado de una secuencia de caracteres puede cambiar radicalmente segun lo que se haya declarado antes en el programa.

* **Ejemplo 1 (Templates anidados):**  
  En versiones anteriores de C++, una expresion como `vector<vector<int>>` causaba que el escaner interpretara `>>` como el operador de desplazamiento a la derecha en lugar de dos cierres de plantilla `>` y `>`.
* **Ejemplo 2 (El dilema de tipo vs variable):**  
  Una linea como `T(x);` puede ser la declaracion de una variable `x` de tipo `T`, o puede ser una llamada a una funcion `T` pasandole `x`. El escaner no puede saber como tokenizar `T` sin preguntarle a la tabla de simbolos del parser si `T` es un tipo de dato o una funcion (tecnica conocida como *Lexer Hack*). Flex no ofrece un canal bidireccional simple para este tipo de retroalimentacion constante.

---

### 4. Lenguajes con interpolacion compleja de expresiones en cadenas (Ruby, Perl, Bash)
Muchos lenguajes permiten incrustar expresiones de codigo completas dentro de un texto entre comillas, como:
`"El resultado total es: #{calcular_total(base, factor) + 10}"`

* **Por que Flex se queda corto:** El escaner tendria que suspender el modo de lectura de texto plano, cambiar al modo de lectura de expresiones completas de codigo (incluyendo llamadas a funciones, operadores, parentesis anidados e incluso otras cadenas interpoladas adentro), y luego volver al modo texto. Manejar esta recursividad con las reglas planas de expresiones regulares de Flex se vuelve extremadamente dificil y desordenado.

---

## Conclusion
Flex es una herramienta excelente para lenguajes donde los tokens son regulares, independientes del contexto y faciles de aislar con expresiones regulares (como C, SQL, JSON o expresiones matematicas). Para lenguajes con indentacion significativa, sin palabras reservadas, o con dependencias fuertes del analizador sintactico, un escaner escrito a mano suele ser una mejor eleccion.
