FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go mod init app-1 && go build -o app-1 main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/app-1 .
EXPOSE 8080
CMD ["./app-1"]
