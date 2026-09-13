#!/usr/bin/env bash
set -eu

# ===== THEOS PATH (Rootless) =====
if [ -z "${THEOS:-}" ] && [ -d "/var/mobile/theos" ]; then
	export THEOS="/var/mobile/theos"
fi

# ===== fallback (optional) =====
if [ -z "${THEOS:-}" ] && [ -d "/opt/theos" ]; then
	export THEOS="/opt/theos"
fi

if [ -z "${THEOS:-}" ]; then
	echo "[-] THEOS not found"
	exit 1
fi

TWEAK_NAME="PastaCode"

echo "[*] THEOS: $THEOS"
echo "[*] Cleaning..."

make clean

echo "[*] Building .dylib..."

make FINALPACKAGE=1

DYLIB_PATH=$(find .theos/obj -type f -name "${TWEAK_NAME}.dylib" 2>/dev/null | head -n 1)

if [ -z "$DYLIB_PATH" ]; then
	echo "[-] ${TWEAK_NAME}.dylib not found"
	exit 1
fi

echo "[*] Dylib found: $DYLIB_PATH"

mkdir -p packages
cp -f "$DYLIB_PATH" "packages/${TWEAK_NAME}.dylib"

echo "[+] Done"
echo "[+] Output: packages/${TWEAK_NAME}.dylib"
