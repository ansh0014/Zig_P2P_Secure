const std = @import("std");
const constants = @import("../utils/constants.zig");
const handshake = @import("handshake.zig");
const Connection = @import("../network/connection.zig").Connection;
const sender = @import("../network/sender.zig");
const receiver = @import("../network/receiver.zig");
const writer = @import("../network/writer.zig");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Client mode\n", .{});

    const unique_id = try handshake.readUniqueIdFromInput();

    std.debug.print("Connecting to {s}:{}...\n", .{ constants.HOST, constants.PORT });

    const address = try std.net.Address.parseIp(constants.HOST, constants.PORT);
    const stream = try std.net.tcpConnectToAddress(address);

    var conn = try allocator.create(Connection);
    conn.* = Connection.init(stream, allocator);
    defer {
        conn.close();
        allocator.destroy(conn);
    }

    std.debug.print("Connected to server!\n", .{});
    std.debug.print("Sending handshake...\n", .{});

    _ = try conn.stream.writeAll(&unique_id);

    std.debug.print("Handshake sent. Session established.\n\n", .{});

    const key = constants.DEFAULT_KEY[0..32];
    var output_mutex = std.Thread.Mutex{};
    var msg_queue = MessageQueue.init(allocator);
    defer msg_queue.deinit();

    const sender_thread = try std.Thread.spawn(.{}, sender.senderThread, .{ &msg_queue, allocator, &output_mutex });
    const writer_thread = try std.Thread.spawn(.{}, writer.writerThread, .{ conn, &msg_queue, key });
    const receiver_thread = try std.Thread.spawn(.{}, receiver.receiverThread, .{ conn, key, &output_mutex });

    sender_thread.join();
    writer_thread.join();
    receiver_thread.join();
}
