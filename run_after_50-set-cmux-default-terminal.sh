#!/usr/bin/env bash
# Set cmux as the default terminal (same as cmux menu > "Make cmux the Default Terminal").
# Registers cmux as the LaunchServices handler for shell scripts, unix executables, and ssh:// URLs.
# Idempotent: checks current handlers first, no-ops when already set.
set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || exit 0
[[ -d "/Applications/cmux.app" ]] || exit 0

python3 <<'PY' && exit 0 || true
import plistlib
from pathlib import Path

path = Path.home() / "Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
try:
    handlers = plistlib.loads(path.read_bytes()).get("LSHandlers", [])
except Exception:
    raise SystemExit(1)

cmux = [h for h in handlers if h.get("LSHandlerRoleAll") == "com.cmuxterm.app"]
have_ct = {h["LSHandlerContentType"] for h in cmux if "LSHandlerContentType" in h}
have_sch = {h["LSHandlerURLScheme"] for h in cmux if "LSHandlerURLScheme" in h}

if {"com.apple.terminal.shell-script", "public.unix-executable"} <= have_ct and {"ssh", "cmux"} <= have_sch:
    raise SystemExit(0)
raise SystemExit(1)
PY

workdir="$(mktemp -d -t cmux-default-terminal)"
trap 'rm -rf "$workdir"' EXIT

cat >"$workdir/set-default.swift" <<'SWIFT'
import AppKit
import UniformTypeIdentifiers

let appURL = URL(fileURLWithPath: "/Applications/cmux.app")
let contentTypes = ["com.apple.terminal.shell-script", "public.unix-executable"]
let schemes = ["ssh", "cmux"]
var failed = false
let group = DispatchGroup()

for id in contentTypes {
    guard let type = UTType(id) else {
        print("unknown content type: \(id)")
        failed = true
        continue
    }
    group.enter()
    NSWorkspace.shared.setDefaultApplication(at: appURL, toOpen: type) { error in
        if let error = error {
            print("content \(id): \(error.localizedDescription)")
            failed = true
        }
        group.leave()
    }
}

for scheme in schemes {
    group.enter()
    NSWorkspace.shared.setDefaultApplication(at: appURL, toOpenURLsWithScheme: scheme) { error in
        if let error = error {
            print("scheme \(scheme): \(error.localizedDescription)")
            failed = true
        }
        group.leave()
    }
}

while group.wait(timeout: .now()) == .timedOut {
    RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
}

exit(failed ? 1 : 0)
SWIFT

swiftc -o "$workdir/set-default" "$workdir/set-default.swift"
"$workdir/set-default"
