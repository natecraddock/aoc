const std = @import("std");
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day06.txt");

pub fn main() !void {
    var fishes = try util.toIntSlice(u8, data, ",");
    var counts = [_]usize{0} ** 9;
    var countsTemp = [_]usize{0} ** 9;

    for (fishes) |fish| {
        counts[fish] += 1;
    }

    var day: usize = 1;
    while (day <= 256) : (day += 1) {
        var temp: usize = 0;
        for (counts) |count, group| {
            if (group == 0) {
                countsTemp[8] = counts[0];
                temp = counts[0];
                countsTemp[0] = 0;
            } else {
                countsTemp[group - 1] = counts[group];
            }
        }
        countsTemp[6] += temp;

        for (countsTemp) |count, group| {
            counts[group] = countsTemp[group];
        }

        if (day == 80) print("{}\n", .{sum(&counts)});
        if (day == 256) print("{}\n", .{sum(&counts)});
    }
}

fn sum(counts: []usize) usize {
    var s: usize = 0;
    for (counts) |count| {
        s += count;
    }
    return s;
}
