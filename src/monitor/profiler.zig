const std = @import("std");

pub const ProfileResult = struct {
    name: []const u8,
    calls: u64 = 0,
    total_ns: u64 = 0,
    min_ns: u64 = std.math.maxInt(u64),
    max_ns: u64 = 0,

    pub fn average(self: ProfileResult) u64 {
        if (self.calls == 0) return 0;
        return self.total_ns / self.calls;
    }

    pub fn record(self: *ProfileResult, duration_ns: u64) void {
        self.calls += 1;
        self.total_ns += duration_ns;
        if (duration_ns < self.min_ns) self.min_ns = duration_ns;
        if (duration_ns > self.max_ns) self.max_ns = duration_ns;
    }
};

pub const Profiler = struct {
    encrypt_stats: ProfileResult,
    decrypt_stats: ProfileResult,
    send_stats: ProfileResult,

    pub fn init() Profiler {
        return Profiler{
            .encrypt_stats = .{ .name = "Encrypt" },
            .decrypt_stats = .{ .name = "Decrypt" },
            .send_stats = .{ .name = "Net Send" },
        };
    }

    pub fn printStats(self: *Profiler) void {
        std.debug.print("\n--- PROFILER ---\n", .{});
        printOne(&self.encrypt_stats);
        printOne(&self.decrypt_stats);
        printOne(&self.send_stats);
        std.debug.print("----------------\n", .{});
        std.debug.print("You: ", .{});
    }

    fn printOne(r: *ProfileResult) void {
        if (r.calls == 0) {
            std.debug.print("  {s}: no data\n", .{r.name});
            return;
        }
        const avg_us = r.average() / 1000;
        const min_us = r.min_ns / 1000;
        const max_us = r.max_ns / 1000;
        std.debug.print("  {s}: {} calls | avg {} us | min {} us | max {} us\n", .{
            r.name, r.calls, avg_us, min_us, max_us,
        });
    }
};
