const std = @import("std");
const constants = @import("../utils/constants.zig");

pub const Connection = struct {
    stream: std.net.Stream,
    allocator: std.mem.Allocator,

    pub fn init(stream: std.net.Stream, allocator: std.mem.Allocator) Connection {
        return Connection{
            .stream = stream,
            .allocator = allocator,
        };
    }

    fn readExact(self: *Connection, buf: []u8) !void {
        var total: usize = 0;
        while (total < buf.len) {
            const n = try self.stream.read(buf[total..]);
            if (n == 0) return error.ConnectionClosed;
            total += n;
        }
    }

    pub fn send(self: *Connection, message: []const u8) !void {
        const len: u32 = @intCast(message.len);
        const len_buf = std.mem.toBytes(len);
        try self.stream.writeAll(&len_buf);
        try self.stream.writeAll(message);
    }

    pub fn receive(self: *Connection) ![]u8 {
        var len_buf: [4]u8 = undefined;
        try self.readExact(&len_buf);

        const msg_len = std.mem.readInt(u32, &len_buf, .little);

        if (msg_len > constants.MAX_MESSAGE_LEN) {
            return error.MessageTooLarge;
        }
        if (msg_len == 0) {
            return error.EmptyMessage;
        }

        const message = try self.allocator.alloc(u8, msg_len);
        errdefer self.allocator.free(message);

        try self.readExact(message);

        return message;
    }

    pub fn close(self: *Connection) void {
        self.stream.close();
    }
};
