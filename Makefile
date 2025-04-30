PAK_NAME := $(shell jq -r .name pak.json)

MINUI_POWER_CONTROL_VERSION := 1.1.0
PORTMASTER_VERSION := 2025.04.18-0611
MINUI_PRESENTER_VERSION := 0.9.0
JQ_VERSION := 1.7.1

clean:
	find bin -type f ! -name '.gitkeep' -delete
	find lib -type f ! -name '.gitkeep' -delete
	find lib -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
	rm -rf PortMaster

bump-version:
	jq '.version = "$(RELEASE_VERSION)"' pak.json > pak.json.tmp
	mv pak.json.tmp pak.json

build: bin/bin.txt lib/lib.txt PortMaster bin/minui-power-control bin/minui-presenter bin/jq
	@echo "Build complete"

bin/bin.txt:
	mkdir -p bin
	unzip -o files/bin.zip -d bin
	touch bin/bin.txt

lib/lib.txt:
	mkdir -p lib
	unzip -o files/lib.zip -d lib
	touch lib/lib.txt

PortMaster:
	curl -f -o trimui.portmaster.zip -sSL https://github.com/PortsMaster/PortMaster-GUI/releases/download/$(PORTMASTER_VERSION)/trimui.portmaster.zip
	unzip -o trimui.portmaster.zip -d trimui.portmaster
	mv trimui.portmaster/Apps/PortMaster/PortMaster PortMaster
	rm -rf trimui.portmaster
	rm -f trimui.portmaster.zip
	unzip PortMaster/pylibs.zip -d PortMaster
	rm -f PortMaster/pylibs.zip

bin/minui-power-control:
	mkdir -p bin
	curl -f -o bin/minui-power-control -sSL https://github.com/ben16w/minui-power-control/releases/download/$(MINUI_POWER_CONTROL_VERSION)/minui-power-control
	chmod +x bin/minui-power-control

bin/minui-presenter:
	mkdir -p bin
	curl -f -o bin/minui-presenter -sSL https://github.com/josegonzalez/minui-presenter/releases/download/$(MINUI_PRESENTER_VERSION)/minui-presenter-tg5040
	chmod +x bin/minui-presenter

bin/jq:
	mkdir -p bin
	curl -f -o bin/jq -sSL https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-arm64
	chmod +x bin/jq
	curl -sSL -o bin/jq.LICENSE "https://github.com/jqlang/jq/raw/refs/heads/master/COPYING"

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist
