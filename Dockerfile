FROM rust:latest AS builder
WORKDIR /app

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

COPY . .
RUN cargo build --release

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates binutils && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/standard-rust-axum-api .

RUN strip /app/standard-rust-axum-api

RUN useradd -m appuser
USER appuser

ENV PORT=8080
EXPOSE 8080
CMD ["./standard-rust-axum-api"]