#!/bin/bash
set -euo pipefail

: "${GITHUB_URL:?set to https://github.com/OWNER or https://github.com/OWNER/REPO}"

# A volume mounted at /home/runner covers the image's runner install, so seed it.
[ -f ./config.sh ] || cp -a /opt/actions-runner/* .

# Registration survives restarts when /home/runner is a volume; only configure once.
if [ ! -f .runner ]; then
  : "${RUNNER_TOKEN:?runner registration token, from Settings > Actions > Runners > New runner (expires in 1 hour)}"

  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$RUNNER_TOKEN" \
    --name "${RUNNER_NAME:-$(hostname)}" \
    --runnergroup "${RUNNER_GROUP:-Default}" \
    --labels "${RUNNER_LABELS:-docker}" \
    --work _work \
    --unattended \
    --replace
fi

exec ./run.sh
