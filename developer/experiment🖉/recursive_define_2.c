#include <stdio.h>


#define X  Q()B()(C)
#define Q() A
#define A(x) 21
#define B()

#define P X

int main(){
  printf("X %d" ,P);
}

/*
  This does not work because it does not cause an argument evaluation, as did test_recursive_define_1.c

2025-05-12T03:01:11Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> gcc test_recursive_define_2.c 
test_recursive_define_2.c: In function ‘main’:
test_recursive_define_2.c:5:13: warning: implicit declaration of function ‘A’ [-Wimplicit-function-declaration]
    5 | #define Q() A
      |             ^
test_recursive_define_2.c:4:12: note: in expansion of macro ‘Q’
    4 | #define X  Q()B()(C)
      |            ^
test_recursive_define_2.c:9:11: note: in expansion of macro ‘X’
    9 | #define P X
      |           ^
test_recursive_define_2.c:12:18: note: in expansion of macro ‘P’
   12 |   printf("X %d" ,P);
      |                  ^
test_recursive_define_2.c:4:19: error: ‘C’ undeclared (first use in this function)
    4 | #define X  Q()B()(C)
      |                   ^
test_recursive_define_2.c:9:11: note: in expansion of macro ‘X’
    9 | #define P X
      |           ^
test_recursive_define_2.c:12:18: note: in expansion of macro ‘P’
   12 |   printf("X %d" ,P);
      |                  ^
test_recursive_define_2.c:4:19: note: each undeclared identifier is reported only once for each function it appears in
    4 | #define X  Q()B()(C)
      |                   ^
test_recursive_define_2.c:9:11: note: in expansion of macro ‘X’
    9 | #define P X
      |           ^
test_recursive_define_2.c:12:18: note: in expansion of macro ‘P’
   12 |   printf("X %d" ,P);
      |                  ^

2025-05-12T03:02:36Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
>
*/

  
