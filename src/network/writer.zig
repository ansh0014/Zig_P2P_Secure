const std = @import("std");
const Connection = @import("connection.zig").Connection;
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const xor = @import("../crypto/xor.zig");

pub fn writerThread(conn: *Connection, queue: *MessageQueue, key: []const u8) !void {
    std.debug.print("[Writer Thread] Started\n", .{});

    var msg_count: usize = 0;
    while (true) {
        std.debug.print("[Writer] Waiting for message from queue...\n", .{});

        if (queue.pop()) |msg| {
            msg_count += 1;
            std.debug.print("[Writer] Got message #{} from queue: {s}\n", .{ msg_count, msg.data });

            defer {
                var mutable_msg = msg;
                mutable_msg.deinit();
            }

            const encrypted = try conn.allocator.dupe(u8, msg.data);
            defer conn.allocator.free(encrypted);

            xor.encrypt(encrypted, key);
            std.debug.print("[Writer] Encrypted message\n", .{});

            conn.send(encrypted) catch |err| {
                std.debug.print("[Writer] Send error: {}\n", .{err});
                return;
            };

            std.debug.print("[Writer]  Message #{} sent successfully\n", .{msg_count});
        }
    }
}
