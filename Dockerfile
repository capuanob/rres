# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y clang make

ADD . /rres
WORKDIR /rres

## Build
RUN clang fuzz/fuzz_chunk_alloc.c -o rres-fuzzer

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /rres/rres-fuzzer /rres-fuzzer
