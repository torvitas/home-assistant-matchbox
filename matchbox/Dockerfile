FROM docker.io/alpine:3.22.0 AS scripts
ADD https://github.com/poseidon/matchbox.git#v0.11.0 /src

FROM quay.io/poseidon/matchbox:v0.11.0 as matchbox

FROM ghcr.io/hassio-addons/base:18.0.3
COPY --from=scripts /src/scripts /scripts
COPY --from=matchbox /matchbox /matchbox
EXPOSE 8080
ENTRYPOINT ["/matchbox"]
