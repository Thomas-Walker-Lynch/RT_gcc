#include <stdio.h>

#macro Q(f ,...)(
 printf(f ,__VA_ARGS__) 
)

int main(void){
  printf("5: %x" ,I(5));
  Q("%x %x %x" ,1 ,2 ,3);
  putchar('\n');
  return 0;
}
