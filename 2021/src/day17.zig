const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day17.txt");

const Target = struct {
    x_min: i32,
    x_max: i32,
    y_min: i32,
    y_max: i32,
};

fn parseTarget(d: []const u8) !Target {
    var it = std.mem.split(std.mem.trim(u8, d, "\n"), ": ");
    _ = it.next().?;

    it = std.mem.split(it.next().?, ", ");
    var x_it = std.mem.split(it.next().?[2..], "..");
    var y_it = std.mem.split(it.next().?[2..], "..");

    return Target{
        .x_min = try std.fmt.parseInt(i32, x_it.next().?, 10),
        .x_max = try std.fmt.parseInt(i32, x_it.next().?, 10),
        .y_min = try std.fmt.parseInt(i32, y_it.next().?, 10),
        .y_max = try std.fmt.parseInt(i32, y_it.next().?, 10),
    };
}

const Probe = struct {
    x: i32,
    y: i32,
    vel_x: i32,
    vel_y: i32,

    max: i32 = std.math.minInt(i32),
    x_at_max: i32 = 0,

    const Self = @This();

    fn new(x: i32, y: i32) Self {
        return .{ .x = 0, .y = 0, .vel_x = x, .vel_y = y };
    }

    fn sim(self: *Self, target: Target) ?i32 {
        if (self.y > self.max) {
            self.max = self.y;
            self.x_at_max = self.x;
        }

        while (true) {
            // move
            self.x += self.vel_x;
            self.y += self.vel_y;

            // set max
            if (self.y > self.max) {
                self.max = self.y;
                self.x_at_max = self.x;
            }

            // in target?
            if (self.x >= target.x_min and self.x <= target.x_max and
                self.y >= target.y_min and self.y <= target.y_max)
            {
                return self.max;
            }

            // not worth moving again?
            if (self.x >= target.x_max or self.y <= target.y_min) return null;

            // update vel
            if (self.vel_x != 0) self.vel_x += if (self.vel_x < 0) @as(i32, 1) else @as(i32, -1);
            self.vel_y -= 1;
        }
    }
};

pub fn main() !void {
    var target = try parseTarget(data);

    // brute force it
    var x: i32 = 1;
    var y: i32 = -100;
    var max_y: i32 = std.math.minInt(i32);

    var valid = List(Probe).init(gpa);

    while (true) {
        var probe = Probe.new(x, y);
        if (probe.sim(target)) |max| {
            if (max > max_y) max_y = max;

            try valid.append(probe);
        }

        x += 1;
        if (x > target.x_max) {
            x = 1;
            y += 1;
        }

        // print("{} ({}, {}), {}\n", .{ max_y, x, y, probe.x_at_max });
        if (probe.x_at_max > target.x_max and y > 1000) break;
    }

    print("{}\n", .{max_y});
    print("{}\n", .{valid.items.len});
}
