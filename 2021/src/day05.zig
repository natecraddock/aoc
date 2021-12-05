const std = @import("std");
const print = std.debug.print;
const Map = std.AutoHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day05.txt");

const Point = struct {
    x: i32,
    y: i32,

    pub fn fromStr(str: []const u8) !Point {
        var parsed = try util.toIntSlice(i32, str, ",");
        return Point{ .x = parsed[0], .y = parsed[1] };
    }
};

fn update(map: *Map(Point, usize), p: Point) !void {
    if (map.get(p)) |count| {
        try map.put(p, count + 1);
    } else {
        try map.put(p, 1);
    }
}

fn interpolate(map: *Map(Point, usize), a: []const u8, b: []const u8, diag: bool) !void {
    // this util function would be better now that it exists
    // var first = try util.parseInto(Point, a, ",");
    // var second = try util.parseInto(Point, b, ",");
    var first = try Point.fromStr(a);
    var second = try Point.fromStr(b);

    if (first.x == second.x) {
        var y = first.y;
        var dir: i32 = if (first.y < second.y) 1 else -1;
        while (y != second.y) : (y += dir) {
            try update(map, Point{ .x = first.x, .y = y });
        }
        try update(map, second);
    } else if (first.y == second.y) {
        var x = first.x;
        var dir: i32 = if (first.x < second.x) 1 else -1;
        while (x != second.x) : (x += dir) {
            try update(map, Point{ .x = x, .y = first.y });
        }
        try update(map, second);
    } else if (diag) {
        var x = first.x;
        var y = first.y;
        var dirx: i32 = if (first.x < second.x) 1 else -1;
        var diry: i32 = if (first.y < second.y) 1 else -1;
        while (x != second.x and y != second.y) {
            try update(map, Point{ .x = x, .y = y });
            x += dirx;
            y += diry;
        }
        try update(map, second);
    }
}

pub fn main() !void {
    var lines = try util.toStrSlice(data, "\n");

    {
        // no diagonals
        var counts = Map(Point, usize).init(gpa);
        for (lines) |line| {
            var d = try util.toStrSlice(line, " -> ");
            try interpolate(&counts, d[0], d[1], false);
        }

        var it = counts.iterator();
        var total: usize = 0;
        while (it.next()) |num| {
            if (num.value_ptr.* > 1) total += 1;
        }

        print("{}\n", .{total});
    }

    {
        // now consider diagonals
        var counts = Map(Point, usize).init(gpa);
        for (lines) |line| {
            var d = try util.toStrSlice(line, " -> ");
            try interpolate(&counts, d[0], d[1], true);
        }

        var it = counts.iterator();
        var total: usize = 0;
        while (it.next()) |num| {
            if (num.value_ptr.* > 1) total += 1;
        }

        print("{}\n", .{total});
    }
}
