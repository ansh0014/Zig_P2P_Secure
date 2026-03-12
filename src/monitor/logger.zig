const std = @import("std");

pub const LogLevel = enum {
    Debug,
    Info,
    Warning,
    Error,
    Critical,
};

pub fn log(level: LogLevel, comptime format: []const u8, args: anytype) void {
    const timestamp = std.time.milliTimestamp();
    const seconds = timestamp / 1000;
    const millis = timestamp % 1000;

    const level_str = switch (level) {
        .Debug => "DEBUG",
        .Info => "INFO",
        .Warning => "WARN",
        .Error => "ERROR",
        .Critical => "CRIT",
    };

    std.debug.print("[{d}.{d:0>3}] [{}] {} ", .{ seconds, millis, level_str, format });
    std.debug.print(format, args);
    std.debug.print("\n", .{});
}
