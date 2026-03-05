const std = @import("std");
const constants = @import("constants.zig");


pub const Config = struct {
    host: []const u8,
    port: u16,
    encryption_mode: EncryptionMode,
    enable_monitoring: bool,
    log_level: LogLevel,

    pub fn default() Config {
        return Config{
            .host = constants.HOST,
            .port = constants.PORT,
            .encryption_mode = .xor,
            .enable_monitoring = true,
            .log_level = .info,
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
