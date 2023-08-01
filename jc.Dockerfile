FROM golang:1.20-bullseye AS builder

RUN  set -ex \
    && apt-get update \
    && apt-get install -y git make

WORKDIR /build/

COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN git submodule update --init --recursive
RUN make GOFLAGS="-trimpath -modcacherw" CGO_ENABLED=0

FROM debian:bullseye-slim

RUN set -ex \
    && mkdir -p /etc/juicity
    
COPY --from=builder /build/juicity-server /usr/local/bin/juicity-server
COPY --from=builder /build/juicity-client /usr/local/bin/juicity-client
COPY --from=builder /build/install/example-*.json /etc/juicity/

CMD [ "juicity-server" ]