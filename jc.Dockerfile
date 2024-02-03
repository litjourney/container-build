FROM golang:1.21.0-bullseye AS builder

ARG JUICITY_VERSION

RUN  set -ex \
    && apt-get update \
    && apt-get install -y git make

WORKDIR /build/

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN make GOFLAGS="-trimpath -modcacherw" CGO_ENABLED=0 VERSION=${JUICITY_VERSION} all

FROM debian:bullseye-slim

RUN set -ex \
    && mkdir -p /etc/juicity

COPY --from=builder /build/juicity-server /usr/local/bin/juicity-server
COPY --from=builder /build/juicity-client /usr/local/bin/juicity-client
COPY --from=builder /build/install/example-*.json /etc/juicity/

CMD [ "juicity-server" ]
