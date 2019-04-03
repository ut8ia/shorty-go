# Multi-stage build setup (https://docs.docker.com/develop/develop-images/multistage-build/)

# Stage 1 (to create a "build" image, ~850MB)
FROM golang:1.12.1 AS builder
RUN go version

COPY . /go/src/shorturls/
WORKDIR /go/src/shorturls/
RUN set -x && \
    go get github.com/golang/dep/cmd/dep && \
    dep ensure -v

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o app .

# Stage 2 (to create a downsized "container executable", ~7MB)

# If you need SSL certificates for HTTPS, replace `FROM SCRATCH` with:
#
#   FROM alpine:3.7
#   RUN apk --no-cache add ca-certificates
#
FROM scratch
WORKDIR /root/
COPY --from=builder /go/src/shorturls/app .
COPY --from=builder /go/src/shorturls/config.* .
COPY --from=builder /go/src/shorturls/public ./public

EXPOSE 1323
ENTRYPOINT ["./app"]