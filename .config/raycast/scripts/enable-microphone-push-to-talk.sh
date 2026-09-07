#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Enable Push to Talk
# @raycast.mode compact
# @raycast.packageName Microphone
# @raycast.description Enable Right Command push-to-talk again.
set -euo pipefail
hs_cli="/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs"
if /usr/bin/pgrep -x Hammerspoon >/dev/null; then
  "$hs_cli" -q -c 'hs.timer.doAfter(0.2, hs.reload)' >/dev/null
else
  /usr/bin/open -a Hammerspoon
fi
for attempt in {1..20}; do
  /bin/sleep 0.25
  if "$hs_cli" -q -c 'assert(hs.accessibilityState() and rightCmdWatcher and rightCmdWatcher:isEnabled() and pushToTalkTimer and pushToTalkTimer:running(), "Push-to-talk is not ready")' >/dev/null 2>&1; then
    echo 'Push-to-talk enabled. Hold Right Command to speak.'
    exit 0
  fi
done
echo 'Push-to-talk could not start. Check Hammerspoon Accessibility permission.' >&2
exit 1
