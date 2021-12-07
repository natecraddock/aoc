const std = @import("std");
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day07.txt");

pub fn main() !void {
    var pos = try util.toIntSlice(i64, data, ",");

    var min = std.mem.min(i64, pos);
    var max = std.mem.max(i64, pos);

    // I like how you can get the max size of any arbitrary int with a comptime call
    var costOne: i64 = std.math.maxInt(i64);
    var costTwo: i64 = std.math.maxInt(i64);

    var c: i64 = undefined;
    while (min <= max) : (min += 1) {
        c = try alignTo(min, pos, false);
        if (c < costOne) costOne = c;

        c = try alignTo(min, pos, true);
        if (c < costTwo) costTwo = c;
    }

    print("{}\n", .{costOne});
    print("{}\n", .{costTwo});
}

fn alignTo(val: i64, pos: []i64, comptime increasing: bool) !i64 {
    var sum: i64 = 0;
    for (pos) |p| {
        if (increasing) {
            // trying to be clever here with the (n * n * 0.5) + (n + 0.5) formula
            // actually slowed me down because I had no idea how to cast floats in Zig!
            var steps = @intToFloat(f32, try std.math.absInt(val - p));
            sum += @floatToInt(i64, (steps * steps * 0.5) + (steps * 0.5));
        } else {
            sum += try std.math.absInt(val - p);
        }
    }
    return sum;
}
