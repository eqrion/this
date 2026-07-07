+++
title = "Just Keep At It: A Decade at Mozilla"
date = "2026-07-07T09:00:00-06:00"
slug = "ten-years-at-mozilla"
tags = ["mozilla", "wasm"]
description = "How ten years at Mozilla happened, from a graphics intern in 2016 to working on the WebAssembly standard. A look back at how I got here, what I learned along the way, and why I'm still here."
draft = false
+++

Well, that went by quick!

I joined Mozilla as an intern in 2016. I wouldn't believe you if you told me I'd still be here in 2026, working on their WebAssembly engine and contributing to the WebAssembly standards process.

Ten years at one company is a long time in this industry. I'm feeling a bit sentimental, so I thought I'd share how that happened, and why I'm still here.

<!--more-->

## Beginnings

I came to Mozilla through [Rust](https://rust-lang.org). I was a CS student at Bethel University at the time, interested in this new systems language, and Mozilla was the company building it.

There was no Rust internship on offer, so I applied for the two roles that came closest to what I cared about: one on their Graphics team, and one on SpiderMonkey (Mozilla's JavaScript engine).

I got the Graphics one. Not my first choice, but I knew I was a long shot for the compiler role.

I spent that summer in Mozilla's Mountain View office, thrown into the largest and most complex codebase I'd ever seen. Parts of it about as old as I was! There was no hand-holding. You either needed to ping the right person on IRC (RIP), or figure it out yourself.

<figure>
  <img src="/images/ten-years-at-mozilla/first-desk.jpg" alt="My desk during my internship">
  <figcaption>My desk at Mozilla's Mountain View office from when I was an intern</figcaption>
</figure>

<figure>
  <img src="/images/ten-years-at-mozilla/first-day-whiteboard.jpg" alt="A whiteboard from my first day, sketching out Firefox's async pan/zoom architecture">
  <figcaption>Whiteboard design firehose from within an hour after starting</figcaption>
</figure>

It was hard, and I enjoyed it. I learned more that summer than all my years in college combined.

I spent most of that summer wrestling with impostor syndrome (TBH, I probably still have it). Getting a full-time offer should've challenged that notion, but somehow it didn't.

Mozilla originally asked that I move to Toronto as a condition of joining full-time, but I was able to negotiate to try out remote first. I wanted to be near my family back in Minnesota, including my now-wife. Mozilla has been accepting of remote work, and it's a big strength.

Over the next few years I worked across the graphics engine in Firefox: the GPU process, off-main-thread painting, async pan-zoom, CSS scroll anchoring, and eventually a bit of Fission too.

## The switch

By 2019, after three years on the Graphics team, I was ready for a new challenge.

A position opened on the WebAssembly team, part of SpiderMonkey, the same area I'd originally applied to as an intern. I applied again. I didn't have any formal compiler background, just some reading and hacking on things in my spare time. I don't know exactly why they took a chance on me, but I'm thankful they did.

Getting started on the WebAssembly team was, if anything, harder than my first days on Graphics. I was pretty good at navigating a complicated codebase at that point. But for SpiderMonkey that was just table stakes. To really contribute, I needed to learn the theory and practice of compilers. It was (and is) a lot to learn, but I was excited to be paid to do it.

When our previous team lead moved on in 2022, I stepped into a larger role, taking on Mozilla's representation in the [WebAssembly Community Group](https://www.w3.org/community/webassembly/) and the standards process.

<figure>
  <img src="/images/ten-years-at-mozilla/wasman.jpg" alt="WasMan, a small red robot toy with a WebAssembly logo on its chest">
  <figcaption>WasMan, from a WebAssembly CG meeting in Pittsburgh</figcaption>
</figure>

It's strange to think the compiler role I was a long shot for as an intern is where I ended up all along, and it's turned into the most rewarding work of my career.

## What I've learned

### The web is actually great

When I started, I wasn't interested in the web as a platform, only in low-level systems like computer graphics or compilers. My vague opinion was that the web should've just been POSIX with a GPU API.

Ten years in, I've come to appreciate the web. It solves genuinely hard problems, and has survived multiple technology shifts while other platforms failed. It's easy to take for granted.

A web browser handles several difficult things at once:
  1. **Strict backwards compatibility**: "don't break the web".
  1. **Open standards**: the web is defined by standards, not just a single company or implementation.
  1. **Portability**: the web runs on TVs, mobile devices, laptops, desktops, and servers.
  1. **User control over content**: ad blocking, client-side translations, reader mode, and others.
  1. **No central gatekeeper**: anyone can buy a domain and launch a website. There is no approval process or app store.
  1. **Untrusted content**: it's expected to be reasonably safe to open up an arbitrary link. Browsers must protect users.
  1. **Performance**: users expect all this to run as close to native speeds as possible.

If you want a simpler and better replacement for the web platform, you need to grapple with all of those things. I've come to realize there is an essential complexity to this problem that I had overlooked.

Sure, there are parts you'd redesign given a clean slate. But no alternative has taken hold, and I don't think that's an accident. Designing something better is hard.

### Focus on what you can control

Mozilla has not always been a calm organization. There have been strategy shifts, reorgs, and layoffs over the years. Early on, that uncertainty was distracting. Over time I've learned to narrow my focus: do good work and focus on advancing the web. I hope my work on wasm and the web will outlive any particular organization.

In addition, the web platform org within Mozilla has been a stable home, staffed by some of the most tenured people at the company. I've been lucky to be part of it.

### It's okay to be optimistic

Early on in my time at Mozilla, there was a big debate internally about whether to adopt Rust. The language wasn't even at 1.0 yet, and people were skeptical whether it would last. Was it worth betting on?

I wasn't sure what we should do. I liked Rust, and it was part of why I had joined, but I can also be pretty cynical, and the odds of a new language succeeding are vanishingly small.

My manager at the time shared a story that stuck with me: when he was starting out, there was a new language called Python his team was wrestling with adopting, unsure of its longevity. He said, "You never really know how things will turn out. It's okay to take a risk on something new."

In the years since, Rust has taken off and gotten wide adoption across the industry. Does that mean you should take a chance on anything? Absolutely not. But I've learned to be a bit less cynical.

### Just keep at it

Both times I joined a new team, I didn't have any prior experience. In both cases, what got me through was to keep trying and to be willing to feel lost for as long as it takes.

The problems we work on at Mozilla are hard. I've had to teach myself things I ideally could have studied formally. I've come to accept that it's okay to be self-taught if you pair it with enough hard work.

The flip side: I've spent a lot of time learning things the hard way when I could've just asked someone. Working smart, not just hard, is something I'm still figuring out.

## Looking ahead

I'm still genuinely excited about WebAssembly. I think the best years for it are still ahead. Mozilla is looking to make [wasm a first-class citizen on the web](https://hacks.mozilla.org/2026/02/making-webassembly-a-first-class-language-on-the-web/) and wasm components are a big part of that.

But honestly, that's only half of it. Ten years in, I'm still here because I get to work on hard problems, with world-class engineers, on a platform I've come to believe in.

Here's to whatever the next stretch holds!
