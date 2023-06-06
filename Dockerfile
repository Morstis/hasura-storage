#From which image we want to build. This is basically our environment.
FROM golang:1.19-alpine as builder

# install vips deps and build tools
RUN apk update
RUN apk add vips-dev automake build-base

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . . 


#build our binary at root location. Binary name will be main. We are using go modules so gpath env variable should be empty.
RUN go build \
    -mod=vendor \
    -o hasura-storage-bin \
    -trimpath \
    main.go


FROM alpine
WORKDIR /app
RUN apk update
RUN apk add vips
COPY --from=builder /app/hasura-storage-bin /app/main

ENTRYPOINT [ "/app/main" ]
