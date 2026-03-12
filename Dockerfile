FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y curl xz-utils && rm -rf /var/lib/apt/lists/*

RUN curl -L https://ziglang.org/download/0.12.1/zig-linux-x86_64-0.12.1.tar.xz | tar -xJ -C /opt && \
    ln -s /opt/zig-linux-x86_64-0.12.1/zig /usr/local/bin/zig

WORKDIR /app
COPY src/ src/
COPY build.zig .

RUN zig build -Doptimize=ReleaseSafe

FROM debian:bookworm-slim

WORKDIR /app
COPY --from=builder /app/zig-out/bin/zigp2p .

EXPOSE 8080

ENTRYPOINT ["./zigp2p"]
