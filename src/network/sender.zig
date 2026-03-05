const std = @import("std");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const Message = @import("../threading/message_queue.zig").Message;
const constants = @import("../utils/constants.zig");

pub fn senderThread(queue: *MessageQueue, allocator: std.mem.Allocator, output_mutex: *std.Thread.Mutex) !void {
    std.debug.print("[Sender Thread] Started\n", .{});

    const stdin = std.io.getStdIn().reader();
    var buffer: [constants.MAX_MESSAGE_LEN]u8 = undefined;

    while (true) {
        output_mutex.lock();
        std.debug.print("You: ", .{});
        output_mutex.unlock();

        const input = stdin.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
            output_mutex.lock();
            std.debug.print("[Sender] Read error: {}\n", .{err});
            output_mutex.unlock();
            continue;
        };

        if (input) |msg| {
            if (msg.len == 0) continue;

            const msg_copy = try allocator.dupe(u8, msg);

            const message = Message{
                .data = msg_copy,
                .allocator = allocator,
            };

            try queue.push(message);
        } else {
            break;
        }
    }
}
