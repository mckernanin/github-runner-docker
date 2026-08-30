FROM ubuntu:26.04

ARG RUNNER_VERSION=2.337.0
ARG TARGETARCH=amd64


RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl jq git sudo unzip zip libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Node on PATH must satisfy npm 11 (^20.17 || >=22.9); 24 matches actions/setup-node's default here.
ARG NODE_MAJOR=24
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && test "$(node -p 'process.versions.node.split(".")[0]')" = "$NODE_MAJOR" \
    && npm --version

RUN useradd -m -s /bin/bash runner

# Kept out of /home/runner so a volume mounted there cannot cover it; the
# entrypoint seeds the volume from here on first start.
WORKDIR /opt/actions-runner
RUN arch="$(echo "$TARGETARCH" | sed 's/^amd64$/x64/')" \
    && curl -fsSL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz" \
      | tar -xz \
    && ./bin/installdependencies.sh

WORKDIR /home/runner

COPY entrypoint.sh /entrypoint.sh

USER runner
ENTRYPOINT ["/entrypoint.sh"]
