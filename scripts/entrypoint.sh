#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d /workspace/.git ]]; then
  echo "WARNING: /workspace is not a Git checkout. Mount a separate HA repository checkout with HA_REPO." >&2
fi

# Refuse the most obvious accidental live Home Assistant mount.
if [[ -e /workspace/.HA_VERSION && -d /workspace/.storage ]]; then
  echo "ERROR: workspace looks like a live Home Assistant /config directory (.HA_VERSION + .storage found)." >&2
  echo "Use a separate Git checkout instead." >&2
  exit 64
fi

git config --global --add safe.directory /workspace 2>/dev/null || true
git config --global user.name "${GIT_AUTHOR_NAME:-Pi HA Agent}"
git config --global user.email "${GIT_AUTHOR_EMAIL:-pi-ha-agent@localhost}"

exec "$@"
