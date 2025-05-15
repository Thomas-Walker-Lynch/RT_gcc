#include <stdio.h>

#assign ()(Number)(0x2d9)

#assign ()(NAME)(ONE)
#assign ()[ NAME() ](1)

#undef NAME
#define NAME TwentySeven
#assign ()[NAME](
  Number / 27
)

int main(void){
#if 1
  printf("forty-two: %x\n" ,Number);
  printf("ONE: %x\n" ,ONE);
  printf("TwentySeven: %x\n" ,TwentySeven);
#endif
  printf("And thus begins the dance.\n");
  return 0;
}
