#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Disable Push to Talk
# @raycast.mode compact
# @raycast.packageName Microphone
# @raycast.description Stop push-to-talk and restore the microphone, even when Hammerspoon is closed.
set -euo pipefail
hs_cli="/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs"
script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
helper="$script_dir/.helpers/restore-microphone"
source_file="$helper.swift"
if [[ ! -x "$helper" || "$source_file" -nt "$helper" ]]; then
  build_file="$(/usr/bin/mktemp "$script_dir/.helpers/restore-microphone.XXXXXX")"
  trap '/bin/rm -f "$build_file"' EXIT
  /usr/bin/xcrun swiftc -warnings-as-errors "$source_file" -o "$build_file"
  /bin/mv -f "$build_file" "$helper"
  trap - EXIT
fi
if /usr/bin/pgrep -x Hammerspoon >/dev/null; then
  "$hs_cli" -q -c 'if rightCmdWatcher then rightCmdWatcher:stop() end; if pushToTalkTimer then pushToTalkTimer:stop() end; hs.shutdownCallback = nil' >/dev/null
fi
exec "$helper"
