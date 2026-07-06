#!/bin/bash
set -e

_APPDIR="/usr/lib/@appname@"
_RUNNAME="${_APPDIR}/@runname@"

export PATH="${_APPDIR}:${PATH}"
export LD_LIBRARY_PATH="${_APPDIR}/swiftshader:${_APPDIR}/lib:${LD_LIBRARY_PATH}"
export ELECTRON_IS_DEV=0
export ELECTRON_DISABLE_SECURITY_WARNINGS=true
export NODE_ENV=production
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

export ELECTRON_OZONE_PLATFORM_HINT=auto

_FLAGS_FILE="${XDG_CONFIG_HOME}/@appname@-flags.conf"
declare -a flags
if [[ -f "${_FLAGS_FILE}" ]]; then
    mapfile -t < "${_FLAGS_FILE}"
fi
for line in "${MAPFILE[@]}"; do
    if [[ ! "${line}" =~ ^[[:space:]]*#.* ]] && [[ -n "${line}" ]]; then
        flags+=("${line}")
    fi
done

declare -a app_args
for arg in "$@"; do
    if [[ "${arg}" == "--wayland" ]]; then
        flags+=("--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecodeLinuxGL" "--ozone-platform=wayland")
    else
        app_args+=("${arg}")
    fi
done

cd "${_APPDIR}"

if [[ "${EUID}" -ne 0 ]] || [[ "${ELECTRON_RUN_AS_NODE}" ]]; then
    exec electron@electronversion@ "${flags[@]}" "${_RUNNAME}" "${app_args[@]}" || exit $?
else
    exec electron@electronversion@ --no-sandbox "${flags[@]}" "${_RUNNAME}" "${app_args[@]}" || exit $?
fi