const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day10.txt");

fn find(char: u8) ?u8 {
    const openings = [_]u8{ '(', '[', '{', '<' };
    const closings = [_]u8{ ')', ']', '}', '>' };
    for (openings) |opener, i| {
        if (char == opener) return closings[i];
    }
    return null;
}

const asc = std.sort.asc(usize);

pub fn main() !void {
    var stack = List(u8).init(gpa);
    defer stack.deinit();
    var lines = try util.toStrSlice(data, "\n");
    defer gpa.free(lines);

    var score: usize = 0;
    var scores_incomplete = List(usize).init(gpa);

    for (lines) |line| {
        var is_incomplete = true;

        for (line) |char| {
            if (find(char)) |closing| {
                // an opening
                try stack.append(closing);
            } else {
                // a closing
                var expect = stack.pop();
                if (expect != char) {
                    score += switch (char) {
                        ')' => 3,
                        ']' => 57,
                        '}' => 1197,
                        '>' => 25137,
                        else => @as(usize, 0),
                    };
                    is_incomplete = false;
                    break;
                }
            }
        }

        // incomplete
        if (is_incomplete) {
            var incomplete: usize = 0;
            while (stack.items.len > 0) {
                incomplete *= 5;
                var char = stack.pop();
                incomplete += switch (char) {
                    ')' => 1,
                    ']' => 2,
                    '}' => 3,
                    '>' => 4,
                    else => @as(usize, 0),
                };
            }
            try scores_incomplete.append(incomplete);
        }

        stack.clearAndFree();
    }

    std.sort.sort(usize, scores_incomplete.items, {}, asc);

    print("{}\n", .{score});
    print("{}\n", .{scores_incomplete.items[scores_incomplete.items.len / 2]});
}
