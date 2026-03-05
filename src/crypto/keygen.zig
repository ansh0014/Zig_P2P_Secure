const std = @import("std");
pub fn deriveKeyFromId(id: []const u8, allocator: std.mem.Allocator) ![]u8 {
    var key = try allocator.alloc(u8, 32);
    var hasher = std.crypto.hash.sha2.Sha256.init(.{});
    hasher.update(id);
    hasher.final(key[0..32]);
    return key;
}

// Generates a random key of specified length
pub fn generateRandomKey(allocator: std.mem.Allocator, len: usize) ![]u8 {
    const key = try allocator.alloc(u8, len);
    std.crypto.random.bytes(key);
    return key;
}
