# RT CPP Extensions and GCC Toolchain

> *Status: Scripts build a standalone GCC 12.4.1 on Debian 12.10 with an option for RT's CPP extensions. Directives #macro and #assign are included. The builtin macros are being incorporated, and will hopefully be released soon.*

This repository provides a standalone GCC installation toolkit with optional support for the RT extensions to the C preprocessor. It includes reusable build scripts, macro programming infrastructure, and documentation for the extended CPP environment.

The RT extensions are designed to modernize CPP with structural programming primitives, support for token/argument list transformations, and controlled macro evaluation. They enable the use of type templates and reusable include files in plain C, without altering standard CPP behavior.

---

## Repository Structure

* `developer/` — Core documentation, macro definitions, experiments, and examples
* `script_Deb-12.10_gcc-12.4.1🖉/` — Working scripts for building GCC 12.4.1 on Debian 12.10, with or without the RT extensions
* `script_gcc-15🖉/` — Incomplete scripts for GCC 15.x (experimental)
* `LICENSE.text` — MIT License

---

## How to Build

To begin a build, first set up your environment:

```bash
. env_developer
```

Each script directory contains its own `README.org` and a set of Bash scripts that can be run in order. They are idempotent and reflect the actual command sequence used during the build.

---

## About the RT Extensions

The RT CPP extensions introduce two new macro directives:

### `#macro`

A multiline, ISO-style function macro with literal token bodies and a strict parameter list. Enables readable macro logic that spans lines without escape characters.

### `#assign`

Similar behavior to a non-function, declarative, form of `#define`.  It has both a directive and macro form. In macro form it expands to nothing. When brackets are used instead of parenthesis, the clauses are expanded before the named macro is defined.

```c
#assign (FOO) (42)        // literal
_ASSIGN [BAR] [BAZ]       // expanded name and body
```

Hence in this second case, `BAR` will be expanded and must result in an identifier name, if it is not macro, then it is taken literally.  Also `BAZ` will be expanded if it is a macro, and the result will be the body of the `[BAZ]` macro.

## Built-in Macros

RT introduces functional built-in macros to extend CPP’s token manipulation capabilities. All built-ins are prefixed with `_` and operate without side effects, except `_ASSIGN`.

### _ASSIGN

A macro form of `#assign`. Takes two *clauses* — either parenthesized for literal input, or bracketed for expanded input.

```c
  _ASSIGN (FOO) (42)           // literal name and body
  _ASSIGN [BAR] [BAZ]          // both name and body expanded
```

- ( ... ) ⇒ literal clause (no expansion)
- [ ... ] ⇒ expanded clause (macros are recursively expanded)

This expands to nothing but defines (or overwrites) a macro binding. New macros created via _ASSIGN are *colored* (i.e., inert within the macro that created them).

---

### List Conversions

These help translate between CPP’s two list types: space-separated `token_list` and comma-separated `argument_list`.

```c
  _TO_ARG_LIST(tokens...)        // a b c → a,b,c
  _TO_TOKEN_LIST(a,b,c)          // a,b,c → a b c
```

---

### Token List Operators

```c
  _FIRST(tokens...)              // first token
  _REST(tokens...)               // all but first
  _MAP(f, tokens...)             // f(a) f(b) f(c)
  _AL_MAP(f, a1, a2, ...)        // f(a1) f(a2) f(a3)
```

- _MAP operates on a space-separated token list.
- _AL_MAP operates on a comma-separated argument list.

---

### Logic Primitives

These treat token presence as boolean truth.

```c
  _IF(p, a, b)                   // if p is non-empty → a else → b
  _NOT(p)                        // if p is empty → TRUE else →
  _AND(a1, a2, ...)              // all must be non-empty
  _OR(a1, a2, ...)               // returns first non-empty
```

Notes:
- _AND() expands to nothing if any argument is empty.
- _OR() short-circuits to the first non-empty argument.

---

### Token-Level Predicate

```c
  _IS_IDENTIFIER(x)             // if x is a valid identifier → x else →
```

---

### Token Construction

```
  _PASTE(a, b, c)               // pastes into single token
```

All tokens are concatenated into one; result must be a valid CPP token (e.g., identifier). Invalid pastes result in a compiler error.

---

These primitives enable set manipulation, conditional macros, structural mapping, and functional programming patterns — within standard C preprocessor constraints.

---

## License

This project is licensed under the **MIT License**.
See the `LICENSE.text` file for full terms.

