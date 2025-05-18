#include <stdio.h>

#rt_macro Q(f ,...)(
 printf(f ,__VA_ARGS__) 
)

int main(void){
  Q("%x %x %x" ,1 ,2 ,3);
  putchar('\n');
  return 0;
}
