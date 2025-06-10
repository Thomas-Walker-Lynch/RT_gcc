# RT CPP Extensions and GCC Toolchain

> **Status:** This project builds a standalone GCC 12.4.1 on Debian 12.10, with optional support for the RT Extensions to the C Preprocessor. Scripts are modular, reproducible, and under active refinement.

---

## Overview

This repository provides a structured toolchain for building GCC with optional support for the RT Extensions to the C Preprocessor (CPP). These extensions modernize the C macro system to support reusable structural templates, controlled evaluation, and functional-style transformations — all within the semantics of standard C.

The project is designed for clarity and reproducibility. Each script series targets a specific GCC version and platform, enabling consistent builds for both development and experimentation.

---

## RT CPP Extensions

The RT Extensions introduce new preprocessor directives and built-in macros that enable:

- Multiline macros and declarative definitions
- Token and argument list transformations
- Structural and functional macro programming
- Compatibility with standard CPP behavior

These capabilities allow type templates, associative sets, conditional logic, and macro-driven abstraction layers — all expressed in standard C headers.

Detailed documentation is located in the `developer/` directory.

---

## Repository Structure

- `developer/` — Core documentation, macro definitions, experiments, and examples  
- `script_Deb-12.10_gcc-12.4.1🖉/` — Working scripts for building GCC 12.4.1 on Debian 12.10  
- `script_gcc-15🖉/` — Preliminary scripts for GCC 15.x (experimental)  
- `LICENSE.text` — MIT License

---

## Getting Started

To configure your shell environment for building and testing:

```bash
. env_developer
```

Each script directory contains its own `README.org` and a set of executable scripts representing the build sequence. These scripts are idempotent and document the actual commands used to construct the toolchain.

---

## License

This project is licensed under the **MIT License**.  
See `LICENSE.text` for full terms.
