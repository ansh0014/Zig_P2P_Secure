# Problem: Messages Not Received in TCP Chat System

## Overview

While developing the **Secure Concurrent Chat System**, a critical issue was encountered where messages sent from the client or server were not received on the opposite side.

Both the client and server successfully established a connection and completed the handshake process. The sender and writer threads appeared to function correctly, but the receiver thread did not display any incoming messages.

## System Architecture

Each peer in the system runs the following threads:

* **Sender Thread** – Reads user input from the terminal.
* **Writer Thread** – Encrypts messages and sends them through the TCP socket.
* **Receiver Thread** – Listens for incoming messages from the TCP socket.

Expected architecture:

```
Client
 ├── Sender Thread
 ├── Writer Thread
 └── Receiver Thread

Server
 ├── Sender Thread
 ├── Writer Thread
 └── Receiver Thread
```

## Observed Behavior

1. Client connects to server successfully.
2. Handshake completes and encryption session is established.
3. Sender thread reads user input.
4. Writer thread encrypts and sends the message.

Example logs:

```
[Writer] Got message from queue: hi (len=2)
[Writer] Encrypted 14 bytes, sending...
```

However, the **receiver thread never prints the message**.

## Root Cause

The issue occurs due to **incorrect TCP message handling**.

TCP is a **stream protocol**, not a message protocol.

When sending data over TCP:

* Messages may arrive **split across multiple packets**.
* Messages may arrive **combined together**.
* The receiver cannot know where one message ends and the next begins.

Example:

Sender sends:

```
"hi"
```

Receiver might receive:

```
"h"
"i"
```

or

```
"hi"
```

or

```
"hihello"
```

Without a **message framing protocol**, the receiver cannot correctly determine message boundaries.

## Result

The receiver thread either:

* Waits indefinitely for more bytes, or
* Reads incorrect data sizes.

As a result, messages appear to be "lost".

## Impact

* Chat messages do not display.
* Receiver thread blocks waiting for data.
* Communication becomes unreliable.

This issue is common when implementing custom protocols on top of TCP.
