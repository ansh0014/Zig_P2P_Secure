const std = @import("std");

pub const Message = struct {
    data: []const u8,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *Message) void {
        self.allocator.free(self.data);
    }
};

pub const MessageQueue = struct {
    queue: std.ArrayList(Message),
    mutex: std.Thread.Mutex,
    not_empty: std.Thread.Condition,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) MessageQueue {
        return .{
            .queue = std.ArrayList(Message).init(allocator),
            .mutex = .{},
            .not_empty = .{},
            .allocator = allocator,
        };
    }

    pub fn push(self: *MessageQueue, msg: Message) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        try self.queue.append(msg);
        self.not_empty.signal();
    }

    pub fn pop(self: *MessageQueue) ?Message {
        self.mutex.lock();
        defer self.mutex.unlock();

        while (self.queue.items.len == 0) {
            self.not_empty.wait(&self.mutex);
        }

        return self.queue.orderedRemove(0);
    }

    pub fn deinit(self: *MessageQueue) void {
        for (self.queue.items) |*msg| {
            msg.deinit();
        }
        self.queue.deinit();
    }
};
