# Standalone GCC installation with optional  RT cpp extensions

## State of the scripts 

The default branch is 'core_developers_branch'.  (It is not 'master'.)

The scripts in the script_Deb-12.10_gcc-12.4.1🖉/ directory are currently building gcc-12.4.1 on a Debian-12.10 system. They also work to build gcc-12.4.1 with the optional RT extensions to cpp.

If you are on another system, or using another version of gcc, if the script_Deb-12.10_gcc-12.4.1🖉/ scripts work for you, please note that here.

If you had to modify the scripts to make the install work, please make a new directory with your system and gcc version, and copy and modify the scripts there.

The scripts in the script_gcc-15🖉/ directory do not work. It was difficult to bootstrap a standalone install of the latest gcc, on Deb-12, but I gave it a try. Hence the fall back to the version 12.

## Documentation

Apart from this file, the text documents are written in emacs org format.

To see documentation on how to do the build, read the README in the appropriate script directory. Also note that the scripts themselves list the commands and options used, in the order they are used.


## The RT extentions

The RT extensions won't let you write recrusive macros. My apologies to my cpp magic friends. However, they will let you write sets, and to associate values with set members.  See the documents directory more information.

Also for reference, I put the cpp magic like faux recursion in the top level library directory, but I suspect you won't need it.

### `#rt_macro`

Defines a macro in standard ISO form, using token literal parsing and optional parameter substitution. Basically it is `#define` where the body is contained within parenthesis, and need not be on one line.

#### Syntax (EBNF):

```
directive     ::= "#rt_macro" name params body ;

name          ::= identifier ;

params        ::= "(" param_list? ")" ;
param_list    ::= identifier ("," identifier)* ;

body          ::= "(" literal? ")" ;

literal       ::= ; sequence parsed into tokens without expansion

; whitespace, including newlines, is ignored
```

If you need an unbalanced paren, define a macro that expands to a paren and use that. Parenthesis need only to match when the body is lexed.

### `#assign`

This is another variation on #define. Currently it can not be used to define function like macros. 

Unlike assign, there is an option to expand the name and body before the definition is registered. When the name is expanded, it must expand to an identifier that can be used as a nmae.

Should the body or name contain macros that are expanded, these expansions are done before the macro is put in the symbol table.  Hence, the name.

If the assigned name arrives as an already defined, though disabled macro, `#assign` will clear the disabled flag. This does not enable recursion, but it does enable one more step of evaluation the next time the macro is evaluated. Note that macros are 'painted' during evaluation, so removing the flag only enables evaluation until the macro is painted again.

#### Syntax (EBNF):

    cmd        ::= "#assign" name body ;

    name       ::= clause ;
    body       ::= clause ;

    clause     ::= "(" literal? ")" | "[" expr? "]" ;

    literal    ::= ; sequence parsed into tokens
    expr       ::= ; sequence parsed into tokens with recursive expansion of each token

    ; white space, including new lines, is ignored.

---

#### Examples

See the experiments/ directory for more examples.

```
#assign (A_NAME) (3)
```

Is the same as:

```
#define A_NAME 3
```

```
#define B_NAME Fred
#assign [B_NAME] (5)
```

Is the same as:

```
#define Fred 5
```

### `__CAT(SEP, ...)`

A builtin macro utility for token concatenation with an explicit separator.

Unlike the standard `##` token pasting, `__CAT` allows insertion of a custom separator, and works with variadic arguments. 

**Example:**

```
__CAT(_, foo, bar, baz)  // expands to: foo_bar_baz
```
```
__CAT(, foo, bar, baz)  // expands to: foobarbaz
```


### License

This project is licensed under the **MIT License**.  
See the `LICENSE.text` file for full terms.

## Project Structure / Building

The top level directory is for project overhead files.  Development work is done in the 'developer' directory.  If someday there is a test bench it will go in the 'tester' directory.

Begin the build process by editing the environment setting script, `env_developer` so that it goes to the correct build script directory, then source it.

```
> . env_developer
```

The build script directory will have a README.org, as well as bash scripts that can be read directly.


