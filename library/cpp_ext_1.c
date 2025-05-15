/*
These are the recursive extension.

Simple errors can lead to very long error outputs, which might be why
the cpp designers had obviously intended that recursion would not be possible.

To be added:

LIST_TOO_LONG
  
cleanup list
DROP_EMPTY_ALL
DROP_EMPTY_LEFT
DROPE_EMPTY_RIGHT

#define CAT(sep,first,...)                              \

Instead of comma separated lists consider instead to make a list with #define:
```
#define LIST_1
#define LIST_2

#ifdef LIST_2
 ...
``

*/

#ifndef CPP_EXT_1
#define CPP_EXT_1

/*---------------------------------------------------------------------------
  Force extra macro expansion (the EVAL trick)
  This chain of EVAL macros forces the preprocessor to perform many rescans,
  which is necessary to “unroll” recursive macros.
---------------------------------------------------------------------------*/
  //#define EVAL(...)            EVAL1024(__VA_ARGS__)
  #define EVAL(...)            EVAL32(__VA_ARGS__)
  #define EVAL1024(...)        EVAL512(EVAL512(__VA_ARGS__))
  #define EVAL512(...)         EVAL256(EVAL256(__VA_ARGS__))
  #define EVAL256(...)         EVAL128(EVAL128(__VA_ARGS__))
  #define EVAL128(...)         EVAL64(EVAL64(__VA_ARGS__))
  #define EVAL64(...)          EVAL32(EVAL32(__VA_ARGS__))
  #define EVAL32(...)          EVAL16(EVAL16(__VA_ARGS__))
  #define EVAL16(...)          EVAL8(EVAL8(__VA_ARGS__))
  #define EVAL8(...)           EVAL4(EVAL4(__VA_ARGS__))
  #define EVAL4(...)           EVAL2(EVAL2(__VA_ARGS__))
  #define EVAL2(...)           EVAL1(EVAL1(__VA_ARGS__))
  #define EVAL1(...)           __VA_ARGS__

/*---------------------------------------------------------------------------
  Defer macros: these help “hide” recursive calls for additional expansion passes.
---------------------------------------------------------------------------*/
// defined in cpp_ext_0: RETURN_NOTHING()

  #define DEFER1(m) \
    m RETURN_NOTHING()
  #define DEFER2(m) \
    m RETURN_NOTHING RETURN_NOTHING()()
  #define DEFER3(m) \
    m RETURN_NOTHING RETURN_NOTHING RETURN_NOTHING()()()
  #define DEFER4(m) \
    m RETURN_NOTHING RETURN_NOTHING RETURN_NOTHING RETURN_NOTHING()()()()
  #define DEFER5(m) \
    m RETURN_NOTHING RETURN_NOTHING RETURN_NOTHING RETURN_NOTHING RETURN_NOTHING()()()()()

/*---------------------------------------------------------------------------
  List operations

  number of EVALs required depends upon length list that is processed

  REST will return nothing on one of two conditions: that the list has
  been exhausted, or that the list is about to be exhausted and it has nothing
  after the last comma. To assure that a tailing item always gets sent
  to the predicate, even when empty, we append an empty item.

---------------------------------------------------------------------------*/
  // defined in cpp_ext_0: _FIRST(a ,...) a 

  // returns found item or EOL()
  #define _FIND(predicate ,...) \
    IF \
      (__VA_ARGS__) \
      (IF \
        ( predicate(_FIRST(__VA_ARGS__)) ) \
        ( _FIRST(__VA_ARGS__) ) \
        ( DEFER3(_FIND_CONFEDERATE)()(predicate ,REST(__VA_ARGS__)) ) \
        ) \
      (EOL()) 
  #define _FIND_CONFEDERATE() _FIND
  #define FIND(predicate ,...) EVAL( _FIND(predicate ,__VA_ARGS__ ,) )

  // true if list exhausted, false otherwise
  #define _WHILE(predicate ,...) \
    IF \
      (__VA_ARGS__) \
      (IF \
        ( predicate(_FIRST(__VA_ARGS__)) ) \
        ( DEFER3(_WHILE_CONFEDERATE)()(predicate ,REST(__VA_ARGS__)) ) \
        () \
        ) \
      (1) 
  #define _WHILE_CONFEDERATE() _WHILE
  #define WHILE(predicate ,...) EVAL( _WHILE(predicate ,__VA_ARGS__ ,) )

  // returns true or false
  #define _CONTAINS(item ,...) \
    IF \
      (__VA_ARGS__) \
      (IF \
        ( EQ(item ,_FIRST(__VA_ARGS__)) ) \
        ( 1 ) \
        ( DEFER3(_CONTAINS_CONFEDERATE)()(item ,REST(__VA_ARGS__)) ) \
        ) \
      () 
  #define _CONTAINS_CONFEDERATE() _CONTAINS
  #define CONTAINS(predicate ,...) EVAL( _CONTAINS(predicate ,__VA_ARGS__ ,) )

  // if no list, returns EOL(), else returns last item in the list
  #define _LAST(...) \
    IF \
      (__VA_ARGS__) \
      ( _LAST_s(_FIRST(__VA_ARGS__) ,REST(__VA_ARGS__)) ) \
      (EOL())
  #define _LAST_s(item, ...) \
    IF \
      (__VA_ARGS__) \
      ( DEFER3(_LAST_s_CONFEDERATE)()(_FIRST(__VA_ARGS__) ,REST(__VA_ARGS__)) ) \
      (item)
  #define _LAST_s_CONFEDERATE() _LAST_s
  #define LAST(...) EVAL( _LAST(__VA_ARGS__ ,) )

  #define CAT(sep ,...) \
    IF \
      (__VA_ARGS__) \
      (_CAT_s( sep ,__VA_ARGS__))   \
      ()

  #define _CAT_s(sep ,a ,...)\
    IF \
      (__VA_ARGS__) \
      ( EVAL(_CAT_ss(sep ,a ,__VA_ARGS__)) )  \
      (a)

  #define _CAT_ss(sep ,accumulator ,a ,...) \
    IF \
      (__VA_ARGS__) \
      ( DEFER2(_CAT_ss_CONFEDERATE)()(sep ,accumulator##sep##a ,__VA_ARGS__) ) \
      (accumulator##sep##a)

  #define _CAT_ss_CONFEDERATE() _CAT_ss

  // comma does not work with CAT so use this, though perhaps list ,a would be faster?
  #define APPEND(...) \
    IF \
      (__VA_ARGS__) \
      (_APPEND_s(__VA_ARGS__))   \
      ()

  #define _APPEND_s(a ,...)\
    IF \
      (__VA_ARGS__) \
      ( EVAL(_APPEND_ss(a ,__VA_ARGS__)) )  \
      (a)

  #define _APPEND_ss(accumulator ,a ,...) \
    IF \
      (__VA_ARGS__) \
      ( DEFER2(_APPEND_ss_CONFEDERATE)()(accumulator, a, ,__VA_ARGS__) ) \
      (accumulator,a)

  #define _APPEND_ss_CONFEDERATE() _APPEND_ss


/*---------------------------------------------------------------------------
  Quantifiers
---------------------------------------------------------------------------*/

  // AKA all quantification, returns true or false
  #define AND(...) WHILE(EXISTS ,__VA_ARGS__)

  // AKA existence quantification, returns true or false
  #define OR(...)  NOT( WHILE(NOT ,__VA_ARGS__) )

/*---------------------------------------------------------------------------
  Access
---------------------------------------------------------------------------*/

  #define FIRST(...) \
    IF( __VA_ARGS__ ) \
      ( _FIRST(__VA_ARGS__) ) \
      (EOL())


#endif  
