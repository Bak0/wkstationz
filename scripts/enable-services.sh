#!/bin/bash
# Enable system services.
# Tolerant by design: a missing or already-active unit must never abort the
# installation. Units are detected at runtime because the audio stack differs
# between PipeWire and PulseAudio installs.

set -u

warn() { printf '  ! %s\n' "$*"; }
ok()   { printf '  + %s\n' "$*"; }

# Enable a system unit if it exists. Returns non-zero only on real failure.
enable_system_unit() {
    local unit="$1"
    if ! systemctl list-unit-files "$unit" >/dev/null 2>&1 \
       || ! systemctl cat "$unit" >/dev/null 2>&1; then
        warn "system unit '$unit' not available, skipping"
        return 0
    fi
    if systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        ok "system unit '$unit' already enabled"
    elif sudo systemctl enable "$unit" >/dev/null 2>&1; then
        ok "enabled system unit '$unit'"
    else
        warn "could not enable system unit '$unit'"
    fi
    return 0
}

# Enable and start a user unit if it exists.
enable_user_unit() {
    local unit="$1"
    if ! systemctl --user list-unit-files "$unit" >/dev/null 2>&1 \
       || ! systemctl --user cat "$unit" >/dev/null 2>&1; then
        warn "user unit '$unit' not available, skipping"
        return 0
    fi
    if systemctl --user is-enabled --quiet "$unit" 2>/dev/null; then
        ok "user unit '$unit' already enabled"
    elif systemctl --user enable "$unit" >/dev/null 2>&1; then
        ok "enabled user unit '$unit'"
    else
        warn "could not enable user unit '$unit'"
    fi
    if systemctl --user is-active --quiet "$unit" 2>/dev/null; then
        ok "user unit '$unit' already running"
    elif systemctl --user start "$unit" >/dev/null 2>&1; then
        ok "started user unit '$unit'"
    else
        warn "could not start user unit '$unit'"
    fi
    return 0
}

# Audio: enable whichever stack is actually installed.
enable_audio() {
    local handled=0

    if systemctl --user cat pipewire-pulse.service >/dev/null 2>&1 \
       || systemctl --user cat pipewire-pulse.socket >/dev/null 2>&1; then
        ok "detected PipeWire audio stack"
        enable_user_unit pipewire-pulse.service
        enable_user_unit pipewire.socket
        enable_user_unit pipewire.service
        enable_user_unit wireplumber.service
        handled=1
    fi

    if systemctl --user cat pulseaudio.service >/dev/null 2>&1 \
       || systemctl --user cat pulseaudio.socket >/dev/null 2>&1; then
        ok "detected PulseAudio audio stack"
        enable_user_unit pulseaudio.service
        enable_user_unit pulseaudio.socket
        handled=1
    fi

    if [ "$handled" -eq 0 ]; then
        warn "no supported audio stack detected; audio left unconfigured"
    fi
}

echo "Enabling SDDM (display manager)..."
enable_system_unit sddm.service

echo "Enabling audio..."
enable_audio

echo "Enabling swaync (notification daemon)..."
enable_user_unit swaync.service

echo "Service configuration finished."