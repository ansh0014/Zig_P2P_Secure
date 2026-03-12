const std = @import("std");
const Connection = @import("connection.zig").Connection;
const ChaCha20 = @import("../crypto/ChaCha20.zig");
const CpuMonitor = @import("../monitor/cpu.zig").CpuMonitor;
const Profiler = @import("../monitor/profiler.zig").Profiler;

pub fn receiverThread(conn: *Connection, key: []const u8, output_mutex: *std.Thread.Mutex, monitor: *CpuMonitor, profiler: *Profiler) void {
    while (true) {
        const encrypted = conn.receive() catch |err| {
            if (err == error.ConnectionClosed) break;
            continue;
        };
        defer conn.allocator.free(encrypted);

        const dec_start = std.time.nanoTimestamp();
        const decrypted = ChaCha20.decryptWithNonce(encrypted, key, conn.allocator) catch {
            continue;
        };
        defer conn.allocator.free(decrypted);
        const dec_end = std.time.nanoTimestamp();
        profiler.decrypt_stats.record(@intCast(dec_end - dec_start));

        monitor.recordReceived(encrypted.len);

        output_mutex.lock();
        defer output_mutex.unlock();
        std.debug.print("\nPeer: {s}\nYou: ", .{decrypted});
    }
}
