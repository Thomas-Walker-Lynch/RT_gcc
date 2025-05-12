#include <stdio.h>


#define X  Q()B()(C)
#define Q() A
#define A(x) 21
#define B()

#define P(x) x

int main(){
  printf("X %d" ,P(X));
}

/*
2025-05-12T03:00:19Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> /bin/gcc test_recursive_define_1.c 

2025-05-12T03:00:51Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> ./a.out
X 21
2025-05-12T03:00:55Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> gcc test_recursive_define_1.c 

2025-05-12T03:01:03Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> ./a.out
X 21
2025-05-12T03:01:05Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> gcc -E -P test_recursive_define_1.c | tail -n 5
extern int __overflow (FILE *, int);

int main(){
  printf("X %d" ,21);
}

2025-05-12T03:01:11Z[developer]
Thomas-developer@StanleyPark§/home/Thomas/subu_data/developer/N/developer/experiment§
> 
*/
