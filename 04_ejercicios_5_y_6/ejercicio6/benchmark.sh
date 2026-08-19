#!/bin/bash
gcc -O2 wc_c.c -o wc_c
flex wc_flex.l
gcc -O2 lex.yy.c -o wc_flex

echo "Generando archivo de prueba grande (aprox. 22 MB)..."
python3 -c "print('The quick brown fox jumps over the lazy dog\n' * 500000)" > big_test.txt

echo ""
echo "=== 1. Ejecucion Version C Puro ==="
time ./wc_c < big_test.txt

echo ""
echo "=== 2. Ejecucion Version Flex ==="
time ./wc_flex < big_test.txt

rm big_test.txt
