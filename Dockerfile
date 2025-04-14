# build step
FROM rust:1-slim-bookworm as builder
WORKDIR /app
RUN apt update && apt install -y \
    lld \
    clang \
    libssl-dev \
    pkg-config \
    build-essential
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release


# Runtime step
FROM debian:bookworm-slim AS runtime
WORKDIR /app
COPY --from=builder /app/target/release/zero_to_prod_rust zero_to_prod_rust
COPY configuration configuration
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./zero_to_prod_rust"]