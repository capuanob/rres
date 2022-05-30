# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git clang make

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
WORKDIR /
ADD https://api.github.com/repos/capuanob/rres/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/rres.git
WORKDIR /rres

## Build
RUN clang fuzz/fuzz.c -o rres-fuzzer

## Prepare all library dependencies for copy
RUN mkdir /deps
RUN cp `ldd rres-fuzzer | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
RUN mkdir -p /tests
COPY --from=builder /rres/rres-fuzzer /rres-fuzzer
COPY --from=builder /rres/examples/*.rres /tests
COPY --from=builder /deps /usr/lib

CMD ["/rres-fuzzer", "@@"]
