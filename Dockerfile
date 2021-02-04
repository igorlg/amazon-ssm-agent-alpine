FROM alpine

WORKDIR /data

RUN apk update && apk add make
