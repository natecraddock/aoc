const std = @import("std");
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day11.txt");

const Octo = struct {
    energy: usize = 0,
    flashed: bool = false,
};

pub fn main() !void {
    // init octo field (grown by 1 to make edges easier to handle)
    var octos: [12][12]Octo = undefined;
    for (octos) |row, i| {
        for (row) |octo, j| {
            octos[i][j] = .{ .energy = 0, .flashed = false };
        }
    }

    // read in initial values
    var lines = try util.toStrSlice(data, "\n");
    defer gpa.free(lines);
    for (lines) |line, i| {
        for (line) |c, j| {
            octos[i + 1][j + 1].energy = c - '0';
        }
    }

    var num_flashes: usize = 0;
    var step_all_flashed: usize = 0;

    var step: usize = 0;
    var all_flashed = false;
    while (step < 100 or !all_flashed) : (step += 1) {
        // increase by one
        for (octos[1..11]) |row, i| {
            for (row[1..11]) |octo, j| {
                octos[i + 1][j + 1].energy += 1;
            }
        }

        // flash!
        var flashed = true;
        while (flashed) {
            flashed = false;
            for (octos[1..11]) |row, i| {
                for (row[1..11]) |octo, j| {
                    if (octo.energy > 9 and !octo.flashed) {
                        if (step < 100) num_flashes += 1;
                        flashed = true;

                        // flash!
                        octos[i + 1][j + 1].flashed = true;

                        var r = i + 1;
                        var c = j + 1;

                        octos[r - 1][c - 1].energy += 1;
                        octos[r - 1][c].energy += 1;
                        octos[r - 1][c + 1].energy += 1;
                        octos[r][c + 1].energy += 1;
                        octos[r + 1][c + 1].energy += 1;
                        octos[r + 1][c].energy += 1;
                        octos[r + 1][c - 1].energy += 1;
                        octos[r][c - 1].energy += 1;
                    }
                }
            }
        }

        all_flashed = true;
        for (octos[1..11]) |row, i| {
            for (row[1..11]) |octo, j| {
                if (octos[i + 1][j + 1].flashed) {
                    octos[i + 1][j + 1].energy = 0;
                    octos[i + 1][j + 1].flashed = false;
                } else all_flashed = false;
            }
        }

        if (all_flashed) step_all_flashed = step + 1;
    }

    print("{}\n", .{num_flashes});
    print("{}\n", .{step_all_flashed});
}
