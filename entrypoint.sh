#!/bin/bash
set -euo pipefail

: "${GITHUB_URL:?set to https://github.com/OWNER or https://github.com/OWNER/REPO}"
: "${GITHUB_TOKEN:?PAT with repo or admin:org scope}"

path="${GITHUB_URL#https://github.com/}"
case "$path" in
  */*) api="repos/$path" ;;
  *)   api="orgs/$path" ;;
esac

# Registration survives restarts when /home/runner is a volume; only configure once.
if [ ! -f .runner ]; then
  reg_token=$(curl -fsSL -X POST \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/${api}/actions/runners/registration-token" | jq -er .token)

  ./config.sh \
    --url "$GITHUB_URL" \
    --token "$reg_token" \
    --name "${RUNNER_NAME:-$(hostname)}" \
    --labels "${RUNNER_LABELS:-docker}" \
    --work _work \
    --unattended \
    --replace
fi

exec ./run.sh
