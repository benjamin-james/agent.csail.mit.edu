#!/usr/bin/env bash
# Bring up the tunnel tofu needs to reach libvirt on kellislab1.
# Forwards a local TCP port to the libvirt unix socket on the hypervisor
# (via the configured MFA proxyjump), for use as:
#   TF_VAR_libvirt_uri='qemu+tcp://localhost:16509/system'
set -euo pipefail

PORT="${1:-16509}"
TARGET=kellislab1.csail.mit.edu
SOCKET=/var/run/libvirt/libvirt-sock

# kill any stale forward on this port
pkill -f "[-]L ${PORT}:${SOCKET}" 2>/dev/null || true
sleep 1

# refuse to run if something else already owns the port
if nc -z localhost "$PORT" 2>/dev/null; then
	echo "port ${PORT} is already in use — pick another: $0 <port>" >&2
	ss -tlnp "sport = :${PORT}" 2>/dev/null || true
	exit 1
fi

echo "Tunnel up (Ctrl-C to tear down): localhost:${PORT} -> ${TARGET}${SOCKET}"
echo "In another shell: TF_VAR_libvirt_uri='qemu+tcp://localhost:${PORT}/system' tofu plan"
exec ssh -N -o ExitOnForwardFailure=yes -L "${PORT}:${SOCKET}" "$TARGET"
