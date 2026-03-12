const std = @import("std");
const constants = @import("constants.zig");

pub const Config = struct {
    host: []const u8,
    port: u16,
    max_message_len: usize,
    timeout_ms: u32,

    pub fn default() Config {
        return Config{
            .host = constants.HOST,
            .port = constants.PORT,
            .max_message_len = 65536,
            .timeout_ms = 100,
        };
    }
};

pub const EncryptionMode = enum {
    xor,
    chacha20,
};

pub const LogLevel = enum {
    debug,
    info,
    warning,
    error_only,
};
