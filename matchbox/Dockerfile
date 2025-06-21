FROM docker.io/alpine:3.22.0 AS scripts
ADD https://github.com/poseidon/matchbox.git#v0.11.0 /src

FROM quay.io/poseidon/matchbox:v0.11.0
COPY --from=scripts /src/scripts /scripts
EXPOSE 8080
ENTRYPOINT ["/matchbox"]
