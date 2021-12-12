const std = @import("std");
const print = std.debug.print;
const Map = std.AutoHashMap(u8, u8);
const Set = std.StaticBitSet(7);

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day08.txt");

fn mask(pattern: []const u8) Set {
    var set = Set.initEmpty();
    for (pattern) |l| {
        set.set(l - 'a');
    }
    return set;
}

fn count(a: Set, b: Set, expected: u8) bool {
    var t = a;
    t.setIntersection(b);
    return t.count() == expected;
}

fn createMap(patterns: [][]const u8) !Map {
    var map = Map.init(gpa);

    var four: Set = undefined;
    var seven: Set = undefined;

    // find the easy ones 1, 4, 7, 8
    for (patterns) |pattern| {
        var m = mask(pattern);
        switch (pattern.len) {
            2 => try map.put(m.mask, 1),
            3 => {
                try map.put(m.mask, 7);
                seven = mask(pattern);
            },
            4 => {
                try map.put(m.mask, 4);
                four = mask(pattern);
            },
            7 => try map.put(m.mask, 8),
            else => {},
        }
    }

    // now we know the rest based on 4 and 7 and number of set bits
    for (patterns) |pattern| {
        var m = mask(pattern);
        if (m.count() == 6 and count(m, four, 3) and count(m, seven, 3)) try map.put(m.mask, 0);
        if (m.count() == 5 and count(m, four, 2) and count(m, seven, 2)) try map.put(m.mask, 2);
        if (m.count() == 5 and count(m, four, 3) and count(m, seven, 3)) try map.put(m.mask, 3);
        if (m.count() == 5 and count(m, four, 3) and count(m, seven, 2)) try map.put(m.mask, 5);
        if (m.count() == 6 and count(m, four, 3) and count(m, seven, 2)) try map.put(m.mask, 6);
        if (m.count() == 6 and count(m, four, 4) and count(m, seven, 3)) try map.put(m.mask, 9);
    }

    return map;
}

pub fn main() !void {
    var t = std.StaticBitSet(7).initEmpty();

    var counts = [_]u8{0} ** 10;

    var notes = try util.toStrSlice(data, "\n");
    for (notes) |note| {
        var split = try util.toStrSlice(note, "|");
        for (try util.toStrSlice(split[1], " ")) |out| {
            switch (out.len) {
                2 => counts[1] += 1,
                3 => counts[7] += 1,
                4 => counts[4] += 1,
                7 => counts[8] += 1,
                else => {},
            }
        }
    }

    var sum: usize = 0;
    for (counts) |c| {
        sum += c;
    }
    print("{}\n", .{sum});

    sum = 0;
    for (notes) |note| {
        var split = try util.toStrSlice(note, "|");

        var map = try createMap(try util.toStrSlice(split[0], " "));

        var out_val: usize = 0;
        for (try util.toStrSlice(split[1], " ")) |output, i| {
            var m = mask(output).mask;
            out_val = 10 * out_val + map.get(m).?;
        }

        sum += out_val;
    }

    print("{}\n", .{sum});
}
