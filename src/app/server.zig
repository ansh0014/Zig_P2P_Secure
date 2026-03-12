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
    defer {
        conn.close();
        allocator.destroy(conn);
    }

    std.debug.print("Performing handshake...\n", .{});

    var received_id: [constants.UNIQUE_ID_LEN]u8 = undefined;
    var total_read: usize = 0;

    while (total_read < constants.UNIQUE_ID_LEN) {
        const n = try conn.stream.read(received_id[total_read..]);
        if (n == 0) return error.ConnectionClosed;
        total_read += n;
    }

    if (total_read != constants.UNIQUE_ID_LEN) {
        return error.InvalidIdLength;
    }

    std.debug.print("Handshake successful! Session established.\n\n", .{});

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
