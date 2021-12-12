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

pub fn streq(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub fn Counter(comptime T: type) type {
    return struct {
        counter: Map(T, usize),

        pub fn init(allocator: *Allocator) @This() {
            return .{ .counter = Map(T, usize).init(allocator) };
        }

        pub fn add(self: *@This(), val: T) !void {
            if (self.counter.get(val)) |count| {
                try self.counter.put(val, count + 1);
            } else try self.counter.put(val, 1);
        }
    };
}

pub fn toStrSlice(string: []const u8, delim: []const u8) ![][]const u8 {
    var list = List([]const u8).init(gpa);

    var it = std.mem.split(string, delim);
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try list.append(line);
    }

    return list.toOwnedSlice();
}

pub fn toIntSlice(comptime T: type, string: []const u8, delim: []const u8) ![]T {
    var list = List(T).init(gpa);

    var it = std.mem.split(string, delim);
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try list.append(try std.fmt.parseInt(T, std.mem.trim(u8, line, "\n"), 10));
    }

    return list.toOwnedSlice();
}

pub fn parseInto(comptime T: type, string: []const u8, delim: []const u8) !T {
    const info = @typeInfo(T).Struct;

    var split = std.mem.split(string, delim);
    var item: T = undefined;
    inline for (info.fields) |field| {
        var s = split.next() orelse break;
        switch (@typeInfo(field.field_type)) {
            .Int => {
                @field(item, field.name) = try std.fmt.parseInt(field.field_type, s, 10);
            },
            .Float => {
                @field(item, field.name) = try std.fmt.parseFloat(field.field_type, s, 10);
            },
            .Pointer => |p| {
                if (p.child != u8) @compileLog("unsupported type");
                @field(item, field.name) = s;
            },
            else => @compileError("unsupported type"),
        }
    }

    return item;
}

pub fn toSliceOf(comptime T: type, string: []const u8, delim: []const u8) ![]T {
    var list = List(T).init(gpa);
    // assume lines
    var it = std.mem.split(string, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;
        try list.append(try parseInto(T, line, delim));
    }

    return list.toOwnedSlice();
}
