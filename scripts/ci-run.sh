#!/usr/bin/env bash
# Runs a CI command. On failure, re-emits its error lines as GitHub annotations,
# so failures are readable from the checks API without downloading the raw log.
set -uo pipefail

log="$(mktemp)"
"$@" 2>&1 | tee "$log"
status=${PIPESTATUS[0]}
if [ "$status" -ne 0 ]; then
    grep -E "error:|warning:|fatal:|failed|Failed|✘" "$log" | head -n 40 | while IFS= read -r line; do
        echo "::error::${line}"
    done
fi
exit "$status"
