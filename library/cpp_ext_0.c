/*
  See also 
    https://github.com/18sg/uSHET/blob/master/lib/cpp_magic.h 
    and tutorial at: http://jhnet.co.uk/articles/cpp_magic

    documents in $REPO_HOME/developer/document🖉

1. We use a truth of existence

   An empty value is false. Anything else is true. Hence, even the token '0' is true.

2. todo

- cpp_ext as separate project
- make the try into tests
- cpp_ext macros put into a namespace to prevent aliasing

*/

#ifndef CPP_EXT_0
#define CPP_EXT_0

/*---------------------------------------------------------------------------
 DEBUG
---------------------------------------------------------------------------*/

#include <stdio.h>
#define DEBUG_CPP

// print the macro and the evaluation of the macro at compile time:
//   #pragma message( STR_VAL(<macro>) )

#define STR(...) #__VA_ARGS__
#define VAL(...) STR(__VA_ARGS__)
#define STR_VAL(...) #__VA_ARGS__ " -> " VAL(__VA_ARGS__)

// print the macro and the evaluation of the macro at run time:
#define SHOW(expr) printf("%s -> %s\n", #expr, STR(expr));

/*---------------------------------------------------------------------------
Constants
---------------------------------------------------------------------------*/

#define NOTHING

#define COMMA ,
#define SEMICOLON ;

// 'twion' is a two component object that masquerades as a single object
#define _TWION_0 ~,0
#define _TWION_1 ~,1

/*---------------------------------------------------------------------------
Fixed arg count concatenation

  Not implemented for elegance, rather CAT is used to force evaluation of arguments before `##`.
*/

#define _CAT2(a ,b) a ## b
#define CAT2(a ,b) _CAT2(a ,b)

#define _CAT3(a ,b ,c) a ## b ## c
#define CAT3(a ,b ,c) _CAT3(a ,b ,c)

#define _CAT4(a ,b ,c ,d) a ## b ## c ## d
#define CAT4(a ,b ,c ,d) _CAT4(a ,b ,c ,d)

/*---------------------------------------------------------------------------
LOGIC

  empty - false
  NOT() - not empty, is true
*/

  //----------------------------------------
  // primitive access

  //  _FIRST with zero arguments returns nothing, otherwise returns first token
  //  in the list, which can also be nothing.  e.g. _FIRST(,2,3) returns nothing.
  #define _FIRST(a ,...) a

  //  _SECOND must be given a list of length 2, though no tokens need be given
  #define _SECOND(a ,b ,...) b

  //----------------------------------------
  // given one or zero arguments, returns nothing
  //
  #define RETURN_NOTHING()

  //----------------------------------------
  // given a list returns a token
  // given an token returns a token
  // given nothing, returns nothing
  //
  #define _OR(...) _FIRST(RETURN_NOTHING __VA_ARGS__ ())

  /*----------------------------------------
   given a token returns nothing
   given nothing returns 1

   `##` prevents rewrite of _TWION_ in the _EXISTS_TOKEN_1 macro, don't
   replace that with CAT!   
  */
  #define _NOT_TOKEN_ss(x_token) _SECOND(x_token ,) 
  #define _NOT_TOKEN_s(x_token)  _NOT_TOKEN_ss(_TWION_1##x_token)
  #define _NOT_TOKEN(x_token)   _NOT_TOKEN_s(x_token)

  /*----------------------------------------
   given a token or a list, returns nothing
   given nothing, returns 1
  */
  #define NOT(...) _NOT_TOKEN( _OR(__VA_ARGS__) )

  /*----------------------------------------
   given argument is empty returns empty
   given argument is not empty, returns 1
  */
  #define EXISTS(...) NOT( NOT(__VA_ARGS__) )

  // useful synonym
  #define MATCH_RWR(x) NOT(x)

/*---------------------------------------------------------------------------
  IF-ELSE construct.
  Usage: IF_ELSE(condition)(<true case>)(<false case>)

  A most amazing little macro. It has no dependencies on the other macros
  in this file, though many of those will be useful in predicates
*/

  #define IF(...)  CAT2(_IF_ ,EXISTS(__VA_ARGS__))
  #define _IF_1(...)          __VA_ARGS__ _IF_1_ELSE
  #define _IF_(...)                       _IF__ELSE
  #define _IF_1_ELSE(...)
  #define _IF__ELSE(...)      __VA_ARGS__

/*---------------------------------------------------------------------------

  In cpp_ext logic:
    ε  is false and anything else is true

  In BOOLEAN logic
    ε is an error, 0 is false, anything else is true

  USE this operator to convert something in cpp_ext logic to something for
  the built-in operators.

  Note the output of BOOLEAN is always an existing token, so it will
  aways be 'true' in cpp_ext logic.

*/
  #define BOOLEAN(...) IF(__VA_ARGS__) (1) (0)


/*---------------------------------------------------------------------------
  Logic connectors
*/
  #define LEQ2(x ,y) IF(x) (y) (NOT(y))
  #define XOR2(x ,y) IF(x) (NOT(y)) (y)
  #define AND2(x ,y) IF(x) (y) ()
  #define  OR2(x ,y) IF(x) (1) (y)

/*---------------------------------------------------------------------------
  Set
    User must define set members manually:

    #define <set_name>__<member>

    For example a set named TRIP with 1 ,2 ,3 in it:

    #define SET_TRIP__1
    #define SET_TRIP__2
    #define SET_TRIP__3

*/

#define IN(name ,x) NOT(CAT4(SET_ ,name ,__ ,x))
#define NOT_IN(name ,x) CAT4(SET_ ,name ,__ ,x)


/*---------------------------------------------------------------------------
  Registered Equivalence

  Checks if x and y have been paired in a rewrite rule.

  Logic values can not be paired, as anything except an empty argument is taken as true.

  each pairing rule has the form
     EQ__<x>__oo__<y>

  for example:
    #define EQ__APPLE__oo__APPLE
    #define EQ__PEAR__oo__PEAR

    SHOW( EQ(APPLE ,APPLE) ); -> 1
    SHOW( EQ(APPLE ,PEAR) ); -> ε

  // if empty should be EQ to empty, add this
  // without this, EQ(,) -> ε
  #define EQ____oo__

---------------------------------------------------------------------------*/

  // if empty should be EQ to empty, keep this
  // without this, EQ(,) -> ε
  #define EQ____oo__

  #define EQ__0__oo__0
  #define EQ__1__oo__1

  #define EQ(x_token ,y_token) MATCH_RWR( CAT4(EQ__ ,x_token ,__oo__ ,y_token) )

/*---------------------------------------------------------------------------
Remainder of list
---------------------------------------------------------------------------*/

  #define _REST(a ,...) __VA_ARGS__
  #define REST(...)\
    IF \
      (__VA_ARGS__)            \
      ( _REST(__VA_ARGS__) ) \
      ()

#endif
/*
  _FIRST(1) -> 1
  _FIRST() -> 
  _SECOND(1,2) -> 2
  _SECOND(1,) -> 

  RETURN_NOTHING() -> 

  _OR() -> 
  _OR(1) -> RETURN_NOTHING 1 ()
  _OR(1,2,3) -> RETURN_NOTHING 1

  T(x) -> 7
  _NOT_ITEM() -> _NOT_ITEM()
  _NOT_ITEM(1) -> _NOT_ITEM(1)
  _NOT_ITEM(T(x)) -> _NOT_ITEM(7)

  NOT() -> 1
  NOT(1) -> 
  NOT(T(x)) -> 
  NOT(1,2,3) -> 

  BOOL() -> BOOL()
  CAT2(_IF_ ,BOOL()) -> _IF_BOOL()

  TO_1_OR_0() -> TO_1_OR_0()
  TO_1_OR_0(1) -> TO_1_OR_0(1)
  TO_1_OR_0(x) -> TO_1_OR_0(x)
  TO_1_OR_0(1.2.3) -> TO_1_OR_0(1.2.3)

  EXISTS() -> 
  EXISTS(0) -> 1
  EXISTS(x,y,z) -> 1

  LEQ2( , ) -> 1
  LEQ2( , 1 ) -> 
  LEQ2( 1, ) -> 
  LEQ2( 1, 0 ) -> 0

  XOR2( , ) -> 
  XOR2( , 0 ) -> 0
  XOR2( 0, 0 ) -> 

  AND2( , 0 ) -> 
  AND2( 0, 1 ) -> 1

  OR2( , ) -> 
  OR2( , 0 ) -> 0

  EQ(APPLE ,APPLE) -> 1
  EQ(APPLE ,PEAR) -> 
  EQ(PEAR ,PEAR) -> 1
  EQ(,) -> 1
  EQ(,PEAR) -> 
  EQ(PEAR ,) -> 

  BOOLEAN() -> 0
  BOOLEAN(0) -> 1
  BOOLEAN(foo) -> 1
  BOOLEAN(1,2,3) -> 1

  REST() -> 
  REST(1) -> 
  REST(1,2) -> 2
  REST(1,2,3) -> 2,3
*/
