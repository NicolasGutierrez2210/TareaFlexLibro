# Ejercicio 6: Comparativa entre contador de palabras en C y Flex

## Pregunta
El ejercicio solicita reescribir el programa contador de palabras (word count) directamente en lenguaje C sin utilizar Flex, ejecutar ambos programas con un archivo de texto grande, y responder:
1. ¿Es la version escrita en C notablemente mas rapida que la de Flex?
2. ¿Que tan mas dificil resulta de depurar y mantener?

---

## Implementacion

### 1. Version en C (`wc_c.c`)
En C se implementa un bucle `while` que lee caracter por caracter utilizando `getchar()`. Para contar las palabras se utiliza una bandera de estado (`in_word`) que detecta transiciones entre caracteres alfabeticos y separadores:
* Si el caracter es una letra (`isalpha(c)`) y no estabamos dentro de una palabra, se incrementa el contador de palabras y se activa la bandera.
* Si el caracter no es una letra, se desactiva la bandera.
* Cada `\n` suma una linea y cada caracter leido suma al total de caracteres.

### 2. Version en Flex (`wc_flex.l`)
En Flex no se programan banderas de estado manualmente. Se define la regla `[a-zA-Z]+` para que el automata de Flex consuma palabras completas de una sola vez, sumando la longitud directamente al contador de caracteres y aumentando el contador de palabras.

---

## Resultados de las pruebas (Benchmark)

Para la prueba se genero un archivo de texto de aproximadamente 22 MB con 500,000 lineas y 4.5 millones de palabras.

### Tiempos de ejecucion en WSL (Ubuntu):
* **Version en Flex (`wc_flex`):** ~0.46 segundos.
* **Version en C Puro (`wc_c`):** ~0.74 segundos.

Ambas versiones produjeron exactamente el mismo conteo:
* Lineas: 500,001
* Palabras: 4,500,000
* Caracteres: 22,000,001

---

## Analisis y conclusiones

### 1. Rendimiento y velocidad
Contrario a la creencia comun de que el codigo escrito a mano en C siempre supera a una herramienta generadora, la version de **Flex resulta ser mas rapida**.

Esto se debe a dos razones tecnicas:
* **Manejo de buffers:** Flex lee la entrada en bloques grandes de memoria (buffers de 16 KB de forma predeterminada), minimizando las llamadas al sistema. La funcion basica `getchar()` en C, aunque tiene buffer interno de `stdio`, realiza comprobaciones adicionales por cada llamada individual.
* **Automata finito optimizado:** El escaner generado por Flex procesa patrones completos mediante tablas de transicion de estados precalculadas, reduciendo el numero de comparaciones logicas por caracter.

### 2. Dificultad de depuracion y mantenimiento
* **En C:** El programador es responsable de controlar todos los casos borde (transiciones de estado, fin de archivo repentino, caracteres no estandar, saltos de linea de Windows `\r\n` vs Unix `\n`). Conforme el formato del lenguaje a reconocer se vuelve mas complejo (por ejemplo, si agregamos numeros flotantes con exponentes o comentarios), el codigo en C se llena de bucles anidados y condiciones dificiles de depurar.
* **En Flex:** El codigo es declarativo, corto y facil de modificar. Si se desea cambiar la definicion de lo que constituye una palabra, basta con cambiar la expresion regular en una sola linea y Flex regenera toda la logica interna de estados sin riesgo de introducir errores manuales.

---

## Guia de compilacion y ejecucion

### Compilar y ejecutar a mano

1. Compilar y probar la version en C puro:
```bash
gcc -O2 wc_c.c -o wc_c
./wc_c < archivo_prueba.txt
```

2. Compilar y probar la version en Flex:
```bash
flex wc_flex.l
gcc -O2 lex.yy.c -o wc_flex
./wc_flex < archivo_prueba.txt
```

### Ejecutar el benchmark (pruebas)
El script genera un archivo de prueba grande, compila ambas versiones con optimizacion `-O2`, mide los tiempos de ejecucion con `time` y limpia los archivos temporales:

```bash
chmod +x benchmark.sh
./benchmark.sh
```
