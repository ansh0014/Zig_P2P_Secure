const std = @import("std");
const builtin = @import("builtin");

pub fn getCPUUsage() !f32 {
    if (builtin.os.tag == .linux) {
        return getCPUUsageLinux();
    } else if (builtin.os.tag == .windows) {
        return getCPUUsageWindows();
    }
    return error.UnsupportedPlatform;
}

fn getCPUUsageLinux() !f32 {
    const file = try std.fs.openFileAbsolute("/proc/stat", .{});
    defer file.close();

    var buffer: [256]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];

    var lines = std.mem.splitSequence(u8, content, "\n");
    const first_line = lines.next() orelse return error.InvalidFormat;

    var fields = std.mem.splitSequence(u8, first_line, " ");
    _ = fields.next();

    var user: u64 = 0;
    var nice: u64 = 0;
    var system: u64 = 0;
    var idle: u64 = 0;

    if (fields.next()) |field| user = std.fmt.parseInt(u64, field, 10) catch 0;
    if (fields.next()) |field| nice = std.fmt.parseInt(u64, field, 10) catch 0;
    if (fields.next()) |field| system = std.fmt.parseInt(u64, field, 10) catch 0;
    if (fields.next()) |field| idle = std.fmt.parseInt(u64, field, 10) catch 0;

    const total_work = user + nice + system;
    const total = total_work + idle;

    if (total == 0) return 0;

    return @as(f32, @floatFromInt(total_work)) / @as(f32, @floatFromInt(total)) * 100.0;
}

fn getCPUUsageWindows() !f32 {
    return 0.0;
}

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
