FROM lukemathwalker/cargo-chef:latest-rust-1.86 as chef
WORKDIR /app
RUN apt update && apt install -y lld clang


FROM chef as planner
COPY . .
# Compute a lock file
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build dependencies
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release --bin zero_to_prod_rust


# Runtime step
FROM debian:bookworm-slim AS runtime
WORKDIR /app
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*
# RUN apt update && apt install -y \
#    lld \
#    clang \
#    libssl-dev \
#    pkg-config \
#    build-essential
COPY --from=builder /app/target/release/zero_to_prod_rust zero_to_prod_rust
COPY configuration configuration
ENV APP_ENVIRONMENT production
ENTRYPOINT ["./zero_to_prod_rust"]