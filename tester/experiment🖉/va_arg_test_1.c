#include <stdio.h>

#define A(...) (__VA_ARGS__)


int main(void){
    printf( "The answer is: %d\n", A(1,2,3) );
    return 0;
}
