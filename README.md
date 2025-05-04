# Standalone GCC Installation with option for RT mods.

As of 2025-05-04:
* Based on GCC 15.1.0
* I'm still tweeking the standalone scripts.
* Have not yet integrated any of the RT mods.

## Standalone build

For those who desire to watch the chips stand where they may:

```
> source env_toolsmith
> ./build_all.sh
```

Otherwise read `build_all.sh` and follow the steps.

Note the file 'script🖉/environnment.sh' for the variables that guide the installation.

## The `#assign` directive.

Requires running:

```
> source env_toolsmith
> ./apply_RT_assign_directive_mod
> ./build_all.sh
```

### License

The code in this project is released under the **MIT License**, see the LICENSE.text file for details.
