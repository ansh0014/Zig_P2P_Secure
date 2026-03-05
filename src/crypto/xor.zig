const std = @import("std");

pub fn encrypt(data: []u8, key: []const u8) void {
    for (data, 0..) |*byte, i| {
        byte.* ^= key[i % key.len];
    }
}

pub fn decrypt(data: []u8, key: []const u8) void {
    for (data, 0..) |*byte, i| {
        byte.* ^= key[i % key.len];
    }
}

pub fn encryptTimed(data: []u8, key: []const u8) u64 {
    const start = std.time.nanoTimestamp();
    encrypt(data, key);
    const end = std.time.nanoTimestamp();
    return @intCast(end - start);
}

pub fn testXorEncryption() !void {
    var test_data = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    const key = "key";
    encrypt(&test_data, key);
    decrypt(&test_data, key);
}
