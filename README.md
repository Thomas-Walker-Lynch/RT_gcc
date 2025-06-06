# RT CPP Extensions and GCC Toolchain

> *Status: Core system functional. CPP extensions fully implemented for GCC 12.4.1 on Debian 12.10. Documentation in progress.*

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

A declarative form of macro definition that allows both the macro name and body to be defined via either literal or expanded token expressions. Unlike `#define`, `#assign` enables delayed evaluation through bracketed forms.

```c
#assign (FOO) (42)        // literal
#assign [BAR] [BAZ]       // expanded name and body
```

Both directives support structured token handling and follow evaluation rules that prevent recursion via standard CPP coloring.

A built-in macro `_ASSIGN` mirrors the `#assign` directive and can be used within macro logic.

---

## Feature Highlights

* Structural support for:

  * Token lists and argument lists
  * Set membership and associative lookups
  * Conditional logic and functional mapping
  * Token pasting with enforced identifier checks

* Declarative macros for:

  * Set creation: `_SET_ADD`, `_SET_IN`
  * Associative sets: `_ASET_ADD`, `_ASET_GET`
  * List linking: `_LIST_CONNECT`, `_LIST_NEXT`

All constructs respect the rules of standard CPP expansion, but introduce functional primitives such as `_MAP`, `_IF`, `_NOT`, and `_PASTE`.

---

## Documentation

All longform documentation is written in Emacs Org-mode format and located under `developer/docs/`. These include:

* `cpp_ext_user_manual.org` — The full RT preprocessor extension specification
* `README.org` files in each build script directory
* `experiments/` — Example use cases, macro-driven constructs, and test expansions

---

## License

This project is licensed under the **MIT License**.
See the `LICENSE.text` file for full terms.

---

If you're experimenting with macro-based metaprogramming in C — or building portable, reusable preprocessor templates — this project may be what you're looking for.
