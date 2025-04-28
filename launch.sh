#!/bin/sh
PAK_DIR="$(dirname "$0")"
PAK_NAME="$(basename "$PAK_DIR")"
PAK_NAME="${PAK_NAME%.*}"
[ -f "$USERDATA_PATH/PORTS-portmaster/debug" ] && set -x

rm -f "$LOGS_PATH/$PAK_NAME.txt"
exec >>"$LOGS_PATH/$PAK_NAME.txt"
exec 2>&1

echo "$0" "$*"
cd "$PAK_DIR" || exit 1
mkdir -p "$USERDATA_PATH/PORTS-portmaster"
mkdir -p "$SHARED_USERDATA_PATH/PORTS-portmaster"

export PAK_DIR="$SDCARD_PATH/Emus/$PLATFORM/PORTS.pak"
export EMU_DIR="$SDCARD_PATH/Emus/$PLATFORM/PORTS.pak/PortMaster"

export PATH="$EMU_DIR:$PAK_DIR/bin:$PATH"
export LD_LIBRARY_PATH="$PAK_DIR/lib:/usr/trimui/lib:$LD_LIBRARY_PATH"
export SSL_CERT_FILE="$PAK_DIR/files/ca-certificates.crt"
export SDL_GAMECONTROLLERCONFIG_FILE="$EMU_DIR/gamecontrollerdb.txt"
export PYSDL2_DLL_PATH="/usr/trimui/lib"
export HOME="$SHARED_USERDATA_PATH/PORTS-portmaster"
export XDG_DATA_HOME="$PAK_DIR"

ROM_PATH="$1"
ROM_DIR="$(dirname "$ROM_PATH")"
ROM_NAME="$(basename "$ROM_PATH")"
TEMP_DATA_DIR="$SDCARD_PATH/Data"
PORTS_DIR="$ROM_DIR/.ports"

export HM_TOOLS_DIR="$PAK_DIR"
export HM_PORTS_DIR="$TEMP_DATA_DIR/ports"
export HM_SCRIPTS_DIR="$TEMP_DATA_DIR/ports"

cleanup() {
    rm -f /tmp/stay_awake

    if [ -f "$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt" ]; then
        cat "$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        rm -f "$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt"
    fi
    if [ -f "$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt" ]; then
        cat "$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        rm -f "$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt"
    fi
    if [ -f "$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt" ]; then
        cat "$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        rm -f "$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt"
    fi

    lsof +f -- "$TEMP_DATA_DIR/ports" | awk 'NR>1 {print $2}' | xargs -r kill -9 2>/dev/null || true
    if umount "$TEMP_DATA_DIR/ports"; then
        rm -rf "$TEMP_DATA_DIR"
    fi
}

copy_artwork() {
    for dir in "$PORTS_DIR"/*/; do
        [ -d "$dir" ] || continue
        port_json="$dir/port.json"
        [ -f "$port_json" ] || continue
        cover_png="$dir/cover.png"
        [ -f "$cover_png" ] || continue

        echo "Processing folder: $dir"
        shell_script=$(jq -r '.items[] | select(test("\\.sh$"))' "$port_json" | head -n1)
        if [ -z "$shell_script" ] || [ "$shell_script" = "null" ]; then
            echo "No shell script found in $port_json"
            continue
        fi

        mkdir -p "$ROM_DIR/.media"
        dest_file="$ROM_DIR/.media/${shell_script%.*}.png"
        if [ ! -f "$dest_file" ]; then
            echo "Copying $dir/cover.png to $ROM_DIR/.media/$shell_script.png"
            cp "$cover_png" "$dest_file"
        fi
    done
}

unpack_tar() {
    tar_file="$1"
    dest_dir="$2"
    if [ -f "$tar_file" ]; then
        rm -rf "${dest_dir:?}/"*
        if tar -xf "$tar_file" -C "$dest_dir" >/dev/null 2>&1; then
            rm -f "$tar_file"
        fi
    fi
}

main() {
    echo "1" >/tmp/stay_awake
    trap "cleanup" EXIT INT TERM HUP QUIT

    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor >"$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq >"$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq >"$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt"
    echo ondemand >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 1608000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1800000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

    unpack_tar "$PAK_DIR/files/bins.tar" "$PAK_DIR/bin"
    unpack_tar "$PAK_DIR/files/lib.tar" "$PAK_DIR/lib"

    if [ ! -f "$EMU_DIR/config/config.json" ]; then
        mkdir -p "$EMU_DIR/config"
        cp -f "$PAK_DIR/files/config.json" "$EMU_DIR/config/config.json"
    fi

    mkdir -p "$TEMP_DATA_DIR/ports"
    mkdir -p "$ROM_DIR/.ports"
    if ! mount | grep -q "on $TEMP_DATA_DIR/ports type"; then
        mount -o bind "$ROM_DIR/.ports" "$TEMP_DATA_DIR/ports"
    else
        echo "Mount point already exists, skipping mount."
    fi

    cp -f "$PAK_DIR/files/control.txt" "$EMU_DIR/control.txt"
    python3 "$PAK_DIR/src/replace_string_in_file.py" "$EMU_DIR/control.txt" EMU_DIR "$EMU_DIR"
    python3 "$PAK_DIR/src/replace_string_in_file.py" "$EMU_DIR/control.txt" TEMP_DATA_DIR "$TEMP_DATA_DIR"

    python3 "$PAK_DIR/src/replace_string_in_file.py" \
        "$EMU_DIR/pylibs/harbourmaster/platform.py" "/mnt/SDCARD/Roms/PORTS" "$ROM_DIR"
    python3 "$PAK_DIR/src/disable_python_function.py" \
        "$EMU_DIR/pylibs/harbourmaster/platform.py" portmaster_install

    rm -f "$EMU_DIR/.pugwash-reboot"
    if echo "$ROM_NAME" | grep -qi "portmaster"; then
        while true; do
            pugwash --debug

            if [ ! -f "$EMU_DIR/.pugwash-reboot" ]; then
                break;
            fi

            rm -f "$EMU_DIR/.pugwash-reboot"
        done
    else
        "$PAK_DIR/bin/busybox" sh "$ROM_PATH"
    fi

    copy_artwork
}

main "$@"