const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day09.txt");
const desc = std.sort.desc(usize);

pub fn main() !void {
    var lines = try util.toStrSlice(data, "\n");

    const rows = lines.len;
    const cols = lines[0].len;

    var basins = List(usize).init(gpa);
    var visited = try List(bool).initCapacity(gpa, rows * cols);
    try visited.appendNTimes(false, rows * cols);

    var sum: usize = 0;
    for (lines) |line, row| {
        for (line) |point, col| {
            var low = false;
            var val = point - '0';
            if (row == 0) {
                // corners
                if (col == 0) {
                    if (val < lines[row][col + 1] - '0' and val < lines[row + 1][col] - '0') {
                        sum += val + 1;
                        low = true;
                    }
                } else if (col == cols - 1) {
                    if (val < lines[row][col - 1] - '0' and val < lines[row + 1][col] - '0') {
                        sum += val + 1;
                        low = true;
                    }
                } else {
                    if (val < lines[row][col + 1] - '0' and val < lines[row][col - 1] - '0' and val < lines[row + 1][col] - '0') {
                        sum += val + 1;
                        low = true;
                    }
                }
            } else if (row == rows - 1) {
                // corners
                if (col == 0) {
                    if (val < lines[row][col + 1] - '0' and val < lines[row - 1][col] - '0') {
                        sum += val + 1;
                        low = true;
                    }
                } else if (col == cols - 1) {
                    if (val < lines[row][col - 1] - '0' and val < lines[row - 1][col] - '0') {
                        sum += val + 1;
                        low = true;
                    }
                } else {
                    if (val < lines[row][col + 1] - '0' and val < lines[row][col - 1] - '0' and val < lines[row - 1][col] - '0') {
                        sum += val + 1;
                        low = true;
                    }
                }
            } else if (col == 0) {
                if (val < lines[row][col + 1] - '0' and val < lines[row - 1][col] - '0' and val < lines[row + 1][col] - '0') {
                    sum += val + 1;
                    low = true;
                }
            } else if (col == cols - 1) {
                if (val < lines[row][col - 1] - '0' and val < lines[row - 1][col] - '0' and val < lines[row + 1][col] - '0') {
                    sum += val + 1;
                    low = true;
                }
            } else {
                // inner
                if (val < lines[row - 1][col] - '0' and val < lines[row + 1][col] - '0' and val < lines[row][col - 1] - '0' and val < lines[row][col + 1] - '0') {
                    sum += val + 1;
                    low = true;
                }
            }

            if (low) {
                try basins.append(getBasinSize(lines, visited.items, row, col));
            }
        }
    }

    std.sort.sort(usize, basins.items, {}, desc);

    print("{}\n", .{sum});
    print("{}\n", .{basins.items[0] * basins.items[1] * basins.items[2]});
}

fn getBasinSize(lines: [][]const u8, visited: []bool, row: usize, col: usize) usize {
    const rows = lines.len;
    const cols = lines[0].len;

    if (visited[row * cols + col]) return 0;
    if (lines[row][col] == '9') return 0;
    visited[row * cols + col] = true;

    var size: usize = 0;
    if (row > 0) size += getBasinSize(lines, visited, row - 1, col);
    if (col > 0) size += getBasinSize(lines, visited, row, col - 1);
    if (row < rows - 1) size += getBasinSize(lines, visited, row + 1, col);
    if (col < cols - 1) size += getBasinSize(lines, visited, row, col + 1);

    return size + 1;
}
