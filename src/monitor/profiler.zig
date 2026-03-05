const std = @import("std");

// PERFORMANCE PROFILER
// Tracks message latency and encryption performance

pub const Profiler = struct {
    message_count: u64,
    total_encrypt_time: u64,
    total_decrypt_time: u64,
    mutex: std.Thread.Mutex,

    pub fn init() Profiler {
        return Profiler{
            .message_count = 0,
            .total_encrypt_time = 0,
            .total_decrypt_time = 0,
            .mutex = std.Thread.Mutex{},
        };
    }

    pub fn recordEncrypt(self: *Profiler, time_ns: u64) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.total_encrypt_time += time_ns;
        self.message_count += 1;
    }
    pub fn recordDecrypt(self: *Profiler, time_ns: u64) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.total_decrypt_time += time_ns;
    }
    pub fn getAvgEncryptTime(self: *Profiler) u64 {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.message_count == 0) return 0;
        return self.total_encrypt_time / self.message_count;
    }
    pub fn printStats(self: *Profiler) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        std.debug.print("\nPerformance Statistics\n", .{});
        std.debug.print("Messages processed: {}\n", .{self.message_count});

        if (self.message_count > 0) {
            const avg_encrypt = self.total_encrypt_time / self.message_count;
            const avg_decrypt = self.total_decrypt_time / self.message_count;
            std.debug.print("Avg encryption time: {} ns\n", .{avg_encrypt});
            std.debug.print("Avg decryption time: {} ns\n", .{avg_decrypt});
        }
        std.debug.print("==============================\n\n", .{});
    }
    pub fn reset(self: *Profiler) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        self.message_count = 0;
        self.total_encrypt_time = 0;
        self.total_decrypt_time = 0;
    }
};
