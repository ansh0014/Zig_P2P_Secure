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
    std.debug.print("Client mode\n", .{});

    const unique_id = try handshake.readUniqueIdFromInput();

    const host = std.process.getEnvVarOwned(allocator, "PEER_HOST") catch null;
    defer if (host) |h| allocator.free(h);
    const target_host = if (host) |h| h else constants.HOST;

    std.debug.print("Connecting to {s}:{}...\n", .{ target_host, constants.PORT });

    const address = try std.net.Address.parseIp(target_host, constants.PORT);

    const stream1 = try std.net.tcpConnectToAddress(address);

    var send_conn = try allocator.create(Connection);
    send_conn.* = Connection.init(stream1, allocator);
    defer {
        send_conn.close();
        allocator.destroy(send_conn);
    }

    std.debug.print("Connected!\n", .{});

    _ = try send_conn.stream.writeAll(&unique_id);

    const stream2 = try std.net.tcpConnectToAddress(address);

    var recv_conn = try allocator.create(Connection);
    recv_conn.* = Connection.init(stream2, allocator);
    defer {
        recv_conn.close();
        allocator.destroy(recv_conn);
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
