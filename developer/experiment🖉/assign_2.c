#include <stdio.h>

#if 0
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
#define SHOW_MACRO(x) _Pragma(TOSTRING(message(#x " → " TOSTRING(x))))

SHOW_MACRO(a)
SHOW_MACRO(b)

SHOW_MACRO($a)
SHOW_MACRO($b)
#endif

#define a 2
#define b 3
#assign (ADD) [a + b]

int main(void){
    printf("2 + 3 = %d\n", ADD);
    return 0;
}
