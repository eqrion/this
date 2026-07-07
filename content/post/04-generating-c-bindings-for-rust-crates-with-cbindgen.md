+++
date = "2017-08-30T21:51:26-05:00"
title = "Generating C bindings for Rust crates with cbindgen"
slug = "announcing-cbindgen"
aliases = [
  "generating-c-bindings-for-rust-crates-with-cbindgen/",
  "/post/generating-c-bindings-for-rust-crates-with-cbindgen/",
]
draft = false
tags = ["rust", "ffi", "project"]
description = "Introducing cbindgen, a project for generating a C/C++ header for a Rust library. See also the popular bindgen project which works in the opposite direction. cbindgen will parse a single source or a whole library (including dependent crates) and gather all extern C functions, structs, and enums, and generate matching C/C++ definitons."
disqusid = "1150"
+++

Rust is a great language for doing tasks normally done in C/C++. While it has a minimal runtime and zero-cost abstractions, it also has guaranteed memory safety and high level language features that make programming easier.

Another neat thing about Rust is its ability to have a C FFI. Rust can be used to rewrite parts of an existing C/C++ application without having to rewrite the whole thing.

This means that you can get some of the benefits of Rust, without having to rewrite the whole world (which is often infeasible and tends to introduce new bugs).

<!--more-->

<link href="/css/prism.css" rel="stylesheet" />
<script src="/js/prism.js" async="true"></script>

There's a project in Firefox with this exact idea called [Oxidation](https://wiki.mozilla.org/Oxidation). I've spent some time working on a related project called [Quantum Render](https://wiki.mozilla.org/Platform/GFX/Quantum_Render).

One of the challenges for integration projects like these involves writing bindings for interfacing between languages.

When working on Quantum Render, we tracked down more than one nasty bug caused by an incorrect definition in our handwritten binding headers.

Since no one liked writing binding headers, and no one liked finding these bugs, we decided to write a tool to automate this away so we wouldn't have to deal with it again.

## `cbindgen`

Introducing [`cbindgen`](https://github.com/eqrion/cbindgen/), a project for generating a C/C++ header for a Rust library.

(See also the popular [`bindgen`](https://github.com/rust-lang-nursery/rust-bindgen) project which works in the opposite direction.)

`cbindgen` will parse a single source or a whole library (including dependent crates) and gather all `extern "C"` functions, structs, and enums, and generate matching C/C++ definitons.

All you need to do is design an FFI in Rust for your library, and `cbindgen` will generate a header for you to use in your C or C++ project.

Designing an FFI isn't a trivial process of course, but `cbindgen` makes it easier by elliminating one step in the process.

For some guidance on designing an FFI, I'd recommend taking a look at the [Rust Omnibus](http://jakegoulding.com/rust-ffi-omnibus/).

Now to use `cbindgen` in your project you have two options, either use it over the command line or add it to your `build.rs`.

### Command line

```bash
cd path/to/crate
cargo install cbindgen   # Add --force if you wish to update
cargo build              # cbindgen needs Cargo.lock for finding dependencies
cbindgen -o path/to/header
```

### Build script

Add `cbindgen` as a build script dependency, then add this to your build script:

```rust
// build.rs
extern crate cbindgen;

use std::env;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    cbindgen::generate(&crate_dir)
      .unwrap()
      .write_to_file("bindings.h");
}
```

### Configuration

Whether you are using `cbindgen` over the command line or in a build script, it will look for a `cbindgen.toml` file which can be used to enable or disable just about every feature.

For a list of options, take a look [here](https://github.com/eqrion/cbindgen/blob/master/README.md#configuration).

## Example

For example, let's take a look at a sample Rust library (with some details omitted):

```rust
// trebuchet.rs

#[repr(u8)]
enum Ammo {
    Rock,
    WaterBalloon,
    Cow,
}

#[repr(C)]
struct Target {
    latitude: f64,
    longitude: f64,
}

// notice: #[repr(rust)]
struct Trebuchet { ... }

#[no_mangle]
unsafe extern "C" fn trebuchet_new() -> *mut Trebuchet { ... }

#[no_mangle]
unsafe extern "C" fn trebuchet_delete(treb: *mut Trebuchet) { ... }

#[no_mangle]
unsafe extern "C" fn trebuchet_fire(treb: *mut Trebuchet,
                                    ammo: Ammo,
                                    target: Target) { ... }
```

`cbindgen trebuchet.rs -o trebuchet.h`

```C++
// trebuchet.h

#include <cstdint>
#include <cstdlib>

extern "C" {

enum class Ammo : uint8_t {
    Rock = 0,
    WaterBalloon = 1,
    Cow = 2,
};

struct Trebuchet;

struct Target {
    double latitude;
    double longitude;
};

void trebuchet_delete(Trebuchet *treb);

void trebuchet_fire(Trebuchet *treb, Ammo ammo, Target target);

Trebuchet* trebuchet_new();

} // extern "C"
```

This is exactly what we'd like to see.

1. `Ammo` is given proper size and values
2. `Target` has all the required fields and layout
3. `Trebuchet` is declared as an opaque struct
4. All the functions are given equivalent declarations

## Features

We saw how `cbindgen` handles a straightforward example, let's take a look at some more advanced usage.

### 1. Generic structs

Generic types are common in Rust and are fully capable of being used in an FFI when marked `#[repr(C)]`.

The challenge is manually writing bindings for each instantiation of the generic type.

Thankfully, `cbindgen` can do this for us.

```rust
// buffer.rs

#[repr(C)]
struct Buffer<T> {
    data: [T; 8],
    len: usize,
}

#[no_mangle]
extern "C" fn print_buffer_i32(buf: Buffer<i32>) { ... }

#[no_mangle]
extern "C" fn print_buffer_f32(buf: Buffer<f32>) { ... }
```

`cbindgen buffer.rs -o buffer.h`

```C++
// buffer.h

#include <cstdint>
#include <cstdlib>

extern "C" {

struct Buffer_f32 {
  float data[8];
  size_t len;
};

struct Buffer_i32 {
  int32_t data[8];
  size_t len;
};

void print_buffer_f32(Buffer_f32 buf);

void print_buffer_i32(Buffer_i32 buf);

} // extern "C"
```

Here you can see an instantiation of `Buffer` is generated for each use of `Buffer<T>`.

Additionally, `cbindgen` can output template specialization's to make using `Buffer` more ergonomic.

```C++
template<typename T>
struct Buffer;

template<>
struct Buffer<float> : public Buffer_f32 {

};

template<>
struct Buffer<int32_t> : public Buffer_i32 {

};
```

### 2. Type aliases

It's also common in Rust to use `type` aliases to give a type a different name.

`cbindgen` also understands these and will generate a `typedef` when possible.

For example:

```rust
// type.rs

#[repr(C)]
struct Buffer<T> {
    data: [T; 8],
    len: usize,
}

type IntBuffer = Buffer<i32>;

#[no_mangle]
extern "C" fn print_int_buffer(buf: IntBuffer) { }
```

`cbindgen type.rs -o type.h`

```c
// type.h

#include <cstdint>
#include <cstdlib>

extern "C" {

struct Buffer_i32 {
  int32_t data[8];
  size_t len;
};

typedef Buffer_i32 IntBuffer;

void print_int_buffer(IntBuffer buf);

} // extern "C"
```

The nice part of generating typedefs is that you're still able to refer to `Buffer_i32` if necessary or use `IntBuffer`. They both refer to the same type, as they do in Rust.

### 3. Misc.

There are a lot of smaller features that are easier to just list without examples:

1. Support for C or C++ language output
2. Renaming of struct fields, enum variants, function arguments to different styles
3. Generation of `#ifdef`'s for `#[cfg]` attributes
4. Generation of C++ operators for simple structs
5. Output documentation comments into bindings file
6. Configuration to disable or enable any of the above if desired :)
7. Annotation system to override the configuration for a specific item

`cbindgen` is very configurable, so it can most likely provide something helpful for your unique case. And if there isn't feel free to file an issue or open a PR.

## Future Work

Right now `cbindgen` is good at generating bindings for an already existing FFI.

There are definitely improvements to be made on that front, but what gets me excited is the possibility of generating a correct FFI for Rust code.

1. What if we could get a class definition from a struct and impl?
2. What if we could expose Rust's tagged union with a wrapper class?
3. What if we could use simple `#[repr(rust)]` structs from C/C++?

There's a lot of work to be done here, but right now we're just scratching the surface.

## Conclusion

I'd like to invite anyone who is working on a Rust integration project to give `cbindgen` a try, and please file [issues](https://github.com/eqrion/cbindgen/issues) for any bugs or difficulties you run into.

I'd love to make `cbindgen` as robust and battle-tested as possible, so I appreciate all feedback.

If you're interested in contributing, feel free to comment on any issue and I will provide guidance to the best of my ability.

Thanks!
