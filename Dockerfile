FROM registry.access.redhat.com/ubi8/go-toolset as builder
COPY main.go .
RUN go build -o ./app .

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
CMD ["./app"]
COPY --from=builder /opt/app-root/src/app .
