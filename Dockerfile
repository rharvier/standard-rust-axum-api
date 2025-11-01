# Stage 1: build
FROM rust:latest AS builder
WORKDIR /app

# Prépare le cache des dépendances
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Copie le vrai code et rebuild
COPY . .
RUN cargo build --release

# Vérifie que le binaire est bien là
RUN ls -lh target/release

# Stage 2: runtime
FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 🔥 Remarque importante :
# Rust remplace les tirets par des underscores dans le nom du binaire.
# Exemple : `standard-rust-axum-api` devient `standard-rust-axum-api`
COPY --from=builder /app/target/release/standard-rust-axum-api /app/standard-rust-axum-api

RUN chmod +x /app/standard-rust-axum-api

ENV PORT=8080
EXPOSE 8080

CMD ["./standard-rust-axum-api"]
