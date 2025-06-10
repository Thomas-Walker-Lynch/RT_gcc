#include <stdio.h>
/*
tests that built in macro stubs are present, this will not work when the macros have implementations.
*/

#if 0
    _ASSIGN
    _TO_ARG_LIST
    _TO_TOKEN_LIST
    _FIRST
    _REST
    _MAP
    _AL_MAP
    _IF
    _NOT
    _AND
    _OR
    _IS_IDENTIFIER
    _IS_NAME
    _PASTE
#endif

int main(void){
  _ASSIGN(X)(5);
  printf("X: %d" ,X);

  return 0;
}
