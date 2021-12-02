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

const data = @embedFile("../data/day02.txt");

pub fn main() !void {
    var h: i32 = 0;
    var v: i32 = 0;
    var a: i32 = 0;

    var lines = try util.toStrSlice(data, "\n");
    for (lines) |line| {
        var it = std.mem.split(line, " ");
        var dir = it.next().?;
        var val = try std.fmt.parseInt(i32, it.next().?, 10);

        if (std.mem.eql(u8, dir, "forward")) {
            h += val;
            v += a * val;
        } else if (std.mem.eql(u8, dir, "down")) {
            a += val;
        } else if (std.mem.eql(u8, dir, "up")) {
            a -= val;
        }
    }

    print("{d}\n", .{h * v});
}
