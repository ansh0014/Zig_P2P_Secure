const std = @import("std");
const server = @import("app/server.zig");
const client = @import("app/client.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: zigp2p [server|client]\n", .{});
        return;
    }

    const mode = args[1];

    if (std.mem.eql(u8, mode, "server")) {
        try server.run(allocator);
    } else if (std.mem.eql(u8, mode, "client")) {
        try client.run(allocator);
    } else {
        std.debug.print("Unknown mode: {s}\nUse 'server' or 'client'\n", .{mode});
    }
}
