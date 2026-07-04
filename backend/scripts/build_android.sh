#!/usr/bin/env bash

set -euo pipefail

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JNI_LIBS_DIR="$BACKEND_DIR/../android/app/src/main/jniLibs"
API_LEVEL="${ANDROID_API_LEVEL:-21}" 

if [ -z "${ANDROID_NDK_HOME:-}" ]; then
  ANDROID_NDK_HOME=$(ls -d "C:/Android/ndk"/*/ 2>/dev/null | sort -V | tail -n1)
fi
if [ -z "${ANDROID_NDK_HOME:-}" ] || [ ! -d "$ANDROID_NDK_HOME" ]; then
  echo "error: could not find an Android NDK. Set ANDROID_NDK_HOME explicitly." >&2
  exit 1
fi
TOOLCHAIN_BIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/windows-x86_64/bin"

declare -A TARGETS=(
  [arm64-v8a]="arm64:aarch64-linux-android${API_LEVEL}-clang.cmd"
  [armeabi-v7a]="arm:armv7a-linux-androideabi${API_LEVEL}-clang.cmd"
  [x86_64]="amd64:x86_64-linux-android${API_LEVEL}-clang.cmd"
)

echo "Using NDK: $ANDROID_NDK_HOME (API $API_LEVEL)"

for abi in "${!TARGETS[@]}"; do
  entry="${TARGETS[$abi]}"
  goarch="${entry%%:*}"
  cc_name="${entry##*:}"
  cc_path="$TOOLCHAIN_BIN/$cc_name"

  if [ ! -f "$cc_path" ]; then
    echo "error: missing toolchain binary $cc_path" >&2
    exit 1
  fi

  out_dir="$JNI_LIBS_DIR/$abi"
  mkdir -p "$out_dir"
  echo "--- building $abi (GOARCH=$goarch) -> $out_dir/libarmforge.so ---"

  (
    cd "$BACKEND_DIR"
    CC="$cc_path" CGO_ENABLED=1 GOOS=android GOARCH="$goarch" \
      go build -buildmode=c-shared -o "$out_dir/libarmforge.so" ./cmd/mobile
  )
  
  rm -f "$out_dir/libarmforge.h"
done

echo "Done. Native libraries installed under $JNI_LIBS_DIR/{arm64-v8a,armeabi-v7a,x86_64}/libarmforge.so"
