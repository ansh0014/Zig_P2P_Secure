# Secure Concurrent Chat System - Complete Project Specification

## 1. Project Overview

ZigP2P Secure is a systems engineering project demonstrating peer-to-peer encrypted communication using concurrent architecture in Zig. Unlike simple chat applications, this project focuses on:

- Low-level TCP socket programming and protocol design
- Multi-threaded concurrency with proper synchronization
- Stream cipher cryptography (ChaCha20-IETF)
- Real-time system performance monitoring
- Production-grade error handling and resource cleanup

The project is designed as an educational platform for learning systems programming while building a functional, secure communication system.

## 2. Core Features

1. Peer-to-Peer Architecture
   - Direct TCP socket connections between two peers
   - Unique ID-based peer identification
   - Bidirectional encrypted message flow
   - No central server dependency

2. Message Queue System
   - Thread-safe, mutex-protected message queue
   - Decouples input reading from network transmission
   - Supports message ordering and backpressure handling

3. Secure Message Encryption
   - ChaCha20-IETF stream cipher implementation
   - Per-message random nonce generation
   - Message framing protocol with length prefixes
   - Automatic nonce extraction during decryption

4. Real-Time System Monitoring
   - CPU usage sampling and tracking
   - Memory consumption metrics
   - Thread lifecycle monitoring
   - Message throughput analysis

5. Configurable Runtime Architecture
   - Thread-based execution (current implementation)
   - Process-based execution (planned)
   - Switchable at startup for performance comparison

## 3. Concurrency Architecture

### Thread Model

The system uses three primary threads:

1. Sender Thread
   - Reads user input from stdin (blocking)
   - Parses and validates input
   - Pushes messages to thread-safe queue

2. Writer Thread
   - Pops messages from queue
   - Encrypts with ChaCha20 and random nonce
   - Adds length prefix and transmits over socket
   - Handles transmission errors gracefully

3. Receiver Thread
   - Polls socket with sleep-based waiting (50ms intervals)
   - Reads 4-byte length prefix
   - Reads encrypted payload
   - Decrypts with extracted nonce
   - Displays to stdout with synchronized output

### Deadlock Prevention

The system avoids deadlock through:

1. Sleep-first pattern: Threads sleep before attempting receive
2. Non-fatal error handling: Errors trigger continue, not exit
3. Mutex-protected queue: Prevents race conditions on shared data
4. Timeout-based polling: No indefinite blocking on I/O

## 4. Security Architecture

### ChaCha20-IETF Encryption

ChaCha20 is a modern stream cipher providing:
- 256-bit key space
- 96-bit (12-byte) nonce for uniqueness
- Constant-time operations (resistant to timing attacks)
- Industry standard (used in TLS 1.3, WireGuard)

### Message Framing Protocol

```
[4-byte length]
[12-byte nonce]
[encrypted payload]
```

This design provides:
- Length-based message boundaries
- Per-message randomness preventing pattern analysis
- Automatic length validation

### Handshake Protocol

1. Client connects to server
2. Server sends 32-byte Unique ID (raw bytes, no framing)
3. Client receives and verifies ID length
4. Both sides transition to main message protocol
5. Threads spawn and communication begins

Raw bytes for handshake avoid framing confusion during setup.

### Key Exchange (Current Implementation)

The system uses a shared, hardcoded key for testing:
```zig
const DEFAULT_KEY = "thirtytwocharacterkeyfor_chacha";
```

For production use, implement:
- Diffie-Hellman or ECDH key exchange
- HKDF key derivation
- Perfect forward secrecy
- Session key rotation

## 5. Monitoring and Profiling

### CPU Monitoring Module

Tracks CPU usage through platform-specific mechanisms:
- Linux: /proc/stat parsing
- Windows: WMI performance counters
- Provides per-core breakdown

### Logger Module

Structured logging with:
- Timestamp precision (milliseconds)
- Log levels (Debug, Info, Warning, Error)
- Thread-safe output with mutex protection
- Formatted message context

### Profiler Module

Performance analysis tracking:
- Function execution time
- Call count statistics
- Min/max/average timing
- Latency distribution

## 6. Project Architecture

```
src/
  main.zig                  Entry point, mode selection
  root.zig                  Root module exports
  
  app/
    client.zig              Client peer implementation
    server.zig              Server peer implementation
    handshake.zig           ID exchange protocol
  
  network/
    connection.zig          Socket abstraction layer
    sender.zig              User input thread
    receiver.zig            Network receive thread
    writer.zig              Encryption and send thread
    event_loop.zig          Future: async I/O
  
  crypto/
    ChaCha20.zig            Stream cipher encryption
    keygen.zig              Key derivation
    xor.zig                 Legacy XOR (reference)
  
  threading/
    message_queue.zig       Thread-safe queue
    thread_pool.zig         Thread management
    worker.zig              Worker implementation
  
  monitor/
    cpu.zig                 CPU usage metrics
    logger.zig              Structured logging
    profiler.zig            Performance timing
  
  utils/
    constants.zig           Global configuration
    config.zig              Runtime configuration
```

## 7. Data Flow

User Input Flow:
```
User types "hello"
  -> Sender Thread reads stdin
  -> Message created with timestamp
  -> Pushed to queue
  -> Writer Thread pops message
  -> ChaCha20 encryption with random nonce
  -> Frame: [length][nonce][ciphertext]
  -> Socket write
  -> Network transmission
```

Receive Flow:
```
Socket data arrives
  -> Receiver Thread polls socket
  -> Read 4-byte length prefix
  -> Allocate buffer
  -> Read encrypted payload
  -> Extract nonce from payload
  -> ChaCha20 decryption
  -> Display with mutex lock
  -> Loop and poll again
```

## 8. Error Handling Strategy

All functions return Result types:
- Success: Encrypted/decrypted data
- Failure: Error enum with context

Key error cases:
- Invalid key/nonce length
- Connection closed
- Message too large
- Socket I/O errors
- Allocation failures

All errors propagate via try/catch with defer cleanup.

## 9. Learning Objectives

This project teaches:

1. Networking
   - TCP protocol semantics
   - Socket programming (blocking/polling)
   - Protocol design and framing
   - Error recovery

2. Concurrency
   - Multi-threading fundamentals
   - Mutex synchronization
   - Deadlock prevention
   - Message passing architecture

3. Cryptography
   - Stream cipher operation
   - Nonce generation and management
   - Encryption/decryption cycles
   - Security considerations

4. Systems Programming
   - Memory management and allocation
   - Resource cleanup with defer
   - Error propagation
   - Performance monitoring

5. Zig Language
   - Error handling patterns
   - Thread API usage
   - Memory safety practices
   - Comptime features

## 10. Future Enhancements

Short-term:
- Non-blocking I/O with epoll/select
- ChaCha20-Poly1305 authenticated encryption
- Real-time terminal dashboard
- Message persistence

Medium-term:
- Multi-peer mesh network
- TLS/DTLS integration
- Configuration file support
- Graceful shutdown protocol

Long-term:
- GPU-accelerated encryption
- Distributed consensus
- Zero-knowledge proofs
- Post-quantum cryptography

## 11. Build and Run

Build:
```bash
zig build
```

Run Server:
```bash
zig build run -- server
```

Run Client:
```bash
zig build run -- client
```

Follow on-screen prompts for unique ID entry.

## 12. Technical Stack

- Language: Zig 0.12.1+
- Cryptography: std.crypto (built-in)
- Threading: std.Thread (built-in)
- Networking: std.net (built-in)
- Platform: Linux, Windows, macOS

---

Repository: github.com/ansh0014/Zig_P2P_Secure
License: MIT