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

const data = @embedFile("../data/day03.txt");

fn calc(nums: []u1) usize {
    var total: usize = 0;
    for (nums) |n, i| {
        total += std.math.pow(usize, 2, nums.len - i - 1) * n;
    }
    return total;
}

fn num(str: []const u8) usize {
    var bits: [12]u1 = undefined;
    for (str) |s, i| {
        if (s == '0') bits[i] = 0;
        if (s == '1') bits[i] = 1;
    }
    return calc(&bits);
}

pub fn main() !void {
    var gamma: [12]u1 = undefined;
    var epsilon: [12]u1 = undefined;

    var items = try util.toStrSlice(data, "\n");
    var i: usize = 0;
    while (i < 12) : (i += 1) {
        var count: usize = 0;
        for (items) |item| {
            if (item[i] == '0') count += 1;
        }

        if (count > items.len / 2) {
            gamma[i] = 0;
            epsilon[i] = 1;
        } else {
            gamma[i] = 1;
            epsilon[i] = 0;
        }
    }

    var g: usize = calc(&gamma);
    var e: usize = calc(&epsilon);

    i = 0;
    var ignore1: [1000]bool = [_]bool{false} ** 1000;
    var left: usize = 1000;
    while (i < 12) : (i += 1) {
        var count: usize = 0;
        for (items) |item, j| {
            if (ignore1[j]) continue;
            print("{s}\n", .{item});
            if (item[i] == '0') count += 1;
        }
        var consider: u8 = undefined;
        print("{d} {d}\n", .{ left, count });
        if (left % 2 == 0 and count == left / 2) {
            consider = '0';
        } else if (count > left / 2) {
            consider = '1';
        } else {
            consider = '0';
        }
        for (items) |item, j| {
            if (ignore1[j]) continue;
            if (item[i] == consider) ignore1[j] = true;
        }

        left = 0;
        for (ignore1) |item, j| {
            if (!ignore1[j]) left += 1;
        }

        print("\n", .{});
        if (left == 1) break;
    }

    var idx: usize = 0;
    for (ignore1) |_, z| {
        if (!ignore1[z]) idx = z;
    }

    var ls = num(items[idx]);
    print("{d} {d}\n", .{ idx, ls });

    i = 0;
    var ignore2: [1000]bool = [_]bool{false} ** 1000;
    left = 1000;
    items = try util.toStrSlice(data, "\n");
    while (i < 12) : (i += 1) {
        var count: usize = 0;
        for (items) |item, j| {
            if (ignore2[j]) continue;
            if (item[i] == '0') count += 1;
        }
        var consider: u8 = undefined;
        if (left % 2 == 0 and count == left / 2) {
            consider = '1';
        } else if (count < left / 2) {
            consider = '1';
        } else {
            consider = '0';
        }
        for (items) |item, j| {
            if (ignore2[j]) continue;
            if (item[i] == consider) ignore2[j] = true;
        }

        left = 0;
        for (ignore2) |item, j| {
            if (!ignore2[j]) left += 1;
        }

        if (left == 1) break;
    }

    for (ignore2) |_, z| {
        if (!ignore2[z]) idx = z;
    }
    var oxy = num(items[idx]);

    // part 1
    print("{d}\n", .{g * e});
    // part 2
    print("{d}\n", .{ls * oxy});
}
