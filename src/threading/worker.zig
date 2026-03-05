const std = @import("std");
pub const ThreadContext = struct {
    id: usize,
    allocator: std.mem.Allocator,
    data: ?*anyopaque = null,
};
pub fn createContext(id: usize, allocator: std.mem.Allocator) ThreadContext {
    return ThreadContext{
        .id = id,
        .allocator = allocator,
    };
}
pub fn getCurrentThreadId() std.Thread.Id {
    return std.Thread.getCurrentId();
}
pub fn printThreadInfo(name: []const u8) void {
    const thread_id = getCurrentThreadId();
    std.debug.print("[{s} Thread ID: {}] Started\n", .{ name, thread_id });
}
