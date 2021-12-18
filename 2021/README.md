# Advent of Code 2021

These puzzles are solved using the Zig compiler v0.8.1. I chose to _not_ follow
master so these are reproducible with a released version rather than some
commit.

The solutions are cleaned up from my actual solution that was used to solve
within the time limit. Usually that only involves organization and naming, but
occasionally I will rewrite something to make it more clear. I do not change my
core algorithm though. If I later found a more interesting way to find the
solution that solution is included and noted as a later attempt.

## Solutions

* [Day 01](https://github.com/natecraddock/aoc/blob/master/2021/src/day01.zig)
* [Day 02](https://github.com/natecraddock/aoc/blob/master/2021/src/day02.zig)
* [Day 03](https://github.com/natecraddock/aoc/blob/master/2021/src/day03.zig)
* [Day 04](https://github.com/natecraddock/aoc/blob/master/2021/src/day04.zig)
* [Day 05](https://github.com/natecraddock/aoc/blob/master/2021/src/day05.zig)
* [Day 06](https://github.com/natecraddock/aoc/blob/master/2021/src/day06.zig)
* [Day 07](https://github.com/natecraddock/aoc/blob/master/2021/src/day07.zig)
* [Day 08](https://github.com/natecraddock/aoc/blob/master/2021/src/day08.zig)
* [Day 09](https://github.com/natecraddock/aoc/blob/master/2021/src/day09.zig)
* [Day 10](https://github.com/natecraddock/aoc/blob/master/2021/src/day10.zig)
* [Day 11](https://github.com/natecraddock/aoc/blob/master/2021/src/day11.zig)
* [Day 12](https://github.com/natecraddock/aoc/blob/master/2021/src/day12.zig)
* [Day 13](https://github.com/natecraddock/aoc/blob/master/2021/src/day13.zig)
* [Day 14](https://github.com/natecraddock/aoc/blob/master/2021/src/day14.zig)
* [Day 15](https://github.com/natecraddock/aoc/blob/master/2021/src/day14.zig)
* [Day 16](https://github.com/natecraddock/aoc/blob/master/2021/src/day16.zig)
* [Day 17](https://github.com/natecraddock/aoc/blob/master/2021/src/day17.zig)

See the
[`src/util.zig`](https://github.com/natecraddock/aoc/blob/master/2021/src/util.zig)
file for shared utility functions. I wrote these as I went along, so earlier
solutions do not make use of all of the functions.

## Why Zig

I learned of [Zig](https://ziglang.org) earlier this year, and the more I use it
the more I love it. It adds just enough power to C to be more expressive, but
keeps the language small enough to not become overwhelming like C++ or Rust.
Zig also features powerful compile-time metaprogramming capabilities. For an
example, see the `util.parseInto()` function in `util.zig`. I really hope to
see Zig become an influential programming language in the future.

Zig certainly isn't a super competitive language with no hidden control flow, no
hidden allocations, a static type system, manual memory management, and a more
verbose syntax than languages like Python, but I am interested to see how it
manages for the Advent of Code. So far it has been just fine.

Thanks to [SpexGuy](https://github.com/SpexGuy/Zig-AoC-Template) for the
starting template.
