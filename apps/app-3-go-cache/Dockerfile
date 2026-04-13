FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go mod init app-3 && go build -o app-3 main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/app-3 .
EXPOSE 8080
CMD ["./app-3"]
