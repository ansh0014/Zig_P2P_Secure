const std = @import("std");

const ChaCha20 = std.crypto.stream.chacha.ChaCha20IETF;

pub fn encrypt(plaintext: []const u8, key: []const u8, nonce: []const u8, allocator: std.mem.Allocator) ![]u8 {
    if (key.len != 32) return error.InvalidKeyLength;
    if (nonce.len != 12) return error.InvalidNonceLength;
    const ciphertext = try allocator.alloc(u8, plaintext.len);
    var key_array: [32]u8 = undefined;
    var nonce_array: [12]u8 = undefined;
    @memcpy(&key_array, key[0..32]);
    @memcpy(&nonce_array, nonce[0..12]);

    var cipher = ChaCha20.init(key_array, nonce_array);
    cipher.xor(ciphertext, plaintext);

    return ciphertext;
}

pub fn decrypt(ciphertext: []const u8, key: []const u8, nonce: []const u8, allocator: std.mem.Allocator) ![]u8 {
    return encrypt(ciphertext, key, nonce, allocator);
}

// Generate a random nonce for ChaCha20
pub fn generateNonce() [12]u8 {
    var nonce: [12]u8 = undefined;
    std.crypto.random.bytes(&nonce);
    return nonce;
}

// Encrypt with automatic nonce generation
// Returns nonce prepended to ciphertext
pub fn encryptWithNonce(plaintext: []const u8, key: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const nonce = generateNonce();
    const ciphertext = try encrypt(plaintext, key, &nonce, allocator);
    defer allocator.free(ciphertext);

    var result = try allocator.alloc(u8, 12 + ciphertext.len);
    @memcpy(result[0..12], &nonce);
    @memcpy(result[12..], ciphertext);

    return result;
}

// Decrypt data with nonce prepended
pub fn decryptWithNonce(data: []const u8, key: []const u8, allocator: std.mem.Allocator) ![]u8 {
    if (data.len < 12) return error.DataTooShort;

    const nonce = data[0..12];
    const ciphertext = data[12..];

    return decrypt(ciphertext, key, nonce, allocator);
}
