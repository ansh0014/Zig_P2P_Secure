const std = @import("std");
const server = @import("app/server.zig");
const client = @import("app/client.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    std.debug.print("\nZigP2P Secure - Chat System\n", .{});
    std.debug.print("Offline P2P Communication with Encryption\n\n", .{});

    if (args.len < 2) {
        std.debug.print("Usage:\n", .{});
        std.debug.print("  Terminal 1 (Server): {s} server\n", .{args[0]});
        std.debug.print("  Terminal 2 (Client): {s} client\n\n", .{args[0]});
        return;
    }

    const mode = args[1];

    if (std.mem.eql(u8, mode, "server")) {
        std.debug.print("Starting server...\n\n", .{});
        try server.run(allocator);
    } else if (std.mem.eql(u8, mode, "client")) {
        std.debug.print("Starting client...\n\n", .{});
        try client.run(allocator);
    } else {
        std.debug.print("Unknown mode: {s}\n", .{mode});
        std.debug.print("Usage:\n", .{});
        std.debug.print("  Terminal 1 (Server): {s} server\n", .{args[0]});
        std.debug.print("  Terminal 2 (Client): {s} client\n\n", .{args[0]});
    }
}
