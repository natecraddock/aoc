const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day15.txt");

const asc = std.sort.asc(usize);

const Pos = struct {
    x: usize,
    y: usize,
    density: u8,
    risk: ?u32 = null,
    prev: ?*Pos = null,
};

pub fn main() !void {
    var map = blk: {
        var map_array = List([]Pos).init(gpa);
        var lines = try util.toStrSlice(data, "\n");

        for (lines) |line, j| {
            var row = List(Pos).init(gpa);
            for (line) |c, i| {
                try row.append(.{ .x = i, .y = j, .density = c - '0' });
            }
            try map_array.append(row.toOwnedSlice());
        }

        break :blk map_array.toOwnedSlice();
    };
    defer {
        for (map) |line| {
            gpa.free(line);
        }
        gpa.free(map);
    }

    const size = map.len;

    {
        // risk of start is 0
        map[0][0].risk = 0;

        var queue = std.PriorityDequeue(*Pos).init(gpa, sort);
        defer queue.deinit();
        for (map) |line| {
            for (line) |*pos| {
                try queue.add(pos);
            }
        }

        while (queue.items.len > 0) {
            var min = queue.removeMin();

            // set v's distance for each (min, v) in the graph
            // this is simplified due to this being a grid

            // left
            if (min.x > 0) {
                var v = &map[min.y][min.x - 1];
                // TODO: this is a case where v can be inferred to be not-null correct?
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
            // up
            if (min.y > 0) {
                var v = &map[min.y - 1][min.x];
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
            // right
            if (min.x < size - 1) {
                var v = &map[min.y][min.x + 1];
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
            // down
            if (min.y < size - 1) {
                var v = &map[min.y + 1][min.x];
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
        }

        print("{}\n", .{map[size - 1][size - 1].risk.?});
    }

    // alloc full map
    var full_map = try gpa.alloc([]Pos, size * 5);
    for (full_map) |*row, j| {
        row.* = try gpa.alloc(Pos, size * 5);
    }
    for (map) |row, j| {
        for (row) |pos, i| {
            var y: usize = 0;
            while (y < 5) : (y += 1) {
                var x: usize = 0;
                while (x < 5) : (x += 1) {
                    var density = map[j][i].density + x + y;
                    while (density > 9) {
                        density -= 9;
                    }
                    var p: Pos = .{ .x = i + size * x, .y = j + size * y, .density = @intCast(u8, density) };
                    full_map[j + size * y][i + size * x] = p;
                }
            }
        }
    }

    {
        const full_size = size * 5;

        // risk of start is 0
        full_map[0][0].risk = 0;

        var queue = std.PriorityDequeue(*Pos).init(gpa, sort);
        defer queue.deinit();
        for (full_map) |line| {
            for (line) |*pos| {
                try queue.add(pos);
            }
        }

        var num: usize = 1;
        while (queue.items.len > 0) : (num += 1) {
            if (num % 1000 == 0) print("visiting node={}\n", .{num});
            // var min = popSmallest(&queue);
            var min = queue.removeMin();

            // set v's distance for each (min, v) in the graph
            // this is simplified due to this being a grid

            // left
            if (min.x > 0) {
                var v = &full_map[min.y][min.x - 1];
                // TODO: this is a case where v can be inferred to be not-null correct?
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
            // up
            if (min.y > 0) {
                var v = &full_map[min.y - 1][min.x];
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
            // right
            if (min.x < full_size - 1) {
                var v = &full_map[min.y][min.x + 1];
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
            // down
            if (min.y < full_size - 1) {
                var v = &full_map[min.y + 1][min.x];
                if (v.risk == null or v.risk.? > min.risk.? + v.density) {
                    v.risk = min.risk.? + v.density;
                    v.prev = min;
                    queue.update(v, v) catch {};
                }
            }
        }

        print("{}\n", .{full_map[full_size - 1][full_size - 1].risk.?});
    }
}

const Order = std.math.Order;
fn sort(a: *Pos, b: *Pos) Order {
    if (a.risk == null and b.risk == null) return Order.eq;
    if (a.risk != null and b.risk == null) return Order.lt;
    if (a.risk == null and b.risk != null) return Order.gt;
    if (a.risk.? == b.risk.?) return Order.eq;
    return if (a.risk.? < b.risk.?) Order.lt else Order.gt;
}

// This code was the result of assuming the submarine can only travel down and right.
// But all 4 directions are possible. I'm still super happy with this code so I'll
// leave it below :)

// const Pos = struct {
//     density: u8,
//     risk: u32 = 0,
//     prev: struct {
//         y: usize,
//         x: usize,
//     } = .{ .x = 0, .y = 0 },
// };

// pub fn main() !void {
//     var map = blk: {
//         var map_array = List([]Pos).init(gpa);
//         var lines = try util.toStrSlice(data, "\n");

//         for (lines) |line| {
//             var row = List(Pos).init(gpa);
//             for (line) |c| {
//                 try row.append(.{ .density = c - '0', .risk = 0 });
//             }
//             try map_array.append(row.toOwnedSlice());
//         }

//         break :blk map_array.toOwnedSlice();
//     };
//     defer {
//         for (map) |line| {
//             gpa.free(line);
//         }
//         gpa.free(map);
//     }

//     // top
//     for (map[0][1..]) |*pos, i| {
//         pos.risk = map[0][i].risk + pos.density;
//         pos.prev.y = 0;
//         pos.prev.x = i;
//     }

//     // left column
//     for (map[1..]) |row, i| {
//         row[0].risk = map[i][0].risk + row[0].density;
//         pos.prev.y = i;
//         pos.prev.x = 0;
//     }

//     for (map) |row, j| {
//         if (j == 0) continue;
//         for (row) |*pos, i| {
//             if (i == 0) continue;

//             // edit distance?
//             var left = map[j][i - 1].risk + pos.density;
//             var up = map[j - 1][i].risk + pos.density;
//             if (left < up) {
//                 pos.risk = left;
//                 pos.prev.y = j;
//                 pos.prev.x = i - 1;
//             } else {
//                 pos.risk = up;
//                 pos.prev.y = j - 1;
//                 pos.prev.x = i;
//             }
//         }
//     }

//     print("{}\n", .{map[map.len - 1][map.len - 1].risk});
// }
