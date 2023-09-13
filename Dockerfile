FROM rust:latest as build

# create a new empty shell project
RUN USER=root cargo new --bin hykey
WORKDIR /hykey

# copy over your manifests
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml

# this build step will cache your dependencies
RUN cargo build --release
RUN rm src/*.rs

# copy your source tree
COPY ./src ./src

# build for release
RUN rm ./target/release/deps/hykey*
RUN cargo build --release

# our final base
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

# copy the build artifact from the build stage
COPY --from=build /hykey/target/release/hykey .

# set the startup command to run your binary
CMD ["./hykey"]