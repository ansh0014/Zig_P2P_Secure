const std = @import("std");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const Message = @import("../threading/message_queue.zig").Message;

pub fn senderThread(queue: *MessageQueue, allocator: std.mem.Allocator, output_mutex: *std.Thread.Mutex) !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buffer: [1024]u8 = undefined;

    {
        output_mutex.lock();
        defer output_mutex.unlock();
        stdout.writeAll("[Sender Thread] Started\n") catch {};
    }

    while (true) {
        {
            output_mutex.lock();
            defer output_mutex.unlock();
            stdout.writeAll("You: ") catch {};
        }

        const raw_line = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse {
            break;
        };
        const line = std.mem.trim(u8, raw_line, " \t\r");

        if (line.len == 0) {
            continue;
        }

        const message_data = try allocator.dupe(u8, line);
        const message = Message.init(message_data);

        queue.push(message) catch |err| {
            output_mutex.lock();
            defer output_mutex.unlock();
            std.debug.print("[Sender] Queue error: {}\n", .{err});
            allocator.free(message_data);
            continue;
        };
    }
}
