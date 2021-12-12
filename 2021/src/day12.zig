const std = @import("std");
const print = std.debug.print;
const List = std.ArrayList;
const StrMap = std.StringHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day12.txt");

const Edge = struct {
    a: []const u8,
    b: []const u8,
};

const Node = struct {
    is_start: bool = false,
    small: bool = true,
    visited: u8 = 0,
    neighbors: List(*Node),
};

pub fn main() !void {
    var num_paths: usize = 0;

    var nodes = StrMap(Node).init(gpa);
    defer nodes.deinit();

    // list nodes
    var edges = try util.toSliceOf(Edge, data, "-");
    defer gpa.free(edges);

    for (edges) |edge| {
        var gop = try nodes.getOrPut(edge.a);
        if (!gop.found_existing) {
            gop.value_ptr.*.small = std.ascii.isLower(edge.a[0]);
            gop.value_ptr.*.visited = 0;
            gop.value_ptr.*.neighbors = List(*Node).init(gpa);
        }
        gop = try nodes.getOrPut(edge.b);
        if (!gop.found_existing) {
            gop.value_ptr.*.small = std.ascii.isLower(edge.b[0]);
            gop.value_ptr.*.visited = 0;
            gop.value_ptr.*.neighbors = List(*Node).init(gpa);
        }
    }

    // connect nodes
    var start: *Node = undefined;
    var end: *Node = undefined;
    for (edges) |edge| {
        var a = nodes.getPtr(edge.a).?;
        try a.*.neighbors.append(nodes.getPtr(edge.b).?);
        var b = nodes.getPtr(edge.b).?;
        try b.*.neighbors.append(nodes.getPtr(edge.a).?);

        if (util.streq(edge.a, "start")) start = nodes.getPtr(edge.a).?;
        if (util.streq(edge.b, "start")) start = nodes.getPtr(edge.b).?;
        if (util.streq(edge.a, "end")) end = nodes.getPtr(edge.a).?;
        if (util.streq(edge.b, "end")) end = nodes.getPtr(edge.b).?;
    }
    start.is_start = true;

    // find routes
    visit1(start, end, &num_paths);
    print("{}\n", .{num_paths});

    num_paths = 0;
    var any_twice = false;
    visit2(start, end, &num_paths, &any_twice);
    print("{}\n", .{num_paths});

    // free neighbors
    var it = nodes.iterator();
    while (it.next()) |node| {
        node.value_ptr.*.neighbors.deinit();
    }
}

fn visit1(node: *Node, end: *Node, num_paths: *usize) void {
    if (node.small and node.visited > 0) return;

    if (node == end) {
        num_paths.* += 1;
        return;
    }

    if (node.small) node.visited += 1;

    for (node.neighbors.items) |n| {
        visit1(n, end, num_paths);
    }

    if (node.small) node.visited -= 1;
}

fn visit2(node: *Node, end: *Node, num_paths: *usize, any_twice: *bool) void {
    if (node.small and node.visited > 2) return;
    if (node.small and any_twice.* and node.visited > 0) return;
    if (node.is_start and node.visited > 0) return;

    if (node == end) {
        num_paths.* += 1;
        return;
    }

    if (node.small) node.visited += 1;
    if (node.visited == 2) any_twice.* = true;

    for (node.neighbors.items) |n| {
        visit2(n, end, num_paths, any_twice);
    }

    if (node.visited == 2) any_twice.* = false;
    if (node.small) node.visited -= 1;
}
