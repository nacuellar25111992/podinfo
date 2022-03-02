FROM golang:1.17-alpine as builder

ARG REVISION

RUN mkdir -p /podinfo/

WORKDIR /podinfo

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 go build -ldflags "-s -w \
    -X github.com/nacuellar25111992/podinfo/internal/version.REVISION=${REVISION}" \
    -a -o bin/podinfo cmd/podinfo/*

FROM alpine:3.14

ARG BUILD_DATE
ARG VERSION
ARG REVISION

LABEL maintainer="nacuellar25111992"

RUN addgroup -S app \
    && adduser -S -G app app \
    && apk --no-cache add \
    ca-certificates curl netcat-openbsd

WORKDIR /home/app

COPY --from=builder /podinfo/bin/podinfo .
COPY ./ui ./ui
RUN chown -R app:app ./

USER app

CMD ["./podinfo"]
