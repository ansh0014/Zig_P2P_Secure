const std = @import("std");

// THREAD POOL IMPLEMENTATION
// Manages multiple worker threads for concurrent operations
pub const ThreadPool = struct {
    allocator: std.mem.Allocator,
    threads: std.ArrayList(std.Thread),
    pub fn init(allocator: std.mem.Allocator) ThreadPool {
        return ThreadPool{
            .allocator = allocator,
            .threads = std.ArrayList(std.Thread).init(allocator),
        };
    } 
    // Spawns a new thread and adds it to the pool
    pub fn spawn(self: *ThreadPool, comptime func: anytype, args: anytype) !void {
        const thread = try std.Thread.spawn(.{}, func, args);
        try self.threads.append(thread);
    } 
    // Waits for all threads to complete
    pub fn joinAll(self: *ThreadPool) void {
        for (self.threads.items) |thread| {
            thread.join();
        }
    }  
    // Cleans up thread pool resources
    pub fn deinit(self: *ThreadPool) void {
        self.threads.deinit();
    }
};