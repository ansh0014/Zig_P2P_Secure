
/// These define network settings, buffer sizes, and protocol parameters
pub const PORT: u16 = 8080;
pub const HOST = "127.0.0.1";

/// Unique ID length for handshake authentication
pub const UNIQUE_ID_LEN: usize = 16;

/// Maximum message size that can be sent/received
pub const MAX_MESSAGE_LEN: usize = 4096;

/// Buffer size for network operations
pub const BUFFER_SIZE: usize = 8192;

/// XOR encryption key (in real app, derive from unique ID)
pub const DEFAULT_KEY = "SecureKey123456!";
