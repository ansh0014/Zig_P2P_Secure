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
};

pub const Profiler = struct {
    name: []const u8,
    start_time: i64,
    result: *ProfileResult,

    pub fn init(name: []const u8, result: *ProfileResult) Profiler {
        return Profiler{
            .name = name,
            .start_time = std.time.nanoTimestamp(),
            .result = result,
        };
    }

    pub fn end(self: Profiler) void {
        const end_time = std.time.nanoTimestamp();
        const duration: u64 = @intCast(end_time - self.start_time);

        self.result.calls += 1;
        self.result.total_ns += duration;
        if (duration < self.result.min_ns) self.result.min_ns = duration;
        if (duration > self.result.max_ns) self.result.max_ns = duration;
    }
};

pub fn printResult(result: ProfileResult) void {
    std.debug.print("{s}: {} calls, avg {d} ns, min {d} ns, max {d} ns\n", .{
        result.name,
        result.calls,
        result.average(),
        result.min_ns,
        result.max_ns,
    });
}
