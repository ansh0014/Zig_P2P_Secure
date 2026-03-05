const std = @import("std");
const Connection = @import("connection.zig").Connection;
const xor = @import("../crypto/xor.zig");

pub fn receiverThread(conn: *Connection, key: []const u8, output_mutex: *std.Thread.Mutex) !void {
    const thread_id = std.Thread.getCurrentId();

    output_mutex.lock();
    std.debug.print("[Receiver Thread ID: {}] Started\n", .{thread_id});
    output_mutex.unlock();

    var iteration: usize = 0;
    while (true) {
        iteration += 1;

        // Prove thread is alive
        if (iteration % 10 == 0) {
            output_mutex.lock();
            std.debug.print("[Receiver] Still alive (iteration {})\n", .{iteration});
            output_mutex.unlock();
        }

        const encrypted = conn.receive() catch |err| {
            output_mutex.lock();
            std.debug.print("[Receiver] receive() error: {}\n", .{err});
            output_mutex.unlock();

            // CRITICAL: Don't exit! Just continue
            std.time.sleep(100 * std.time.ns_per_ms);
            continue;
        };
        defer conn.allocator.free(encrypted);

        output_mutex.lock();
        std.debug.print("[Receiver] Got encrypted data, length: {}\n", .{encrypted.len});
        output_mutex.unlock();

        const decrypted = try conn.allocator.dupe(u8, encrypted);
        defer conn.allocator.free(decrypted);

        xor.decrypt(decrypted, key);

        output_mutex.lock();
        std.debug.print("\n=== PEER MESSAGE ===\n", .{});
        std.debug.print("Peer: {s}\n", .{decrypted});
        std.debug.print("====================\n", .{});
        std.debug.print("You: ", .{});
        output_mutex.unlock();
    }
}
