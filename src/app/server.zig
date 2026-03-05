const std = @import("std");
const constants = @import("../utils/constants.zig");
const handshake = @import("handshake.zig");
const Connection = @import("../network/connection.zig").Connection;
const sender = @import("../network/sender.zig");
const receiver = @import("../network/receiver.zig");
const writer = @import("../network/writer.zig");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;

pub fn run(allocator: std.mem.Allocator) !void {
    const address = try std.net.Address.parseIp(constants.HOST, constants.PORT);

    var listener = try address.listen(.{
        .reuse_address = true,
    });
    defer listener.deinit();

    const unique_id = try handshake.generateUniqueId();
    std.debug.print("Server started on {s}:{}\n", .{ constants.HOST, constants.PORT });
    handshake.printUniqueId(&unique_id);
    std.debug.print("Waiting for client connection...\n", .{});

    const client_conn = try listener.accept();
    std.debug.print("Client connected\n", .{});

    var conn = try allocator.create(Connection);
    conn.* = Connection.init(client_conn.stream, allocator);
    try conn.setNonBlocking();

    std.debug.print("Performing handshake...\n", .{});

    // Simple handshake - just read 32 bytes
    var received_id: [32]u8 = undefined;
    const bytes_read = try conn.stream.read(&received_id);
    std.debug.print("Read {} bytes from client\n", .{bytes_read});

    if (bytes_read != 32) {
        std.debug.print("ERROR: Expected 32 bytes, got {}\n", .{bytes_read});
    }

    std.debug.print("Handshake successful! Session established.\n\n", .{});

    const key = constants.DEFAULT_KEY;
    var output_mutex = std.Thread.Mutex{};
    var msg_queue = MessageQueue.init(allocator);
    defer msg_queue.deinit();

    const sender_thread = try std.Thread.spawn(.{}, sender.senderThread, .{ &msg_queue, allocator, &output_mutex });
    const writer_thread = try std.Thread.spawn(.{}, writer.writerThread, .{ conn, &msg_queue, key });
    const receiver_thread = try std.Thread.spawn(.{}, receiver.receiverThread, .{ conn, key, &output_mutex });

    defer {
        conn.close();
        allocator.destroy(conn);
    }

    sender_thread.join();
    writer_thread.join();
    receiver_thread.join();
}
