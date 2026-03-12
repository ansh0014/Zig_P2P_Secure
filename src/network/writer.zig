const std = @import("std");
const Connection = @import("connection.zig").Connection;
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const ChaCha20 = @import("../crypto/ChaCha20.zig");

pub fn writerThread(conn: *Connection, queue: *MessageQueue, key: []const u8) void {
    std.debug.print("[Writer Thread] Started\n", .{});

    while (true) {
        std.time.sleep(50 * std.time.ns_per_ms);

        if (queue.pop()) |msg| {
            defer conn.allocator.free(msg.data);

            const encrypted = ChaCha20.encryptWithNonce(msg.data, key, conn.allocator) catch |err| {
                std.debug.print("[Writer] Encryption error: {}\n", .{err});
                continue;
            };
            defer conn.allocator.free(encrypted);

            conn.send(encrypted) catch |err| {
                std.debug.print("[Writer] Send error: {}\n", .{err});
                return;
            };
        }
    }
}
