const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day14.txt");

const Rule = struct {
    pair: []const u8,
    insert: u8,
};

const Pair = struct {
    a: u8,
    b: u8,

    pub fn new(a: u8, b: u8) @This() {
        return .{
            .a = a,
            .b = b,
        };
    }
};

pub fn main() !void {
    var lines = try util.toStrSlice(data, "\n");
    const template = lines[0];

    var polymer = List(u8).init(gpa);
    defer polymer.deinit();

    for (template) |c| {
        try polymer.append(c);
    }

    var rules = List(Rule).init(gpa);
    defer rules.deinit();
    for (lines[1..]) |line| {
        var rule = try util.parseInto(Rule, line, " -> ");
        try rules.append(rule);
    }

    {
        var step: usize = 0;
        while (step < 10) : (step += 1) {
            var build = List(u8).init(gpa);
            defer build.deinit();

            var it: usize = 0;
            while (it < polymer.items.len - 1) : (it += 1) {
                try build.append(polymer.items[it]);
                for (rules.items) |rule| {
                    if (util.streq(rule.pair, polymer.items[it .. it + 2])) {
                        try build.append(rule.insert);
                    }
                }
            }
            try build.append(polymer.items[polymer.items.len - 1]);
            polymer.clearAndFree();
            for (build.items) |c| {
                try polymer.append(c);
            }
        }

        var counts = [_]?usize{null} ** 26;
        var min: usize = std.math.maxInt(usize);
        var max: usize = 0;
        for (polymer.items) |c| {
            if (counts[c - 'A']) |*count| {
                count.* += 1;
            } else counts[c - 'A'] = 1;
        }
        for (counts) |c| {
            if (c) |*count| {
                if (count.* < min) min = count.*;
                if (count.* > max) max = count.*;
            }
        }

        print("{}\n", .{max - min});
    }

    {
        var pairs = util.Counter(Pair).init(gpa);
        defer pairs.deinit();

        for (template[0 .. template.len - 1]) |_, i| {
            try pairs.add(Pair.new(template[i], template[i + 1]));
        }

        var step: usize = 0;
        var chars = util.Counter(u8).init(gpa);
        defer chars.deinit();

        while (step < 40) : (step += 1) {
            chars.counter.clearAndFree();
            var new_pairs = util.Counter(Pair).init(gpa);

            var it = pairs.counter.iterator();
            var i: usize = 0;

            while (it.next()) |item| : (i += 1) {
                for (rules.items) |rule| {
                    if (rule.pair[0] == item.key_ptr.*.a and rule.pair[1] == item.key_ptr.*.b) {
                        try chars.addCount(rule.pair[0], item.value_ptr.*);
                        try chars.addCount(rule.insert, item.value_ptr.*);

                        var p = Pair.new(rule.pair[0], rule.insert);
                        try new_pairs.addCount(p, item.value_ptr.*);
                        p = Pair.new(rule.insert, rule.pair[1]);
                        try new_pairs.addCount(p, item.value_ptr.*);
                    }
                }

                if (i == pairs.counter.count() - 1) {
                    try chars.add(item.key_ptr.*.b);
                }
            }
            pairs = new_pairs;
        }

        var min: usize = std.math.maxInt(usize);
        var max: usize = 0;

        var it = chars.counter.iterator();
        while (it.next()) |val| {
            if (val.value_ptr.* > max) max = val.value_ptr.*;
            if (val.value_ptr.* < min) min = val.value_ptr.*;
        }

        // TODO: off by one here...
        print("{}\n", .{max - min + 1});
    }
}
