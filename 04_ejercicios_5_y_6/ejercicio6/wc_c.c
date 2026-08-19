#include <stdio.h>
#include <ctype.h>

int main(int argc, char **argv)
{
    int c;
    int chars = 0;
    int words = 0;
    int lines = 0;
    int in_word = 0;

    while((c = getchar()) != EOF) {
        chars++;
        if(c == '\n') {
            lines++;
        }
        if(isalpha(c)) {
            if(!in_word) {
                in_word = 1;
                words++;
            }
        } else {
            in_word = 0;
        }
    }

    printf("%8d%8d%8d\n", lines, words, chars);
    return 0;
}
