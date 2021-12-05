const std = @import("std");
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day02.txt");

pub fn main() !void {
    var h: i32 = 0;
    var v: i32 = 0;
    var v2: i32 = 0;
    var a: i32 = 0;

    var lines = try util.toStrSlice(data, "\n");
    for (lines) |line| {
        var it = std.mem.split(line, " ");
        var dir = it.next().?;
        var val = try std.fmt.parseInt(i32, it.next().?, 10);

        if (std.mem.eql(u8, dir, "forward")) {
            h += val;
            v2 += a * val;
        } else if (std.mem.eql(u8, dir, "down")) {
            v += val;
            a += val;
        } else if (std.mem.eql(u8, dir, "up")) {
            v -= val;
            a -= val;
        }
    }

    print("{d}\n", .{h * v});
    print("{d}\n", .{h * v2});
}
