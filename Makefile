PAK_NAME := $(shell jq -r .name pak.json)
PAK_DIR := "Emus/tg5040"

MINUI_BASH_VERSION := 1.0.0
MINUI_POWER_CONTROL_VERSION := 3.0.0
PORTMASTER_VERSION := 2026.07.28-1212
MINUI_PRESENTER_VERSION := 0.13.0
JQ_VERSION := 1.8.2
SQUASHFS_VERSION := 4.7.5
7ZIP_VERSION := 2602

clean:
	find bin -type f ! -name '.gitkeep' -delete
	find lib -type f ! -name '.gitkeep' -delete
	find lib -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
	rm -rf PortMaster
	rm -f files/minui-presenter

bump-version:
	jq '.version = "$(RELEASE_VERSION)"' pak.json > pak.json.tmp
	mv pak.json.tmp pak.json

build: PortMaster bin/minui-power-control bin/minui-presenter files/minui-presenter bin/jq bin/mksquashfs bin/unsquashfs bin/bash bin/7zzs.aarch64
	@echo "Build complete"

PortMaster:
	curl -f -o trimui.portmaster.zip -sSL "https://github.com/PortsMaster/PortMaster-GUI/releases/download/$(PORTMASTER_VERSION)/trimui.portmaster.zip"
	unzip -o trimui.portmaster.zip -d trimui.portmaster
	mv trimui.portmaster/Apps/PortMaster/PortMaster PortMaster
	rm -rf trimui.portmaster
	rm -f trimui.portmaster.zip

bin/minui-power-control:
	mkdir -p bin
	curl -f -o bin/minui-power-control -sSL "https://github.com/ben16w/minui-power-control/releases/download/$(MINUI_POWER_CONTROL_VERSION)/minui-power-control"
	chmod +x bin/minui-power-control

bin/minui-presenter:
	mkdir -p bin
	curl -f -o bin/minui-presenter -sSL "https://github.com/josegonzalez/minui-presenter/releases/download/$(MINUI_PRESENTER_VERSION)/minui-presenter-tg5040"
	chmod +x bin/minui-presenter

files/minui-presenter:
	mkdir -p files
	curl -f -o files/minui-presenter -sSL "https://github.com/josegonzalez/minui-presenter/releases/download/$(MINUI_PRESENTER_VERSION)/minui-presenter-tg5040"
	chmod +x files/minui-presenter

bin/jq:
	mkdir -p bin
	curl -f -o bin/jq -sSL "https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-arm64"
	chmod +x bin/jq
	curl -sSL -o bin/jq.LICENSE "https://raw.githubusercontent.com/jqlang/jq/refs/tags/jq-$(JQ_VERSION)/COPYING"

bin/mksquashfs:
	mkdir -p bin
	curl -f -o bin/mksquashfs -sSL "https://github.com/VHSgunzo/squashfs-tools-static/releases/download/v$(SQUASHFS_VERSION)/mksquashfs-aarch64"
	chmod +x bin/mksquashfs
	curl -sSL -o bin/mksquashfs.LICENSE "https://github.com/VHSgunzo/squashfs-tools-static/raw/refs/heads/main/LICENSE"

bin/unsquashfs:
	mkdir -p bin
	curl -f -o bin/unsquashfs -sSL "https://github.com/VHSgunzo/squashfs-tools-static/releases/download/v$(SQUASHFS_VERSION)/unsquashfs-aarch64"
	chmod +x bin/unsquashfs
	curl -sSL -o bin/unsquashfs.LICENSE "https://github.com/VHSgunzo/squashfs-tools-static/raw/refs/heads/main/LICENSE"

bin/bash:
	mkdir -p bin
	curl -f -o bin/bash -sSL "https://github.com/pobega/minui-bash/releases/download/$(MINUI_BASH_VERSION)/minui-bash-aarch64"
	chmod +x bin/bash
	curl -sSL -o bin/bash.LICENSE "https://github.com/pobega/minui-bash/raw/refs/heads/main/bash.LICENSE"

bin/7zzs.aarch64:
	mkdir -p bin
	curl -f -o /tmp/7z$(7ZIP_VERSION)-linux-arm64.tar.xz -sSL "https://github.com/ip7z/7zip/releases/download/$(shell echo $(7ZIP_VERSION) | sed 's/../&./')/7z$(7ZIP_VERSION)-linux-arm64.tar.xz"
	tar -C /tmp -xf /tmp/7z$(7ZIP_VERSION)-linux-arm64.tar.xz
	mv /tmp/7zzs bin/7zzs.aarch64
	chmod +x bin/7zzs.aarch64
	rm -f /tmp/7z$(7ZIP_VERSION)-linux-arm64.tar.xz
	curl -sSL -o bin/7zzs.aarch64.LICENSE "https://www.7-zip.org/license.txt"

release: build release-pak release-pakz
	@echo "Release $(RELEASE_VERSION) complete"

release-pak: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist

release-pakz: build
	mkdir -p dist
	rm -f dist/$(PAK_NAME).pakz
	rm -rf /tmp/pakz-build
	mkdir -p "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak"
	git archive --format=tar HEAD | tar -x -C "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak"
	while IFS= read -r file; do cp --parents -r "$$file" "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/"; done < .gitarchiveinclude
	mkdir -p "/tmp/pakz-build/Roms/Ports ($(PAK_NAME))"
	touch "/tmp/pakz-build/Roms/Ports ($(PAK_NAME))/0) Portmaster.sh"
	mkdir -p "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/lib"
	tar -xf files/lib.tar.gz -C "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/lib"
	rm /tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/files/lib.tar.gz
	mkdir -p "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/bin"
	tar -xf files/bin.tar.gz -C "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/bin"
	rm /tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/files/bin.tar.gz
	unzip -oq "PortMaster/pylibs.zip" -d "/tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/PortMaster"
	rm -f /tmp/pakz-build/$(PAK_DIR)/$(PAK_NAME).pak/PortMaster/pylibs.zip
	cd /tmp/pakz-build && zip -r "$(PWD)/dist/$(PAK_NAME).pakz" .
	rm -rf /tmp/pakz-build
