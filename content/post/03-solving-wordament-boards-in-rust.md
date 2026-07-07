+++
date = "2016-04-06T21:51:26-05:00"
title = "Solving Wordament Boards in Rust"
slug = "solving-wordament"
aliases = [
  "solving-wordament-boards-in-rust/",
  "/post/solving-wordament-boards-in-rust/",
]
description = "After a short break from coding for school, I finally got enough free time to finish a project. One of my favorite puzzle games is game called Wordament. It's a bit old now, but it still has an active community. The game is like Boggle, you get points for building a word across tiles. To be honest, I'm not very good at it. So I thought, why not write a program to give me some answers? So I did. I know that there are other solvers out there, but I just thought it'd be fun to hack together. You can find the end results here!"
draft = false
tags = ["rust", "project"]
disqusid = "1104"
+++

After a short break from coding for school, I finally got enough free time to finish a project. One of my favorite puzzle games is game called [Wordament](http://www.wordament.com/). It's a bit old now, but it still has an active community. The game is like Boggle, you get points for building a word across tiles.

To be honest, I'm not very good at it. So I thought, why not write a program to give me some answers? So I did. I know that there are other solvers out there, but I just thought it'd be fun to hack together.

<!--more-->

You can find the end results [here](https://github.com/eqrion/wordament)!

The program is written in [Rust](https://www.rust-lang.org/) and solves a Wordament board by recursively building words across tiles. There are a lot of combinations of letters on a board, so I limited the search by using a [Trie](https://en.wikipedia.org/wiki/Trie) built from an English dictionary.

Using the Trie, we can always know whether adding a tile to the current word will be a prefix for a solution. If it doesn't then that line of computation is dropped. With this approach, the speed of the program is very fast. It solves boards almost instantly.

The one limiting factor right now is finding a good dictionary. I've built a simple dictionary using [Scowl](http://wordlist.aspell.net/), but there are some false negatives and some false positives. If anyone knows of a better dictionary, please let me know! Overall though, most words are found. The program also support Digrams, Either/Or, Suffixes, and Prefixes, which I think is really cool.

Unfortunately (or fortunately!) with this cheat, it's still not easy to get into even the top 90th percentile. There's just not enough time to find all the words that it gives you. But it works well, and I've already shocked my friends with my overnight improvement!