FROM pierrezemb/gostatic:latest as gostatic
FROM docker:latest
ADD verify.cnil /usr/local/bin/verify
RUN apk update && apk add bash ca-certificates jq curl && rm -rf /var/cache/apk/*
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
RUN curl https://github.com/vchain-us/vcn/releases/download/v0.9.9/vcn-v0.9.9-linux-amd64-static -o /usr/local/bin/vcn -s -L && chmod +x /usr/local/bin/vcn
COPY --from=gostatic /goStatic /bin/goStatic

ENTRYPOINT verify
