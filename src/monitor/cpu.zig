const std = @import("std");

// CPU MONITORING
// Tracks CPU usage and thread performance

pub const CpuMonitor = struct {
    start_time: i64,

    pub fn init() CpuMonitor {
        return CpuMonitor{
            .start_time = std.time.milliTimestamp(),
        };
    }

    // Get elapsed time in milliseconds
    pub fn getElapsedMs(self: *CpuMonitor) i64 {
        const now = std.time.milliTimestamp();
        return now - self.start_time;
    }

    // Reset the timer
    pub fn reset(self: *CpuMonitor) void {
        self.start_time = std.time.milliTimestamp();
    }

    // Print CPU stats
    pub fn printStats(self: *CpuMonitor) void {
        const elapsed = self.getElapsedMs();
        std.debug.print("CPU Monitor - Elapsed: {} ms\n", .{elapsed});
    }
};

// Measure execution time of a function
pub fn measureTime(comptime func: anytype, args: anytype) !u64 {
    const start = std.time.nanoTimestamp();
    try func(args);
    const end = std.time.nanoTimestamp();
    return @intCast(end - start);
}
