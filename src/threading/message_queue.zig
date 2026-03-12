const std = @import("std");

pub const Message = struct {
    data: []u8,
    timestamp: i64,

    pub fn init(data: []u8) Message {
        return Message{
            .data = data,
            .timestamp = std.time.milliTimestamp(),
        };
    }

    pub fn deinit(self: *Message) void {
        self.allocator.free(self.data);
    }
};

pub const MessageQueue = struct {
    items: std.ArrayList(Message),
    mutex: std.Thread.Mutex,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) MessageQueue {
        return MessageQueue{
            .items = std.ArrayList(Message).init(allocator),
            .mutex = std.Thread.Mutex{},
            .allocator = allocator,
        };
    }

    pub fn push(self: *MessageQueue, message: Message) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        try self.items.append(message);
    }

    pub fn pop(self: *MessageQueue) ?Message {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.items.items.len == 0) {
            return null;
        }

        return self.items.orderedRemove(0);
    }

    pub fn len(self: *MessageQueue) usize {
        self.mutex.lock();
        defer self.mutex.unlock();

        return self.items.items.len;
    }

    pub fn deinit(self: *MessageQueue) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        for (self.items.items) |*msg| {
            self.allocator.free(msg.data);
        }

        self.items.deinit();
    }
};
