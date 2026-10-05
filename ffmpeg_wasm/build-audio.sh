#!/usr/bin/env bash
# Compila el core de ffmpeg.wasm solo-audio con Docker.
#
# Uso (desde la raíz del repo ffmpegwasm/ffmpeg.wasm, con Dockerfile.audio al lado):
#   ./build-audio.sh <carpeta-salida> [--build-arg CLAVE=valor ...]
#
# Ejemplos:
#   ./build-audio.sh out-base
#   ./build-audio.sh out-nosimd --build-arg EXTRA_CFLAGS="-O3"
#   ./build-audio.sh out-opus152 --build-arg OPUS_REPO=https://github.com/xiph/opus.git --build-arg OPUS_BRANCH=v1.5.2
#   ./build-audio.sh out-emsdk --build-arg EMSDK_VERSION=3.1.56
#
# Resultado: <carpeta-salida>/dist/esm/ffmpeg-core.js y ffmpeg-core.wasm

set -euo pipefail

if [ $# -lt 1 ]; then
  sed -n '2,15p' "$0"
  exit 1
fi

OUT="$1"; shift

for f in Dockerfile.audio build/ffmpeg.sh src/fftools src/bind; do
  [ -e "$f" ] || { echo "Falta '$f'. Ejecuta el script desde la raíz del repo ffmpeg.wasm con Dockerfile.audio copiado ahí." >&2; exit 1; }
done

docker info >/dev/null 2>&1 || { echo "Docker no está en marcha." >&2; exit 1; }

mkdir -p "$OUT"
docker buildx build \
  -f Dockerfile.audio \
  --progress=plain \
  -o "$OUT" \
  "$@" \
  .

echo
echo "Listo:"
ls -lh "$OUT"/dist/esm/ffmpeg-core.*
