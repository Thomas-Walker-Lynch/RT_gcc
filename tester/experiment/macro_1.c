#include <stdio.h>

#rt_macro I(x) (x)

int main(void){
  printf("5: %x" ,I(5));
  return 0;
}
