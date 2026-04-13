FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go mod init app-2 && go build -o app-2 main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/app-2 .
EXPOSE 8080
CMD ["./app-2"]
