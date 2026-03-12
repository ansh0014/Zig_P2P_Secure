const std = @import("std");
const Connection = @import("connection.zig").Connection;
const ChaCha20 = @import("../crypto/ChaCha20.zig");

pub fn receiverThread(conn: *Connection, key: []const u8, output_mutex: *std.Thread.Mutex) void {
    const thread_id = std.Thread.getCurrentId();

    output_mutex.lock();
    std.debug.print("[Receiver Thread ID: {}] Started\n", .{thread_id});
    output_mutex.unlock();

    while (true) {
        std.time.sleep(50 * std.time.ns_per_ms);

        const encrypted = conn.receive() catch |err| {
            if (err != error.ConnectionClosed) {
                output_mutex.lock();
                std.debug.print("[Receiver] Error: {}\n", .{err});
                output_mutex.unlock();
            }
            continue;
        };
        defer conn.allocator.free(encrypted);

        const decrypted = ChaCha20.decryptWithNonce(encrypted, key, conn.allocator) catch |err| {
            output_mutex.lock();
            std.debug.print("[Receiver] Decryption error: {}\n", .{err});
            output_mutex.unlock();
            continue;
        };
        defer conn.allocator.free(decrypted);

        output_mutex.lock();
        std.debug.print("\nPeer: {s}\n", .{decrypted});
        std.debug.print("You: ", .{});
        output_mutex.unlock();
    }
}
