#include<stdio.h>

#define CAT2(a ,b)  a##b
#define STRING_1(a) #a
#define STRING(a) STRING_1(a)

int main(){
  printf("ab: %s." ,STRING(CAT2(a ,b)));
  printf("gcc -E this one: %s." ,STRING(CAT2(a ,+)));
}
