const std = @import("std");
const print = std.debug.print;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day16.txt");

const BitReader = struct {
    bytes: []u8,
    byte: u8,
    byte_index: usize = 0,
    index: usize = 0,

    eos: bool = false,

    const Self = @This();

    const ReadError = error{
        EndOfSequence,
    };

    fn init(bytes: []u8) Self {
        return .{ .bytes = bytes, .byte = @bitReverse(u8, bytes[0]) };
    }

    fn next_bit(self: *Self) Self.ReadError!u1 {
        if (self.eos) return Self.ReadError.EndOfSequence;

        var bit: u1 = @intCast(u1, self.byte & 0b0000_0001);
        self.byte >>= 1;

        if (self.index % 8 == 7) {
            self.byte_index += 1;
            if (self.byte_index == self.bytes.len) {
                self.eos = true;
                return bit;
            }
            self.byte = @bitReverse(u8, self.bytes[self.byte_index]);
        }
        self.index += 1;

        return bit;
    }

    fn read(self: *Self, comptime Int: type) Self.ReadError!Int {
        const int_info = @typeInfo(Int).Int;
        if (int_info.signedness == .signed) @compileError("Only accepts unsigned integers");

        if (int_info.bits == 1) return try self.next_bit();

        var value: Int = 0;
        var i: usize = 0;
        while (i < int_info.bits) : (i += 1) {
            value = value * 2 + try self.next_bit();
        }

        return value;
    }
};

pub fn main() !void {
    var buf: [data.len / 2]u8 = undefined;
    var bytes = try std.fmt.hexToBytes(&buf, std.mem.trim(u8, data, "\n"));

    var reader = BitReader.init(bytes);

    var pkt = try parsePacket(&reader);
    print("{}\n", .{pkt.version});
    print("{}\n", .{pkt.val});
}

const Packet = struct {
    version: usize = 0,
    id: u8 = 0,
    op: u8 = 0,
    val: usize = 0,
};

fn parsePacket(reader: *BitReader) BitReader.ReadError!Packet {
    var pkt: Packet = .{};

    pkt.version = try reader.read(u3);
    pkt.id = try reader.read(u3);
    switch (pkt.id) {
        0b100 => {
            var more = true;
            while (more) {
                more = (try reader.read(u1)) == 1;
                pkt.val = (pkt.val * (1 << 4)) + try reader.read(u4);
            }
        },
        else => {
            var len_id = try reader.read(u1);
            var num = switch (len_id) {
                0 => try reader.read(u15),
                1 => try reader.read(u11),
            };

            if (pkt.id == 1) pkt.val = 1;
            if (pkt.id == 2) pkt.val = std.math.maxInt(usize);
            if (pkt.id == 3) pkt.val = std.math.minInt(usize);

            switch (len_id) {
                0 => {
                    var end = reader.index + num;
                    while (reader.index < end) {
                        var p = try parsePacket(reader);
                        switch (pkt.id) {
                            0 => pkt.val += p.val,
                            1 => pkt.val *= p.val,
                            2 => if (p.val < pkt.val) {
                                pkt.val = p.val;
                            },
                            3 => if (p.val > pkt.val) {
                                pkt.val = p.val;
                            },
                            5 => {
                                var p2 = try parsePacket(reader);
                                pkt.version += p2.version;
                                if (p.val > p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                            },
                            6 => {
                                var p2 = try parsePacket(reader);
                                pkt.version += p2.version;
                                if (p.val < p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                            },
                            7 => {
                                var p2 = try parsePacket(reader);
                                pkt.version += p2.version;
                                if (p.val == p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                            },
                            else => unreachable,
                        }
                        pkt.version += p.version;
                    }
                },
                1 => {
                    var i: usize = 0;
                    while (i < num) : (i += 1) {
                        var p = try parsePacket(reader);
                        switch (pkt.id) {
                            0 => pkt.val += p.val,
                            1 => pkt.val *= p.val,
                            2 => if (p.val < pkt.val) {
                                pkt.val = p.val;
                            },
                            3 => if (p.val > pkt.val) {
                                pkt.val = p.val;
                            },
                            5 => {
                                var p2 = try parsePacket(reader);
                                pkt.version += p2.version;
                                if (p.val > p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                                i += 1;
                            },
                            6 => {
                                var p2 = try parsePacket(reader);
                                pkt.version += p2.version;
                                if (p.val < p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                                i += 1;
                            },
                            7 => {
                                var p2 = try parsePacket(reader);
                                pkt.version += p2.version;
                                if (p.val == p2.val) {
                                    pkt.val = 1;
                                } else pkt.val = 0;
                                i += 1;
                            },
                            else => unreachable,
                        }
                        pkt.version += p.version;
                    }
                },
            }
        },
    }

    return pkt;
}
