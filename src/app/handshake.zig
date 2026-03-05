const std = @import("std");
const constants = @import("../utils/constants.zig");

// This file is responsible for the handshake process between the client and server.
// IT INCLUDES FUNCTIONS FOR GENERATING CRYTOGRAPHIC KEYS, EXCHANGING UNIQUE IDS, AND ESTABLISHING A SECURE CONNECTION.

pub fn generateUniqueId() ![constants.UNIQUE_ID_LEN]u8 {
    var id: [constants.UNIQUE_ID_LEN]u8 = undefined;
    std.crypto.random.bytes(&id);
    return id;
}

// now we verify the unique id matches
// we used the handshake to aunthenticate
pub fn verifyUniqueId(receivedId: []const u8, expectedId: []const u8) bool {
    if (receivedId.len != expectedId.len) {
        return false;
    }
    return std.mem.eql(u8, receivedId, expectedId);
}

// prints the unique id in hex format
pub fn printUniqueId(id: []const u8) void {
    std.debug.print("Unique ID: ", .{});
    for (id) |byte| {
        std.debug.print("{x:0>2}", .{byte});
    }
    std.debug.print("\n", .{});
}

// reads unique id from the user input
// client uses this to enter the server's unique id for authentication
pub fn readUniqueIdFromInput(allocator: std.mem.Allocator) ![constants.UNIQUE_ID_LEN]u8 {
    _ = allocator;
    const stdin = std.io.getStdIn().reader();
    std.debug.print("Enter Unique ID (32 hex characters): ", .{});
    var input_buffer: [64]u8 = undefined;
    const input = (try stdin.readUntilDelimiterOrEof(&input_buffer, '\n')) orelse return error.NoInput;
    var trimmed = std.mem.trim(u8, input, &std.ascii.whitespace);
    if (trimmed.len != constants.UNIQUE_ID_LEN * 2) {
        return error.InvalidLength;
    }
    var id: [constants.UNIQUE_ID_LEN]u8 = undefined;
    for (0..constants.UNIQUE_ID_LEN) |i| {
        const hex_pair = trimmed[i * 2 .. i * 2 + 2];
        id[i] = try std.fmt.parseInt(u8, hex_pair, 16);
    }
    return id;
}
