#!/bin/sh
set -eu

LT_ROOT="/opt/languagetool"
LT_DIR="${LT_DIR:-}"

if [ -z "$LT_DIR" ]; then
  LT_DIR="$(find "$LT_ROOT" -mindepth 1 -maxdepth 1 -type d -name 'LanguageTool-*' | sort | tail -n 1)"
fi

if [ -z "$LT_DIR" ] || [ ! -f "$LT_DIR/languagetool-server.jar" ]; then
  echo "LanguageTool nao encontrado em $LT_ROOT" >&2
  exit 1
fi

PORT="${LT_PORT:-8081}"
JAVA_XMS="${LT_JAVA_XMS:-256m}"
JAVA_XMX="${LT_JAVA_XMX:-512m}"

cd "$LT_DIR"

set -- java "-Xms${JAVA_XMS}" "-Xmx${JAVA_XMX}"

if [ -n "${LT_JAVA_OPTS:-}" ]; then
  # shellcheck disable=SC2086
  set -- "$@" ${LT_JAVA_OPTS}
fi

set -- "$@" -cp languagetool-server.jar org.languagetool.server.HTTPServer --port "$PORT"

if [ "${LT_PUBLIC:-true}" = "true" ]; then
  set -- "$@" --public
fi

case "${LT_ALLOW_ORIGIN:-*}" in
  "")
    ;;
  "*")
    set -- "$@" --allow-origin
    ;;
  *)
    set -- "$@" --allow-origin "${LT_ALLOW_ORIGIN}"
    ;;
esac

if [ -n "${LT_CONFIG_FILE:-}" ]; then
  set -- "$@" --config "${LT_CONFIG_FILE}"
fi

if [ "${LT_VERBOSE:-false}" = "true" ]; then
  set -- "$@" --verbose
fi

if [ -n "${LT_EXTRA_ARGS:-}" ]; then
  # shellcheck disable=SC2086
  set -- "$@" ${LT_EXTRA_ARGS}
fi

echo "Iniciando LanguageTool em ${PORT} usando ${LT_DIR}"
exec "$@"
