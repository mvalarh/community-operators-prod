FROM golang:1.10-stretch
ARG DISTRO_TYPE
ENV DISTRO_TYPE ${DISTRO_TYPE}
RUN ./scripts/ci/install-deps ${DISTRO_TYPE}
