FROM registry.access.redhat.com/ubi8/go-toolset as builder
COPY main.go .
RUN go build -o ./app .

FROM gcr.io/ifontlabs/ubi8-minimal:stable
LABEL base.image="gcr.io/ifontlabs/ubi8-minimal:stable"
CMD ["./app"]
COPY --from=builder /opt/app-root/src/app .
