const std = @import("std");
const constants = @import("../utils/constants.zig");
const builtin = @import("builtin");

pub const Connection = struct {
    stream: std.net.Stream,
    allocator: std.mem.Allocator,

    pub fn init(stream: std.net.Stream, allocator: std.mem.Allocator) Connection {
        return Connection{
            .stream = stream,
            .allocator = allocator,
        };
    }

    pub fn setNonBlocking(self: *Connection) !void {
        // REMOVE non-blocking for now - use blocking sockets
        _ = self;
    }

    pub fn send(self: *Connection, message: []const u8) !void {
        const len: u32 = @intCast(message.len);
        const len_buf = std.mem.toBytes(len);

        std.debug.print("[send] Sending length: {}\n", .{len});
        _ = try self.stream.writeAll(&len_buf);

        std.debug.print("[send] Sending message: {s}\n", .{message});
        _ = try self.stream.writeAll(message);

        std.debug.print("[send] ✓ Sent {} bytes successfully\n", .{message.len});
    }

    pub fn receive(self: *Connection) ![]u8 {
        var len_buf: [4]u8 = undefined;

        std.debug.print("[receive] Waiting for 4 bytes (length)...\n", .{});
        _ = try self.stream.readAll(&len_buf);

        const msg_len = std.mem.readInt(u32, &len_buf, .little);
        std.debug.print("[receive] Got length: {}\n", .{msg_len});

        if (msg_len > constants.MAX_MESSAGE_LEN) {
            std.debug.print("[receive] ERROR: Length too large: {}\n", .{msg_len});
            return error.MessageTooLarge;
        }
        if (msg_len == 0) {
            std.debug.print("[receive] ERROR: Empty message\n", .{});
            return error.EmptyMessage;
        }

        const message = try self.allocator.alloc(u8, msg_len);
        errdefer self.allocator.free(message);

        std.debug.print("[receive] Reading {} bytes of message...\n", .{msg_len});
        _ = try self.stream.readAll(message);

        std.debug.print("[receive] ✓ Received: {s}\n", .{message});
        return message;
    }

    pub fn close(self: *Connection) void {
        self.stream.close();
    }
};
