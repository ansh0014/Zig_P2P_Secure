const std = @import("std");
const constants = @import("../utils/constants.zig");
const handshake = @import("handshake.zig");
const Connection = @import("../network/connection.zig").Connection;
const sender = @import("../network/sender.zig");
const receiver = @import("../network/receiver.zig");
const writer = @import("../network/writer.zig");
const MessageQueue = @import("../threading/message_queue.zig").MessageQueue;
const CpuMonitor = @import("../monitor/cpu.zig").CpuMonitor;
const Profiler = @import("../monitor/profiler.zig").Profiler;

pub fn run(allocator: std.mem.Allocator) !void {
    const address = try std.net.Address.parseIp("0.0.0.0", constants.PORT);

    var listener = try address.listen(.{
        .reuse_address = true,
    });
    defer listener.deinit();

    const unique_id = try handshake.generateUniqueId();

    std.debug.print("Server started on 0.0.0.0:{}\n", .{constants.PORT});
    handshake.printUniqueId(&unique_id);
    std.debug.print("Waiting for client connection...\n", .{});

    const client_conn1 = try listener.accept();
    std.debug.print("Client connected\n", .{});

    var recv_conn = try allocator.create(Connection);
    recv_conn.* = Connection.init(client_conn1.stream, allocator);
    defer {
        recv_conn.close();
        allocator.destroy(recv_conn);
    }

    std.debug.print("Performing handshake...\n", .{});

    var received_id: [constants.UNIQUE_ID_LEN]u8 = undefined;
    var total_read: usize = 0;

    while (total_read < constants.UNIQUE_ID_LEN) {
        const n = try recv_conn.stream.read(received_id[total_read..]);
        if (n == 0) return error.ConnectionClosed;
        total_read += n;
    }

    if (total_read != constants.UNIQUE_ID_LEN) {
        return error.InvalidIdLength;
    }

    std.debug.print("Handshake successful!\n", .{});

    const client_conn2 = try listener.accept();

    var send_conn = try allocator.create(Connection);
    send_conn.* = Connection.init(client_conn2.stream, allocator);
    defer {
        send_conn.close();
        allocator.destroy(send_conn);
    }

    std.debug.print("Session ready. Type /help for commands.\n\n", .{});

    const key = constants.DEFAULT_KEY[0..32];
    var output_mutex = std.Thread.Mutex{};
    var msg_queue = MessageQueue.init(allocator);
    defer msg_queue.deinit();

    var monitor = CpuMonitor.init();
    var profiler = Profiler.init();

    const sender_thread = try std.Thread.spawn(.{}, sender.senderThread, .{ &msg_queue, allocator, &output_mutex, &monitor, &profiler });
    const writer_thread = try std.Thread.spawn(.{}, writer.writerThread, .{ send_conn, &msg_queue, key, &monitor, &profiler });
    const receiver_thread = try std.Thread.spawn(.{}, receiver.receiverThread, .{ recv_conn, key, &output_mutex, &monitor, &profiler });

    sender_thread.join();
    writer_thread.join();
    receiver_thread.join();
}
