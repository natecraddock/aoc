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

const data = @embedFile("../data/day04.txt");

pub fn main() !void {
    var lines = try util.toStrSlice(data, "\n");
    var numbers = try util.toIntSlice(u8, lines[0], ",");

    var boards = List(?[5][5]?u8).init(gpa);
    defer boards.deinit();

    var board: [5][5]?u8 = undefined;
    for (lines[1..]) |line, i| {
        var row = try util.toStrSlice(line, " ");
        var j: usize = 0;
        for (row) |num| {
            if (num.len == 0) continue;
            board[i % 5][j] = try std.fmt.parseInt(u8, num, 10);
            j += 1;
        }

        if (i % 5 == 4) {
            try boards.append(board);
        }
    }

    var num_winners: usize = 0;
    for (numbers) |num| {
        for (boards.items) |*b, i| {
            if (b.* == null) continue;
            markBoard(&b.*.?, num);
        }

        for (boards.items) |*b, i| {
            if (b.* == null) continue;
            if (checkBoard(b.*.?)) {
                num_winners += 1;
                if (num_winners == 1) print("{d}\n", .{sumBoard(b.*.?) * num});
                if (num_winners == boards.items.len) print("{d}\n", .{sumBoard(b.*.?) * num});
                b.* = null;
            }
        }
    }
}

fn markBoard(board: *[5][5]?u8, num: u8) void {
    for (board) |*row| {
        for (row) |*n| {
            if (n.* == num) n.* = null;
        }
    }
}

fn checkBoard(board: [5][5]?u8) bool {
    // check rows
    for (board) |row| {
        var all = true;
        for (row) |n| {
            if (n != null) all = false;
        }
        if (all) return true;
    }

    // check cols
    var i: usize = 0;
    while (i < board.len) : (i += 1) {
        var j: usize = 0;
        var all = true;
        while (j < board[i].len) : (j += 1) {
            if (board[j][i] != null) all = false;
        }
        if (all) return true;
    }

    return false;
}

fn sumBoard(board: [5][5]?u8) u32 {
    var sum: u32 = 0;
    for (board) |row| {
        for (row) |n| {
            if (n) |num| sum += num;
        }
    }
    return sum;
}
