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
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$XDG_DATA_HOME"

[ -z "$1" ] && exit 1
ROM_PATH="$1"
ROM_DIR="$(dirname "$ROM_PATH")"
ROM_NAME="$(basename "$ROM_PATH")"
TEMP_DATA_DIR="$SDCARD_PATH/.ports_temp"
PORTS_DIR="$ROM_DIR/.ports"

export HM_TOOLS_DIR="$PAK_DIR"
export HM_PORTS_DIR="$TEMP_DATA_DIR/ports"
export HM_SCRIPTS_DIR="$TEMP_DATA_DIR/ports"

# shellcheck disable=SC2317
cleanup() {
    rm -f /tmp/power_control_dummy_pid
    killall minui-presenter >/dev/null 2>&1 || true

    if [ -f "$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt" ]; then
        cat "$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt" \
            >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        rm -f "$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt"
    fi
    if [ -f "$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt" ]; then
        cat "$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt" \
            >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        rm -f "$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt"
    fi
    if [ -f "$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt" ]; then
        cat "$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt" \
            >/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        rm -f "$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt"
    fi

    lsof +f -- "$TEMP_DATA_DIR/ports" | awk 'NR>1 {print $2}' | xargs -r kill -9 2>/dev/null || true
    if umount "$TEMP_DATA_DIR/ports"; then
        rm -rf "$TEMP_DATA_DIR"
    fi
}

show_message() (
    message="$1"
    seconds="$2"

    if [ -z "$seconds" ]; then
        seconds="forever"
    fi

    killall minui-presenter >/dev/null 2>&1 || true
    echo "$message" 1>&2
    if [ "$seconds" = "forever" ]; then
        minui-presenter --disable-auto-sleep --message "$message" --timeout -1 &
    else
        minui-presenter --disable-auto-sleep --message "$message" --timeout "$seconds"
    fi
)

create_busybox_wrappers() {
    bin_dir="$PAK_DIR/bin"
    echo "Creating busybox wrappers in $bin_dir"
    if [ ! -x "$bin_dir/busybox" ]; then
        echo "Error: $bin_dir/busybox not found or not executable"
        return 1
    fi

    for cmd in $("$bin_dir/busybox" --list); do
        if [ "$cmd" = "sh" ]; then
            continue
        fi

        if [ ! -e "$bin_dir/$cmd" ] || grep -q 'exec .*/busybox .*\$@' "$bin_dir/$cmd"; then
            cat > "$bin_dir/$cmd" <<EOF
#!/bin/sh
exec $PAK_DIR/bin/busybox $cmd "\$@"
EOF
            chmod +x "$bin_dir/$cmd"
        fi
    done
}

copy_artwork() {
    if [ -f "$USERDATA_PATH/PORTS-portmaster/no-artwork" ]; then
        echo "Artwork disabled."
        find "$ROM_DIR/.media" -name '*.png' -type f -delete
        return
    fi

    for dir in "$PORTS_DIR"/*/; do
        [ -d "$dir" ] || continue
        port_json="$dir/port.json"
        [ -f "$port_json" ] || continue
        artwork_file="$dir/cover.png"
        if [ ! -f "$artwork_file" ]; then
            screenshot_candidate=$(find "$dir" -maxdepth 1 -type f -name 'screenshot*' | head -n1)
            if [ -n "$screenshot_candidate" ]; then
                artwork_file="$screenshot_candidate"
            else
                continue
            fi
        fi

        echo "Processing folder $dir for artwork"
        shell_script=$(jq -r '.items[] | select(test("\\.sh$"))' "$port_json" | head -n1)
        if [ -z "$shell_script" ] || [ "$shell_script" = "null" ]; then
            echo "No shell script found in $port_json"
            continue
        fi

        mkdir -p "$ROM_DIR/.media"
        dest_file="$ROM_DIR/.media/${shell_script%.*}.png"
        if [ ! -f "$dest_file" ]; then
            echo "Copying $dir/cover.png to $ROM_DIR/.media/$shell_script.png"
            cp "$artwork_file" "$dest_file"
        fi
    done
}

unpack_tar() {
    tar_file="$1"
    dest_dir="$2"
    echo "Unpacking $1 to $2"
    if [ ! -f "$tar_file" ]; then
        echo "$tar_file not found"
        return
    fi
    if tar -zxf "$tar_file" -C "$dest_dir"; then
        rm -f "$tar_file"
    else
        echo "Failed to unpack $tar_file"
        return 1
    fi
}

unzip_pylibs() {
    pylibs_file="$1"
    echo "Unzipping $1"
    if [ ! -f "$pylibs_file" ]; then
        echo "$pylibs_file not found"
        return
    fi
    if unzip -oq "$pylibs_file" -d "$(dirname "$pylibs_file")"; then
        rm -f "$pylibs_file"
    else
        echo "Failed to unpack $pylibs_file"
        return 1
    fi
}

update_file_shebang() {
    file="$1"
    echo "Updating shebang for $file"
    sed -i '1s|.*|#!/usr/bin/env bash|' "$file"
}

update_shebangs_from_list() {
    filter_files_with_string "#!/bin/bash" | while IFS= read -r file || [ -n "$file" ]; do
        [ -z "$file" ] && continue
        update_file_shebang "$file"
    done
}

filter_files_with_string() {
    string="$1"
    while IFS= read -r file || [ -n "$file" ]; do
        [ -z "$file" ] && continue
        # -q is quiet (no output), returns true if pattern is found.
        if grep -q "$string" "$file"; then
            echo "$file"
        fi
    done
}

replace_string_in_files() {
    old_string="$1"
    new_string="$2"

    while IFS= read -r file || [ -n "$file" ]; do
        [ -z "$file" ] && continue
        echo "Replacing '$old_string' with '$new_string' in $file"
        sed -i "s|$old_string|$new_string|g" "$file"
    done
}

update_portmaster_path_from_list() {
    replace_string_in_files "/roms/ports/PortMaster" "$EMU_DIR"
}


find_shell_scripts() {
    search_path="$1"
    find "$search_path" -type f -executable \
        \( -name "*.sh" -o -name "*.src" -o -name "*.txt" -o ! -name "*.*" \) \
        | while read -r file; do
        if head -n 1 "$file" | grep -qE '^#!.*(sh|bash)'; then
            echo "$file"
        fi
    done
}

modify_squashfs_scripts() {
    squashfs_file="$1"
    tmpdir=$(mktemp -d) || return 1

    echo "Modifying scripts in $squashfs_file"
    if ! unsquashfs -no-progress -d "$tmpdir" "$squashfs_file"; then
        echo "Failed to extract squashfs"
        rm -rf "$tmpdir"
        return 1
    fi

    shell_scripts=$(find_shell_scripts "$tmpdir")
    if ! echo "$shell_scripts" | grep -q .; then
        echo "No shell scripts found in $squashfs_file"
        rm -rf "$tmpdir"
        return 0
    fi
    echo "Updating shebangs for $squashfs_file..."
    echo "$shell_scripts" | update_shebangs_from_list
    echo "Updating PortMaster path for $squashfs_file..."
    echo "$shell_scripts" | filter_files_with_string "/roms/ports/PortMaster" | update_portmaster_path_from_list

    echo "Rebuilding squashfs file $squashfs_file"
    rm -f "$squashfs_file"
    if ! mksquashfs "$tmpdir" "$squashfs_file" -noappend -comp xz -no-progress; then
        echo "Failed to rebuild squashfs"
        rm -rf "$tmpdir"
        return 1
    fi

    rm -rf "$tmpdir"
}

process_squashfs_files() {
    search_dir="$1"

    echo "Processing SquashFS files in $search_dir"
    find "$search_dir" -type f -name "*.squashfs" | while IFS= read -r squashfs_file; do
        processed_marker="${squashfs_file}.processed"

        if [ -f "$processed_marker" ]; then
            if [ "$squashfs_file" -ot "$processed_marker" ]; then
                echo "Skipping $squashfs_file; already processed"
                continue
            fi
        fi

        echo "Processing $squashfs_file"
        if modify_squashfs_scripts "$squashfs_file"; then
            sleep 2
            touch "$processed_marker"
        else
            echo "Failed to process $squashfs_file"
        fi
    done
}

replace_progressor_binaries() {
    search_path="$1"
    progressor_src="$PAK_DIR/files/progressor"
    presenter_src="$PAK_DIR/files/minui-presenter"

    if [ ! -f "$progressor_src" ]; then
        echo "Source progressor binary not found at $progressor_src"
        return 1
    fi

    if [ ! -f "$presenter_src" ]; then
        echo "Source minui-presenter binary not found at $presenter_src"
        return 1
    fi

    find "$search_path" -type f -name "progressor" | while read -r target; do
        echo "Replacing $target with $progressor_src"
        cp -f "$progressor_src" "$target"
        chmod +x "$target"
        presenter_target="$(dirname "$target")/minui-presenter"
        if [ ! -f "$presenter_target" ]; then
            echo "Copying $presenter_src to $presenter_target"
            cp -f "$presenter_src" "$presenter_target"
            chmod +x "$presenter_target"
        fi
    done
}

main() {
    echo "1" >/tmp/stay_awake
    trap "cleanup" EXIT INT TERM HUP QUIT

    if [ "$PLATFORM" = "tg3040" ] && [ -z "$DEVICE" ]; then
        export PLATFORM="tg5040"
    fi

    if ! command -v minui-presenter >/dev/null 2>&1; then
        show_message "Minui-presenter not found." 2
        exit 1
    fi

    if ! command -v minui-power-control >/dev/null 2>&1; then
        show_message "Minui-power-control not found." 2
        exit 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        show_message "Jq not found." 2
        exit 1
    fi

    chmod +x "$PAK_DIR/bin/minui-presenter"
    chmod +x "$PAK_DIR/bin/minui-power-control"
    chmod +x "$PAK_DIR/bin/jq"

    allowed_platforms="tg5040"
    if ! echo "$allowed_platforms" | grep -q "$PLATFORM"; then
        echo "$PLATFORM is not a supported platform."
        exit 1
    fi

    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor \
        >"$USERDATA_PATH/PORTS-portmaster/cpu_governor.txt"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq \
        >"$USERDATA_PATH/PORTS-portmaster/cpu_min_freq.txt"
    cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq \
        >"$USERDATA_PATH/PORTS-portmaster/cpu_max_freq.txt"
    echo ondemand >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 1608000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo 1800000 >/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq

    echo "Starting PortMaster with ROM: $ROM_PATH"
    show_message "Starting, please wait..." forever

    if [ -f "$PAK_DIR/files/bin.tar.gz" ] || [ -f "$PAK_DIR/files/lib.tar.gz" ]; then
        show_message "Unpacking files, please wait..." forever
        unpack_tar "$PAK_DIR/files/bin.tar.gz" "$PAK_DIR/bin"
        unpack_tar "$PAK_DIR/files/lib.tar.gz" "$PAK_DIR/lib"
    fi

    if [ ! -f "$PAK_DIR/bin/busybox_wrappers.processed" ]; then
        create_busybox_wrappers
        touch "$PAK_DIR/bin/busybox_wrappers.processed"
    fi

    if [ ! -f "$EMU_DIR/config/config.json" ]; then
        echo "Copying config.json to $EMU_DIR/config"
        mkdir -p "$EMU_DIR/config"
        cp -f "$PAK_DIR/files/config.json" "$EMU_DIR/config/config.json"
    fi

    mkdir -p "$ROM_DIR/.ports"
    if ! mount | grep -q "on $TEMP_DATA_DIR/ports type"; then
        echo "Mounting $ROM_DIR/.ports to $TEMP_DATA_DIR/ports"
        mkdir -p "$TEMP_DATA_DIR/ports"
        if ! mount -o bind "$ROM_DIR/.ports" "$TEMP_DATA_DIR/ports"; then
            echo "Failed to mount $ROM_DIR/.ports to $TEMP_DATA_DIR/ports"
            exit 1
        fi
    else
        echo "Mount point $TEMP_DATA_DIR/ports already exists, skipping mount."
    fi

    unzip_pylibs "$EMU_DIR/pylibs.zip"
    python3 "$PAK_DIR/src/replace_string_in_file.py" \
        "$EMU_DIR/pylibs/harbourmaster/platform.py" "/mnt/SDCARD/Roms/PORTS" "$ROM_DIR"
    python3 "$PAK_DIR/src/disable_python_function.py" \
        "$EMU_DIR/pylibs/harbourmaster/platform.py" portmaster_install

    cp -f "$PAK_DIR/files/control.txt" "$EMU_DIR/control.txt"
    python3 "$PAK_DIR/src/replace_string_in_file.py" "$EMU_DIR/control.txt" \
        "\$EMU_DIR" "$EMU_DIR"
    python3 "$PAK_DIR/src/replace_string_in_file.py" "$EMU_DIR/control.txt" \
        "\$TEMP_DATA_DIR" "${TEMP_DATA_DIR#/}"

    minui-power-control &

    if echo "$ROM_NAME" | grep -qi "portmaster"; then
        echo "Starting PortMaster GUI"
        show_message "Starting PortMaster..." 10 &
        rm -f "$EMU_DIR/.pugwash-reboot"

        while true; do
            pugwash --debug

            if [ ! -f "$EMU_DIR/.pugwash-reboot" ]; then
                break;
            fi

            rm -f "$EMU_DIR/.pugwash-reboot"
        done

        show_message "Applying changes, please wait..." &
        shell_scripts=$(find_shell_scripts "$ROM_DIR")
        echo "Updating shebangs for launch scripts..."
        echo "$shell_scripts" | update_shebangs_from_list
        echo "Updating PortMaster path for launch scripts..."
        echo "$shell_scripts" | filter_files_with_string "/roms/ports/PortMaster" | update_portmaster_path_from_list
        replace_progressor_binaries "$PORTS_DIR"
        copy_artwork
        process_squashfs_files "$EMU_DIR/libs"
    else
        echo "Starting PortMaster with port: $ROM_PATH"
        show_message "Starting ${ROM_NAME%.*}..." 120 &
        "$PAK_DIR/bin/busybox" bash "$ROM_PATH"
    fi
}

main "$@"
