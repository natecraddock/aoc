const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day01.txt");

pub fn part1() !void {
    var num_larger: usize = 0;

    var it = std.mem.split(data, "\n");
    var last: usize = 0;
    last = try std.fmt.parseInt(u32, it.next().?, 10);
    while (it.next()) |line| {
        var num = std.fmt.parseInt(u32, line, 10) catch break;
        if (num > last) {
            num_larger += 1;
        }

        last = num;
    }

    print("{d}\n", .{num_larger});
}

pub fn part2() !void {
    var num_larger: usize = 0;
    var nums = List(usize).init(gpa);

    var it = std.mem.split(data, "\n");
    while (it.next()) |line| {
        var num = std.fmt.parseInt(u32, line, 10) catch break;
        try nums.append(num);
    }

    var last: usize = 0;
    for (nums.items[1 .. nums.items.len - 2]) |num, i| {
        var sum = nums.items[i + 1] + nums.items[i + 2] + nums.items[i + 3];
        if (sum > last) {
            num_larger += 1;
        }

        last = sum;
    }

    print("{d}\n", .{num_larger});
}

pub fn main() !void {
    try part1();
    try part2();
}
