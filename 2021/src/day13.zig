const std = @import("std");
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day13.txt");

const Coord = struct {
    x: u32,
    y: u32,
};

const Fold = struct {
    axis: []const u8,
    val: u32,
};

pub fn main() !void {
    var split = try util.toStrSlice(data, "\n\n");

    var coords = try util.toSliceOf(Coord, split[0], ",");
    defer gpa.free(coords);

    var folds = try util.toSliceOf(Fold, split[1], "=");
    defer gpa.free(folds);

    {
        var counts = util.Counter(Coord).init(gpa);
        defer counts.deinit();

        const fold = folds[0];
        const axis = fold.axis[fold.axis.len - 1];
        for (coords) |*coord| {
            if (axis == 'x') {
                if (coord.x > fold.val) {
                    coord.x -= (coord.x - fold.val) * 2;
                }
            } else {
                if (coord.y > fold.val) {
                    coord.y -= (coord.y - fold.val) * 2;
                }
            }
        }
        for (coords) |coord| {
            try counts.add(coord);
        }
        print("{}\n", .{counts.counter.count()});
    }

    for (folds[1..]) |fold| {
        const axis = fold.axis[fold.axis.len - 1];
        for (coords) |*coord| {
            if (axis == 'x') {
                if (coord.x > fold.val) {
                    coord.x -= (coord.x - fold.val) * 2;
                }
            } else {
                if (coord.y > fold.val) {
                    coord.y -= (coord.y - fold.val) * 2;
                }
            }
        }
    }

    var counts = util.Counter(Coord).init(gpa);
    defer counts.deinit();

    var max_x: u32 = 0;
    var max_y: usize = 0;
    for (coords) |coord| {
        try counts.add(coord);
        if (coord.x > max_x) max_x = coord.x;
        if (coord.y > max_y) max_y = coord.x;
    }

    var y: u32 = 0;
    while (y <= max_y) : (y += 1) {
        var x: u32 = 0;
        while (x <= max_x) : (x += 1) {
            var s = Coord{ .x = x, .y = y };
            if (counts.counter.get(s)) |_| {
                print("#", .{});
            } else print(".", .{});
        }
        print("\n", .{});
    }
}
