#include <stdio.h>
//#macro X 42

  #define x 5

/*
  #macro Y(x) ((x * 51))
  #macro Z () (3)
*/

// #macro Q(f ,...) ( printf(f ,__VA_ARGS__) )

//  #macro Q(f ,...) ( printf(f ,__VA_ARGS__) 
//  )

#macro Q(f ,...)(
 printf(f ,__VA_ARGS__) 
)

#if 0
  // The parameter list does not get expanded when scanned, as expected, so this fails.
  // When the parameter is set to 'Y' instead of 'y' this works.
  #define Z 7
  #define y Y
  #macro P(y)(Y+Z)
#endif

#if 0
// The body is not expanded when a macro is defined. However, to get mutliline
// behavior we turned off the directive parsing mode, so this will be interesting
// ...
// Y was not expanded in the definition, so this failed at the expansion point
// of the printf below.
#define Y 5
#macro R(Z)(Y+Z)
#undef Y
#endif

int main(void){
  //  printf("Y: %d\n", Y(3));
  //  printf("Z: %d\n", Z());
  Q("%x %x %x" ,1 ,2 ,3);
  putchar('\n');

  // printf("P: %d\n", P(3));
  // printf("R: %d\n", R(11));

  return 0;
}
