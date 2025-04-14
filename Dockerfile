FROM rust:1-slim-bookworm
WORKDIR /app
RUN apt update && apt install lld clang -y
RUN apt update && apt install -y \
    lld \
    clang \
    libssl-dev \
    pkg-config \
    build-essential
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./target/release/zero_to_prod_rust"]