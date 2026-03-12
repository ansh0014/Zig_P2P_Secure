const std = @import("std");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const Message = @import("../threading/message_queue.zig").Message;
const CpuMonitor = @import("../monitor/cpu.zig").CpuMonitor;
const Profiler = @import("../monitor/profiler.zig").Profiler;

pub fn senderThread(queue: *MessageQueue, allocator: std.mem.Allocator, output_mutex: *std.Thread.Mutex, monitor: *CpuMonitor, profiler: *Profiler) !void {
    const stdin = std.io.getStdIn().reader();

    var buffer: [1024]u8 = undefined;

    while (true) {
        {
            output_mutex.lock();
            defer output_mutex.unlock();
            std.debug.print("You: ", .{});
        }

        const raw_line = (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) orelse {
            break;
        };
        const line = std.mem.trim(u8, raw_line, " \t\r");

        if (line.len == 0) {
            continue;
        }

        if (std.mem.eql(u8, line, "/stats")) {
            output_mutex.lock();
            defer output_mutex.unlock();
            monitor.printStats();
            continue;
        }

        if (std.mem.eql(u8, line, "/profile")) {
            output_mutex.lock();
            defer output_mutex.unlock();
            profiler.printStats();
            continue;
        }

        if (std.mem.eql(u8, line, "/help")) {
            output_mutex.lock();
            defer output_mutex.unlock();
            std.debug.print("\n  /stats    - Session statistics\n", .{});
            std.debug.print("  /profile  - Encryption/network profiler\n", .{});
            std.debug.print("  /help     - Show this help\n\n", .{});
            continue;
        }

        const message_data = try allocator.dupe(u8, line);
        const message = Message.init(message_data);

        queue.push(message) catch {
            allocator.free(message_data);
            continue;
        };
    }
}
