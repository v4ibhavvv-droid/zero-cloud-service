# AWS Emulator (aws/aws-emulator) — official Docker path
# Source: https://docs.aws.amazon.com/emulator/latest/userguide/getting-started-docker.html
# Multi-arch: BuildKit TARGETARCH dete hai — Mac (arm64) aur CI (amd64) dono pe chalta hai.
# NOTE: Rust source se build NAHI karte (100GB) — official Linux RPM install hota hai.
FROM public.ecr.aws/amazonlinux/amazonlinux:2023-minimal

ARG TARGETARCH

RUN command -v curl >/dev/null 2>&1 || dnf -y -q install curl \
    && case "${TARGETARCH:-arm64}" in \
         arm64) RPM=aws-emulator-aarch64 ;; \
         *)     RPM=aws-emulator-x86_64 ;; \
       esac \
    && curl -fsSL "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/latest/${RPM}.rpm" -o /tmp/aws-emulator.rpm \
    && rpm -i /tmp/aws-emulator.rpm && rm -f /tmp/aws-emulator.rpm \
    && mkdir -p /home/emulator && chown 1000 /home/emulator

USER 1000
ENV HOME=/home/emulator
EXPOSE 9297
ENTRYPOINT ["aws-emulator", "-b", "0.0.0.0"]
