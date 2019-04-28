FROM golang:1.12-stretch as builder
WORKDIR /src
RUN git clone https://github.com/vchain-us/vcn && cd vcn && make install

FROM docker:latest
ADD verify /usr/local/bin/verify
RUN apk update && apk add bash ca-certificates jq curl && rm -rf /var/cache/apk/*
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
COPY --from=builder /go/bin/vcn /bin/vcn
ENTRYPOINT verify
