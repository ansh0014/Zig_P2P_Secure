const std = @import("std");
const Connection = @import("connection.zig").Connection;
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const ChaCha20 = @import("../crypto/ChaCha20.zig");
const CpuMonitor = @import("../monitor/cpu.zig").CpuMonitor;
const Profiler = @import("../monitor/profiler.zig").Profiler;

pub fn writerThread(conn: *Connection, queue: *MessageQueue, key: []const u8, monitor: *CpuMonitor, profiler: *Profiler) void {
    while (true) {
        std.time.sleep(50 * std.time.ns_per_ms);

        if (queue.pop()) |msg| {
            defer conn.allocator.free(msg.data);

            const enc_start = std.time.nanoTimestamp();
            const encrypted = ChaCha20.encryptWithNonce(msg.data, key, conn.allocator) catch {
                continue;
            };
            defer conn.allocator.free(encrypted);
            const enc_end = std.time.nanoTimestamp();
            profiler.encrypt_stats.record(@intCast(enc_end - enc_start));

            const send_start = std.time.nanoTimestamp();
            conn.send(encrypted) catch {
                return;
            };
            const send_end = std.time.nanoTimestamp();
            profiler.send_stats.record(@intCast(send_end - send_start));

            monitor.recordSent(encrypted.len);
        }
    }
}
