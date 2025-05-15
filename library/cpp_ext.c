#ifndef CPP_EXT
#define CPP_EXT

 #include "cpp_ext_0.c"
 #include "cpp_ext_1.c"

  /*
    CONTAINS requires registration of pattern, as examples:

    #define EQ__int__oo__int
    #define EQ__float__oo__float
    #define EQ__char__oo__char
    #define EQ__void__oo__void

  */
 
  #define ·(...)  CAT(· ,__VA_ARGS__)

#endif 
