/// These define network settings, buffer sizes, and protocol parameters
pub const PORT: u16 = 8080;
pub const HOST = "127.0.0.1";

/// Unique ID length for handshake authentication
pub const UNIQUE_ID_LEN: usize = 32;

/// Maximum message size that can be sent/received
pub const MAX_MESSAGE_LEN: usize = 65536;

/// Buffer size for network operations
pub const BUFFER_SIZE: usize = 8192;

/// XOR encryption key (in real app, derive from unique ID)
pub const DEFAULT_KEY = "thirtytwocharacterkeyfor_chacha!!";

/// Timeout for queue operations
pub const QUEUE_TIMEOUT_MS: u32 = 100;

/// Polling interval for receiver
pub const RECEIVER_POLL_MS: u32 = 50;
