const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = &gpa_impl.allocator;

pub fn toStrSlice(string: []const u8, delim: []const u8) ![][]const u8 {
    var list = List([]const u8).init(gpa);

    var it = std.mem.split(string, delim);
    var index: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }

    return list.toOwnedSlice();
}

pub fn toIntSlice(comptime T: type, string: []const u8, delim: []const u8) ![]T {
    var list = List(T).init(gpa);

    var it = std.mem.split(string, delim);
    var index: usize = 0;
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try list.append(try std.fmt.parseInt(T, line, 10));
    }

    return list.toOwnedSlice();
}
