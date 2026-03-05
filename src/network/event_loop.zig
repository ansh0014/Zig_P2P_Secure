const std = @import("std");

pub const EventLoop = struct {
    // Use io_uring on Linux, IOCP on Windows
    // Single thread handles ALL events

    pub fn run(_: *EventLoop) !void {
        while (true) {
            // Poll for events:
            // - stdin ready to read
            // - socket ready to read
            // - socket ready to write

            // Process ONE event at a time
            // No threads, no locks!
        }
    }
};
