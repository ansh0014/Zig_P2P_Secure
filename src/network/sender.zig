const std = @import("std");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const Message = @import("../threading/message_queue.zig").Message;

pub fn senderThread(queue: *MessageQueue, allocator: std.mem.Allocator, output_mutex: *std.Thread.Mutex) !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buffer: [1024]u8 = undefined;

    output_mutex.lock();
    try stdout.writeAll("[Sender Thread] Started\n");
    output_mutex.unlock();

    while (true) {
        output_mutex.lock();
        try stdout.writeAll("You: ");
        output_mutex.unlock();

        if (stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            if (line.len == 0) continue;

            const message_data = try allocator.dupe(u8, line);
            const message = Message.init(message_data);

            queue.push(message) catch |err| {
                output_mutex.lock();
                std.debug.print("[Sender] Queue error: {}\n", .{err});
                output_mutex.unlock();
                allocator.free(message_data);
                continue;
            };
        } else |_| {
            break;
        }
    }
}
