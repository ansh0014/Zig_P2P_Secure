const std = @import("std");

pub const CpuMonitor = struct {
    start_time: i64,
    messages_sent: u64,
    messages_received: u64,
    bytes_encrypted: u64,
    bytes_decrypted: u64,

    pub fn init() CpuMonitor {
        return CpuMonitor{
            .start_time = std.time.milliTimestamp(),
            .messages_sent = 0,
            .messages_received = 0,
            .bytes_encrypted = 0,
            .bytes_decrypted = 0,
        };
    }

    pub fn getUptimeSeconds(self: *CpuMonitor) f64 {
        const elapsed = std.time.milliTimestamp() - self.start_time;
        return @as(f64, @floatFromInt(elapsed)) / 1000.0;
    }

    pub fn recordSent(self: *CpuMonitor, bytes: u64) void {
        self.messages_sent += 1;
        self.bytes_encrypted += bytes;
    }

    pub fn recordReceived(self: *CpuMonitor, bytes: u64) void {
        self.messages_received += 1;
        self.bytes_decrypted += bytes;
    }

    pub fn printStats(self: *CpuMonitor) void {
        const uptime = self.getUptimeSeconds();
        std.debug.print("\n--- SESSION STATS ---\n", .{});
        std.debug.print("  Uptime:     {d:.1} sec\n", .{uptime});
        std.debug.print("  Sent:       {} messages\n", .{self.messages_sent});
        std.debug.print("  Received:   {} messages\n", .{self.messages_received});
        std.debug.print("  Encrypted:  {} bytes\n", .{self.bytes_encrypted});
        std.debug.print("  Decrypted:  {} bytes\n", .{self.bytes_decrypted});
        if (uptime > 0) {
            const msg_per_min = @as(f64, @floatFromInt(self.messages_sent + self.messages_received)) / uptime * 60.0;
            std.debug.print("  Throughput: {d:.1} msg/min\n", .{msg_per_min});
        }
        std.debug.print("---------------------\n", .{});
        std.debug.print("You: ", .{});
    }
};
