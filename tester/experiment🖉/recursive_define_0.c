#include <stdio.h>


#define X  Q()B()(C)
#define Q() A
#define A(x) 21
#define B()

int main(){
  printf("X %d" ,X);
}

/*

So cpp truly does walk the token list with `cpp_get_token_1(pfile, &loc);` expanding each token one by one left to right. We should be able to get the desired expansion by adding another layer of macros, so that the argument expansion catches the final A(c).

2025-05-12T02:53:59Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> gcc test_recursive_define_0.c 
test_recursive_define_0.c: In function ‘main’:
test_recursive_define_0.c:5:13: warning: implicit declaration of function ‘A’ [-Wimplicit-function-declaration]
    5 | #define Q() A
      |             ^
test_recursive_define_0.c:4:12: note: in expansion of macro ‘Q’
    4 | #define X  Q()B()(C)
      |            ^
test_recursive_define_0.c:10:18: note: in expansion of macro ‘X’
   10 |   printf("X %d" ,X);
      |                  ^
test_recursive_define_0.c:4:19: error: ‘C’ undeclared (first use in this function)
    4 | #define X  Q()B()(C)
      |                   ^
test_recursive_define_0.c:10:18: note: in expansion of macro ‘X’
   10 |   printf("X %d" ,X);
      |                  ^
test_recursive_define_0.c:4:19: note: each undeclared identifier is reported only once for each function it appears in
    4 | #define X  Q()B()(C)
      |                   ^
test_recursive_define_0.c:10:18: note: in expansion of macro ‘X’
   10 |   printf("X %d" ,X);
      |                  ^

2025-05-12T02:54:17Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> gcc -E -P test_recursive_define_0.c | tail -n 5
extern int __overflow (FILE *, int);

int main(){
  printf("X %d" ,A(C));
}

*?
