const std = @import("std");
// logging system for monitoring
pub const LogLevel = enum { debug, info, warning, error_onlyk };
pub const Logger = struct {
    level: LogLevel,
    mutex: std.Thread.Mutex,
    pub fn init(level: LogLevel) Logger {
        return Logger{
            .level = level,
            .mutex = std.Thread.Mutex.init(),
        };
    }
    pub fn debug(self: *Logger, comptime fmt: []const u8, args: anytype) void {
        if (@intFromEnum(self.level) <= @intFromEnum(LogLevel.debug)) {
            self.log("[DEBUG]", fmt, args);
        }
    }

    pub fn info(self: *Logger, comptime fmt: []const u8, args: anytype) void {
        if (@intFromEnum(self.level) <= @intFromEnum(LogLevel.info)) {
            self.log("[INFO]", fmt, args);
        }
    }

    pub fn warning(self: *Logger, comptime fmt: []const u8, args: anytype) void {
        if (@intFromEnum(self.level) <= @intFromEnum(LogLevel.warning)) {
            self.log("[WARNING]", fmt, args);
        }
    }

    pub fn err(self: *Logger, comptime fmt: []const u8, args: anytype) void {
        self.log("[ERROR]", fmt, args);
    }

    fn log(self: *Logger, prefix: []const u8, comptime fmt: []const u8, args: anytype) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        const timestamp = std.time.microTimestamp();
        std.debug.print("{} {s} ", .{ timestamp, prefix });
        std.debug.print(fmt, args);
        std.debug.print("\n", .{});
    }
};
