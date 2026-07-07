+++
date = "2018-10-05T08:08:20-05:00"
title = "Future directions for cbindgen (rust-ffi)"
slug = "future-directions-for-cbindgen"
aliases = [
  "future-directions-for-cbindgen-rust-ffi/",
  "/post/future-directions-for-cbindgen-rust-ffi/",
]
draft = false
tags = ["rust", "ffi", "project"]
description = ""
disqusid = "1151"
+++

<link href="/css/prism.css" rel="stylesheet" />
<script src="/js/prism.js"></script>

It's been over a year since I first wrote about [`cbindgen`](https://github.com/eqrion/cbindgen). A lot has happened since then.

We've had a few new features added ([tagged enums!](https://twitter.com/Gankro/status/958071737492627457)), it's seen some good use ([25k all time downloads!](https://crates.io/crates/cbindgen)), and there was a talk given at a [rust berlin meetup](https://youtu.be/-IQ62T0bllw?t=5631)!

This project started out as a quick fix for a problem we were facing at Mozilla. I thought others might find it useful so I open sourced it. It's the first time I've ever ran an open source project, and I've learned a lot.

To this day, I'm continually surprised to see people using this tool and going through the effort to improve it. To everyone who's helped out, thank you!

There is one issue I'd like to write about though.

<!--more-->

## State of the union

There's been a persistent set of issues we've had with `cbindgen` that have not been solved. They all roughly result from the same problem; `cbindgen` is a standalone parser of rust code, not a `rustc` plugin.

This choice was made for a variety of reasons, ease of implementation being the first and foremost.

What this means is that `cbindgen` doesn't understand your rust library like the compiler does. We've tried to minimize the differences here by making `cbindgen` smarter, but it's not obvious that's the best approach going forward.

To make this concrete, here are some of the problems.

#### 1. Path resolution

The most common problem is with paths. Currently `cbindgen` assumes there is at most one item with each name and that it's always reachable. It doesn't do proper path resolution.

For example:

```rust
mod bar1 {
    #[repr(C)]
    struct Bar(i32);
}
mod bar2 {
    #[repr(C)]
    struct Bar(f32);
}
use bar2::*;
// `cbindgen` doesn't know which `Bar` to use
#[repr(C)]
struct Foo(Bar);
```

I've been told that this is one area of `rustc` that is not easy to reimplement in a thorough way, so I've been a bit diswayed from trying.

Additionally, my understanding is that this is changing with [Rust 2018](https://rust-lang-nursery.github.io/edition-guide/rust-2018/module-system/path-clarity.html) and potentially again in the future, which complicates this matter further.

#### 2. Privacy

This is similar to the issue with paths. Currently `cbindgen` doesn't understand if an item is exported from a crate or not.

This is important, as not everything inside of a crate should be exported in a bindings header. I also believe I've heard that `rustc` may assume that it can optimize a `#[repr(C)]` item if it's not exported, making this a potential safety issue as well.

For example:

```rust
mod foo {
    #[repr(C)]
    pub struct Foo(i32);
}
mod bar {
    pub use foo::Foo;
}
pub use bar::*;
// `cbindgen` doesn't know if `Foo` should be exported or not
```

Today, we use the local visibility modifier to guess your intention for the item. So if you add `pub` to it, we assume that it can be reached from outside the crate.

This is obviously not accurate or a great long term solution.

#### 3. Macros

`cbindgen` just parses rust code, so it has no easy way to expand macros. This seems like it might not be a big problem, but it's a common rust idiom to use macros to define items and is surprisingly useful.

Because of that, `cbindgen` added the `expand` option to run the program source through `rustc -Z unstable-options --pretty=expanded`. This runs the compiler to the point of macro expansion and then pretty prints the results. This works, but isn't perfect.

The issue is that `--pretty=expanded` isn't guaranteed to work with hygenic macros, and because of that it's a nightly only option for the foreseeable future.

So it's not easy to use for people on a stable channel and isn't supported in the long term.

#### 4. `#[cfg]`

`cbindgen` tries to produce 'configuration neutral' headers. This means that when we see a `cfg` we try to generate equivalent C preprocessor `#ifdef`s. If we also run into `libc::c_int` we output a C `int`. The final header should be able to be checked in, and compiled on multiple systems.

This can be a bit convenient, but isn't always what people expect.

The hard part here is that this approach is fragile and incomplete. `#[cfg]` attributes receive special evaluation by `rustc`, and it's not trivial to duplicate their semantics. Some `#[cfg]` attributes are supported, and others are not.

For example:

```rust
// This is supported
#[cfg(feature = "ffi")]
#[repr(C)]
struct Foo(i32);

// But this is not?
#[cfg_attr(feature = "ffi", repr(C))]
struct Bar(i32);
```

It'd be nice to support whatever rust you want to write without having to work around `cbindgen`'s limitations.

## A different approach

It's very possible to make `cbindgen` smarter to mitigate these issues, but I'm concerned with the long term health of this approach.

Further efforts to solve these problems will involve reimplementing parts of `rustc`, possibly poorly. These solutions will need to be maintained, and evolved to match changes in rust editions. This could be a decent amount of work for what should just be a binding generator.

So what if `cbindgen` used the compiler for these things instead?

I've thought about this possibility before, but I wasn't sure if `cbindgen` was a good fit.

The issue is that `rustc` has churn, and linking to the internal libraries is intentionally unstable. The footprint of any tool needs to be small enough that updating with changes to `rustc` is easy.

In addition, one of the things I've learned is that everyone wants to customize the output of the header file in complicated ways. The list of [configuration options](https://github.com/eqrion/cbindgen/blob/master/README.md#configuration) has grown to the point where I forget why we even have some options.

A good amount of the source code is devoted to generating, formatting, and customizing C/C++ output. This will probably only grow in the future as well.

If this tool could ever be integrated into `rustc`, it cannot be that large with that much churn. So it seems to me that just linking `cbindgen` with `rustc` is not going to work well.

## rust-ffi

But recently I had the thought, what if instead we split up `cbindgen`?

Imagine this:

1. A compiler shim, `emit-ffi`, which takes a rust crate and emits an `ffi.json` file with the raw details of the FFI. This tool is focused only on emitting the exported items that can participate in an FFI and their relevent metadata.
2. A standalone tool, `c-ffi`, which takes a `ffi.json` and generates a `C/C++` header with all the customization you can imagine. This tool can do language specific processing and formatting to generate the final header.

This seems like it could lower the maintenance and stability concerns enough to be feasible.

I decided this approach was interesting enough to warrant a proof-of-concept and wrote one. You can view it [here](https://github.com/eqrion/rust-ffi).

If you're interested in the what a `ffi.json` could look like, [here's](https://gist.github.com/eqrion/c15361006039e369b0c7a3d9b19a08d7) an example.

The proof-of-concept works pretty well and has similar functionality to the first version of `cbindgen` (minus generics).

## Open questions

There are still some open questions with this approach.

#### 1. Merging with rustc

Is getting `emit-ffi` into `rustc` a viable option in the future? If it's not, is there a way to still make this tool work for users without extraneous steps.

Today you can just `cargo install cbindgen`, and it'd be good to not make that more complicated.

#### 2. `build.rs` scripts

It's possible to write `build.rs` scripts that link to `cbindgen` as a library and invoke it that way. This approach might not make sense if `cbindgen` is a compiler plugin.

#### 3. Build systems

Currently `cbindgen` is very flexible about when it's run and whether the rust source is actually valid, as it's not actually compiling any code. If `cbindgen` was an invocation of `rustc` that may make some uses not feasible.

For example, it can handle references to definitions that don't exist, which has proved useful for [Stylo](https://wiki.mozilla.org/Quantum/Stylo) in Firefox as they also use [`rust-bindgen`](https://github.com/rust-lang-nursery/rust-bindgen) for bindings from Gecko. When `cbindgen` has run, `rust-bindgen` has not yet run so not all definitions are available. This allows them to work around circular dependencies.

I've heard this could be worked around, but just more difficult.

#### 4. `const`

`cbindgen` has support for parsing `const` items and generating equivalent `C/C++` definitions. This is even more fragile and limited than the `#[cfg]` issue listed above, because we're translating `rust` expressions to `C` expressions.

This most likely wouldn't be supported with information we can get from the compiler, although it's possible that trivial primitive types could be supported.

## Feedback

I've learned that it's important to communicate openly when working on an open source project, so I'm asking here for feedback on whether this new approach is viable.

Please let me know about your use cases and how they would be impacted by such a change.

I personally think this new approach is much more technically solid, and I would love to pursue this as a long term replacement for `cbindgen`.

I always read the comments here, and wherever these articles get reposted. I'm also on [twitter](https://twitter.com/eqrion).
