# Standalone GCC Installation with Option for RT Mods

As of 2025-05-14:

* Based on GCC 12.4.1
* Builds on Debian 12
* Standalone toolchain build scripts are functional and modular
* Includes `#macro` and `#assign` directive support (RT extensions)

---

## Standalone Build

For those who wish to let the chips fall where they may:

```bash
> source env_toolsmith
> ./build_all.sh
```

Alternatively, read through `build_all.sh` and follow its logic step by step.  
Environment variables are defined in `script🖉/environment.sh` — this file guides where and how components are installed.

---

## The `#rt_macro` and `#assign` Directives

These are two experimental extensions to the C preprocessor (CPP), part of the **RT Extensions**.

To enable them:

```bash
> source env_toolsmith
> ./apply_RT_assign_directive_mod
> ./build_all.sh
```

(At the moment manually copy the directives.cc and macro.cc files back into the source.)

---

### `#rt_macro`

Defines a macro in standard ISO form, using token literal parsing and optional parameter substitution. Equivalent to a cleaner `#define`, with controlled multi-line support and macro parameter semantics.

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

- A `literal` clause is delimited with `(` ... `)` and behaves like `#define F(x) (x + 1)`.
- An `expr` clause is delimited with `[` ... `]` and expands tokens as they are parsed.

If you need an unbalanced parenthesis in the macro, define it to a macro, then include the macro.

#define OPEN (
#assign X() ( OPEN )

---

### `#assign`

Assigns a macro dynamically. It differs from `#macro` by:
- Accepting a **macro name expression** (`name_clause`) which may itself be an expansion
- Accepting a **macro body expression**, optionally with recursive expansion
- Allowing runtime reassignment of macro behavior

_This enables construction of self-modifying or symbolic macros within a source file._

**Note:** `#assign` currently supports expression-based bodies but does not include parameter binding.

#### Syntax (EBNF):

    cmd        ::= "#assign" name body ;

    name       ::= clause ;
    body       ::= clause ;

    clause     ::= "(" literal? ")" | "[" expr? "]" ;

    literal    ::= ; sequence parsed into tokens
    expr       ::= ; sequence parsed into tokens with recursive expansion of each token

    ; white space, including new lines, is ignored.

     This differs from `#define`:
       -name clause must reduce to a valid #define name
       -the assign is defined after the body clause has been parsed

---

### License

This project is licensed under the **MIT License**.  
See the `LICENSE.text` file for full terms.
