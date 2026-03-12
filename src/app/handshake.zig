const std = @import("std");
const constants = @import("../utils/constants.zig");

pub fn generateUniqueId() ![constants.UNIQUE_ID_LEN]u8 {
    var id: [constants.UNIQUE_ID_LEN]u8 = undefined;
    std.crypto.random.bytes(&id);
    return id;
}

pub fn printUniqueId(id: *const [constants.UNIQUE_ID_LEN]u8) void {
    std.debug.print("Unique ID: ", .{});
    for (id) |byte| {
        std.debug.print("{x:0>2}", .{byte});
    }
    std.debug.print("\n", .{});
}

pub fn readUniqueIdFromInput(allocator: std.mem.Allocator) ![constants.UNIQUE_ID_LEN]u8 {
    const stdin = std.io.getStdIn().reader();
    var buffer: [128]u8 = undefined;

    std.debug.print("Enter Unique ID (32 hex characters): ", .{});

    if (stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (line.len != constants.UNIQUE_ID_LEN * 2) {
            return error.InvalidIdLength;
        }

        var id: [constants.UNIQUE_ID_LEN]u8 = undefined;

        var i: usize = 0;
        while (i < constants.UNIQUE_ID_LEN) : (i += 1) {
            const hex_str = line[i * 2 .. i * 2 + 2];
            id[i] = std.fmt.parseInt(u8, hex_str, 16) catch return error.InvalidHexFormat;
        }

        return id;
    } else |_| {
        return error.InputError;
    }
}

pub fn verifyUniqueId(received: *const [constants.UNIQUE_ID_LEN]u8, expected: *const [constants.UNIQUE_ID_LEN]u8) bool {
    for (received, expected) |r, e| {
        if (r != e) return false;
    }
    return true;
}
