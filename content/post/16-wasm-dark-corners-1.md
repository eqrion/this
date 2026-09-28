+++
title = "WebAssembly Dark Corners: Part 1 - Control Flow"
date = "2026-07-07T09:00:00-06:00"
slug = "wasm-dark-corners-part-1-control-flow"
tags = ["wasm"]
description = "The first in a series on surprising corners of WebAssembly. This one covers control flow: why Wasm has no direct jumps, how blocks and loops work instead, and the compromises that design forces on toolchains and interpreters."
draft = false
+++

This is the first post in a series called "Wasm Dark Corners". I'd like to talk about the parts of the WebAssembly language that surprise people when they first run into them. There aren't necessarily bad decisions or mistakes, and there were often good reasons for them at the time. But they're surprising, and not widely known outside people who work on Wasm engines or toolchains.

I'm not writing this to dunk on Wasm. In general Wasm is really well designed, and picked the right tradeoffs. I just find that digging into the pain points can be informative.

This first post covers some preliminaries and then explores control flow. If you don't understand control flow at an exact level, the trickier stuff won't make sense either.

I represent Mozilla in the [WebAssembly Community Group](https://www.w3.org/community/webassembly/), but everything here is my own (potentially misinformed) opinion.

<!--more-->

## Stack machine?

A Wasm function has a type: a set of parameter values it's passed, and a set of result values it must produce. Values have value types: `i32`, `i64`, `f32`, `f64` (and [many more](https://webassembly.github.io/spec/core/syntax/types.html#value-types) in the latest version of the spec).

You may have heard that Wasm is a [stack machine](https://en.wikipedia.org/wiki/Stack_machine). Roughly, that means there's an implicit value stack that instructions manipulate. In a [register machine](https://en.wikipedia.org/wiki/Register_machine) like x86 or arm64, you'd say "add this register to that register." In Wasm, you first push values onto the value stack, then pop them with an instruction.

The canonical example:

```wat
;; push i32 onto the stack
i32.const 2

;; push another i32 onto the stack
i32.const 2

;; pop two i32 values, and produce a new one with the result
i32.add
```

That's a 2 + 2, with the result 4 left on the stack. There's a lot of literature on the tradeoffs between stack and register machines. One paper I found useful is: [Virtual Machine Showdown: Stack Versus Registers](https://dl.acm.org/doi/10.1145/1328195.1328197).

So great, we're a stack machine, not a register machine, I can understand that. Except...

## Register machine?

A Wasm function doesn't just have an implicit value stack, it also has typed local variables. Params are implicitly stored in locals, and then a function can declare extra locals on top of that.

You push a local onto the value stack with `local.get`, and you can update one with `local.set`. In effect, locals act like registers, but you still have to push and pop them to actually do anything with them.

```wat
(func $f
  ;; these params become the first locals
  (param $x i32) (param $y i32)

  ;; a result is not a local, it's taken from the final value on the stack
  (result i32)

  ;; locals can be explicitly declared
  (local $z i32)

  local.get $x   ;; push param 0
  local.get $y   ;; push param 1
  i32.add        ;; pop both, push x + y
  local.get $x   ;; push param 0 again
  i32.mul        ;; pop both, push (x + y) * x
  local.set $z   ;; store into local $z

  local.get $z   ;; leave the result on the stack at the end
)
```

## It's a hybrid!

In the end, Wasm is a hybrid architecture: computation is done on a value stack while values can either be stored on the stack or in locals.

For anyone familiar with [Java bytecode](https://en.wikipedia.org/wiki/List_of_JVM_bytecode_instructions), this is a very similar design to the one Java took.

There are several advantages to choosing a hybrid:
  1. Dense encoding: Operands are implicit and so many instructions are just a single opcode byte with nothing else to encode.
  2. You don't need stack-shuffling opcodes: pure stack machines need dup, swap, rot, or pick to use a value twice or get operands into the right order.
  3. Value stack models temporary expressions well: Most values in real code are temporaries used by a single other expression. Stack machines encode this naturally without requiring a producer to invent temporary registers for them.
  4. Locals model stack frames well: Compilers IRs often can map their variables and stack slots directly into locals. Mapping to a pure stack machine would require scheduling each value's live range and emitting stack-shuffling opcodes.

The JVM, CLR, and CPython all have a hybrid design here as well, so Wasm was not alone in this decision.

## The control flow problem

With that background, let's get to control flow. Straight-line code is easy, but what if you need to conditionally execute one thing or another?

In a traditional ISA, you'd have a conditional branch instruction that takes a condition code and does a byte-offset relative jump to another program counter (PC). This runs into some problems!

What if that PC is in the middle of a different instruction? What if the code you branch to expects the register state or stack frame to be different? ISAs can just say that's your fault, duck under OS isolation primitives, and maybe throw on some '[undefined behavior](https://en.wikipedia.org/wiki/Undefined_behavior)' if that doesn't work.

Wasm doesn't have that luxury. Wasm code cannot have undefined behavior, which means that it must be well-typed and have execution rules for all situations. `i32.add` must be guaranteed to be able to pop two `i32` values. The Wasm specification calls this [validation](https://webassembly.github.io/spec/core/valid/conventions.html).

Not only must we be able to validate code, we also want to do it in linear time. Programs can have a lot of code and validating it should not be the bottleneck.

So let's say Wasm had a branch instruction that jumps by a byte offset. If it's a forward branch, you haven't yet seen what's at the target: you don't know if you're jumping into the middle of an instruction, or whether the value stack we have is compatible with the value stack at that location. That design just doesn't work if you want cheap, single-pass validation.

So what do we do?

## Blocks and loops

Wasm went a different way from traditional ISAs. As you execute code, you hit labels, and labels begin new blocks. There are two kinds of labels: a forward one, called [`block`](https://developer.mozilla.org/en-US/docs/WebAssembly/Reference/Control_flow/block), and a backward one, called [`loop`](https://developer.mozilla.org/en-US/docs/WebAssembly/Reference/Control_flow/loop).

Every branch instruction names a label currently in scope. To jump forward, you need to have already opened a `block` that ends where you want to land. To jump backward, you need to have opened a `loop` that starts where you want to return.

```wat
(block $done
  (loop $continue
    ;; branching to $continue goes backward to here!
    
    ;; ... work ...
    local.get $cond
    br_if $done   ;; forward exit, once $cond is true
    br $continue  ;; otherwise, take the backward edge
  )
)
;; branching to $done goes forward to here!
```

Despite the name, `loop` is not equivalent to something like Rust's `loop` expression! In Wasm, reaching the end of a `loop` block just falls through; you only take the back edge if you explicitly branch to it. It's really just a label, not a full control flow construct.

```wat
(loop
  ;; this is not an infinite loop! code actually just falls through
)
```

To figure out which block a branch targets, the branch instruction encodes an index counting up from zero, starting at the nearest enclosing block. This is a [De Bruijn index](https://en.wikipedia.org/wiki/De_Bruijn_index). The text format also allows you to use [S-expressions](https://en.wikipedia.org/wiki/S-expression), instead of a flat sequence of instructions terminated by `end`.

The original example is actually syntax sugar for:

```wat
block
  loop
    local.get $cond
    br_if 1
    br 0
  end
end
```

## The branch family

Beyond the plain, unconditional `br`, there's `br_if`, which pops a condition and either branches or falls through, and `br_table`, which pops an index and jumps to one of a list of labels depending on its value. `br_table` is Wasm's version of a jump table, and it's required to reasonably compile big switch statements.

```wat
(block $case2
  (block $case1
    (block $case0
      local.get $x
      br_table $case0 $case1 $case2
    )
    ;; case 0
    ;; ...
    return
  )
  ;; case 1
  ;; ...
  return
)
;; case 2
;; ...
return
```

## Conveniences: if and select

Two more instructions are worth a quick mention, since they're really just sugar. `if` lets you write a conditional without spelling out nested blocks by hand:

```wat
local.get $cond
(if (result i32)
  (then (i32.const 1))
  (else (i32.const 0))
)
```

You can express the same thing with nested `block`s, but `if` saves binary size and lets baseline compilers do the obvious thing quickly. `select` is the equivalent convenience for a conditional value pick, roughly what a ternary operator compiles to. As far as I know, neither adds any expressive power over blocks; they just make common patterns smaller and faster to compile.

I'm leaving exception handling ([`try`/`catch`](https://developer.mozilla.org/en-US/docs/WebAssembly/Reference/Exception_handling/try_table)) out of this post; it deserves its own dedicated writeup later in the series.

## Validating control flow in linear time

Let's get back to validating control flow.

Labels don't just tell you where to jump, they also tell you what the value stack needs to look like there. A `block` or `loop` has params and results, just like a function does.

When you enter a block, its declared params must already be on the stack, and they become available inside the block. Its declared results must be on the stack at the end of the block, and remain available after it.

When you branch to a label, you therefore need to supply the values it expects. For a backward branch to a `loop`, that means the loop's params, since you're going back to a point that expects them. For a forward branch to a `block`, that means the block's results, since you're jumping to the point right after it, which expects them.

This is easiest with a couple examples:

```wat
(block $done
  ;; this block label declares that an i32 will be available after
  (result i32)

  ;; branching to $done must have an i32 on the stack
  i32.const 42
  br $done
)
;; an i32 is guaranteed on the stack and can be used
```

```wat
(loop $continue
  ;; this loop label declares that an i32 will be available at the beginning
  (param i32)

  ;; branching to $continue must have an i32 on the stack
  ;; the loop already gave us one that we can just forward on
  br $continue
)
```

This doesn't match how real hardware works, or how most programming languages express control flow, but it has two nice properties:
  1. linear-time validation: as you go, you keep a stack of the labels currently in scope along with their params and results, and every branch is a direct lookup and comparison against that stack. 
  2. control flow is always [*structured*](https://en.wikipedia.org/wiki/Structured_programming) and [*reducible*](https://en.wikipedia.org/wiki/Control-flow_graph#Reducibility). Reducible control flow covers what almost every normal program does, while ruling out patterns like jumping into the middle of a loop without going through its header. This can simplify compiler passes, but shifts some burden onto toolchains generating Wasm (see below).

## The good

To summarize: a label stack gives you linear-time validation, and restricting to reducible control flow keeps optimizing compilers simpler, since they can already assume reducibility internally. These are really nice properties and a great achievement!

It's not without downsides though...

## The bad

### How do I generate this?

Wasm's design for control flow is biased toward exactly what JIT compilers would want, and not what language toolchains would like to generate. Most compilers have an internal representation that is a (potentially irreducible) control flow graph. Wasm bytecode is linear, with nested labels, and strictly reducible.

Imagine you had a control flow graph like this:
```
             entry
               |
               v
         +-----------+
   +---->|     A     |
   |     +-----------+
   |       |       |
   |      !x       x
   |       |       |
   |       v       v
   |    +-----+ +-----+
   +-y--|  C  | |  B  |
        +-----+ +-----+
           |       |
          !y       |
           |       |
           v       v
        +-------------+
        |      D      |
        +-------------+
```

How exactly do you go about converting that into this equivalent Wasm:
```wat
(block $D
  (block $B
    (loop $A
      ;; A
      local.get $x
      br_if $B      ;; A -> B

      ;; C
      local.get $y
      br_if $A      ;; C -> A
      br $D         ;; C -> D
    )
  )
  ;; B, then fall through to D
)
;; D
```

Notice that the blocks have to be opened in the reverse order of where they end, the loop needs a manual `br` to avoid falling into `B`, and none of the nesting looks anything like the original graph.

The original solution is Alon Zakai's Relooper algorithm, built for Emscripten: [Zakai, "Reloop All The Blocks"](http://mozakai.blogspot.com/2012/05/reloop-all-blocks.html). It's a greedy, heuristic algorithm over the control-flow graph, and for a long time it was the only game in town. It's complex and is prone to suboptimal translations when the heuristics fail.

There is also [Stackifier](https://labs.leaningtech.com/blog/control-flow) which was built as a successor to Relooper and is used in LLVM.

A newer approach is [Ramsey, "Beyond Relooper: Recursive Translation of Unstructured Control Flow to Structured Control Flow" (ICFP 2022)](https://www.cs.tufts.edu/~nr/pubs/relooper.pdf) which gives a very simple, single-pass algorithm using recursion over immutable ASTs.

It's still not ideal though, and there are proposals to relax Wasm itself so this mapping is less necessary: [the Funclets proposal](https://github.com/WebAssembly/funclets), and [Multiloop](https://gist.github.com/conrad-watt/6a620cb8b7d8f0191296e3eb24dffdef), both of which would let Wasm directly express irreducible control flow.

Neither is being worked on right now, but the door isn't closed on fixing this in the future.

### How do I interpret this?

Sometimes you don't want to (or can't) compile Wasm into machine code, and need to interpret it. Unfortunately, Wasm's control flow design makes this difficult to do efficiently.

When you hit a branch instruction, you don't know its exact target byte offset, only the index of the label it targets. That's great for validation, but bad if you're writing an interpreter that wants to jump to a byte offset.

There are a couple of ways around it. The simplest is to rewrite the bytecode into an internal format while validating, and interpret that instead.

The other, from [Ben Titzer, "A Fast In-Place Interpreter for WebAssembly" (OOPSLA 2022)](https://arxiv.org/abs/2205.01183), is to modify the validation pass to also build compressed side tables that record the resolved target offset for every branch instruction. As far as I know, that's the state of the art for in-place interpreters.

This isn't the only place Wasm makes things difficult for interpreters, but it's one of the bigger ones.

### Linear time?

I mentioned earlier that a major goal was linear-time validation of Wasm bytecode. This was true in Wasm 1.0, but is arguably not anymore after [multi-value](https://github.com/WebAssembly/multi-value/blob/master/proposals/multi-value/Overview.md) was standardized!

[`br_if`](https://developer.mozilla.org/en-US/docs/WebAssembly/Reference/Control_flow/br_if) is a special instruction that conditionally branches to a block, while leaving the value stack as-is in the fallthrough path. To validate the `br_if` you need to compare the top of the value stack against the label, while still leaving the value stack as-is. You can then just do a new `br_if` again.

```wat
(block $skip (result i32 (; ... 999 more times ... ;))
;; push 1000 i32s

i32.const 0 ;; condition code
br_if $skip ;; validates 1000 entries on the stack and leaves them

i32.const 0 ;; condition code
br_if $skip ;; validates 1000 entries on the stack and leaves them

i32.const 0 ;; condition code
br_if $skip ;; validates 1000 entries on the stack and leaves them

i32.const 0 ;; condition code
br_if $skip ;; validates 1000 entries on the stack and leaves them
)
```

Each `br_if` costs `O(stack height)` so validation becomes quadratic in function size.

Don't tell anyone I told you about this! Also please never emit this code or you're in for a bad time.

## What's next

Next up: what happens after an unconditional branch. Should be pretty simple, right? Let's just say this was the most controversial part of Wasm's original design, and is still being debated.
