# linkrs

A demonstration on how to use multiple rust staticlibs compiled with LTO that may have leaked non-exported symbols in a gcc-compiled executable.

`make direct` takes two static libs (`kv_add` and `kv_sub`) compiled via rustc C with LTO, and tries to use them in a single executable `c/main.c`. This fails due to duplicate symbols leaked during LTO.

`make slim` takes these same static libs, but strips them down so that only `kv_add` and `kv_sub` (also the names of the functions) remain. Specifically, it searches for all symbols with prefix `kv_*`. This succeeds. run with `./build/bin/main_slim`.

If you want to use this for your use case, you will need to change the prefix `kv_*` to whatever prefix(es) you use.
