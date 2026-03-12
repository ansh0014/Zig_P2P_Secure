# Solution: Implement Message Framing for TCP Communication

## Overview

The issue was resolved by implementing a **message framing protocol**.

Each message sent through TCP now includes a **fixed-length header containing the message size**.

This allows the receiver to know exactly how many bytes to read for each message.

## Message Format

Each packet sent over the network follows this structure:

```
[4 bytes message length][encrypted message bytes]
```

Example:

```
[0005][hello]
```

Where:

* First **4 bytes** represent the message length.
* Remaining bytes contain the **encrypted message payload**.

## Sending Messages

The writer thread performs the following steps:

1. Encrypt the message.
2. Compute the encrypted message length.
3. Send the message length (4 bytes).
4. Send the encrypted message.

Conceptual implementation:

```
len = encrypted_message_length

write(socket, length_bytes)
write(socket, encrypted_message)
```

This ensures the receiver knows exactly how much data to expect.

## Receiving Messages

The receiver thread performs the following steps:

1. Read the first **4 bytes** from the socket.
2. Parse the message length.
3. Allocate a buffer of that size.
4. Read exactly that many bytes from the socket.
5. Decrypt the message.
6. Print the message.

Conceptual flow:

```
read 4 bytes → message_length
allocate buffer(message_length)
read message_length bytes
decrypt message
display message
```

## Receiver Thread Loop

The receiver thread continuously listens for messages:

```
while connection_active:
    read message length
    read encrypted message
    decrypt message
    print message
```

Because the socket read blocks until data arrives, the receiver thread automatically wakes when a new message is sent.

No manual thread switching is required.

## Advantages of This Approach

* Reliable message boundaries
* Works correctly with TCP streams
* Prevents partial message reads
* Supports encrypted payloads
* Scales for larger messages

## Additional Improvements

Future enhancements may include:

* Message authentication tags
* Non-blocking socket operations
* Message compression
* Protocol versioning
* Packet headers for metadata

## Final Result

After implementing message framing, the chat system correctly delivers messages between the client and server, and the receiver thread processes incoming messages reliably.
