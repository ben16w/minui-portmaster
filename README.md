# MinUI PortMaster

A MinUI and NextUI Emu Pak for PortMaster which includes everything needed and requires no additional software.

## Description

MinUI PortMaster is an Emu Pak for [MinUI](https://github.com/shauninman/MinUI) and [NextUI](https://github.com/LoveRetro/NextUI), wrapping up [PortMaster](https://portmaster.games/), which organizes and simplifies the installation process for hundreds of PC ports. MinUI PortMaster is a standalone Emu Pak and does not require any additional software to run, for example, [TRIMUI_EX](https://github.com/kloptops/TRIMUI_EX). Everything is included in the `PORTS.pak` file and only a few steps are needed to install.

> **Note:** MinUI PortMaster has been deigned to run on TrimUI devices only.

## Features

- Browse and install a wide selection of community ports and homebrew.
- Distributed as a single Pak directory, no additional setup required.
- Follows MinUI/NextUI SD card folder structure.
- View cover artwork in NextUI for installed ports.
- Supports deep sleep and shutdown on compatible devices (coming soon).

## Supported Platforms

PortMaster is designed and tested for the following platforms:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro

## Installation

1. Mount your MinUI SD card to your computer.
2. Download the latest release from GitHub. It will be named `PORTS.pak.zip`.
3. Copy the zip file to the correct platform folder in the "/Emus" directory on the SD card. Please ensure the new zip file name is `PORTS.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Emus/<PLATFORM>/PORTS.pak/launch.sh` file on your SD card.
6. Create a folder at `/Roms/Ports (PORTS)`. This is where all the ports data will be stored.
7. Create an empty file named `Portmaster.sh` in `/Roms/Ports (PORTS)`. Alternatively, you can copy the `Portmaster.sh` file from this repository.
8. Unmount your SD Card and insert it into your MinUI device.

Note: The `<PLATFORM>` folder name is based on the name of your device. For example, if you are using a TrimUI Brick, the folder is `tg5040`.

## Usage

- From MinUI or NextUI, select the Ports->Portmaster entry to launch the manager.
- Browse available ports and install new ones.
- Installed ports will appear under the Ports entry in MinUI/NextUI.

## Known Issues

- When you launch PortMaster or a port, a `/mnt/SDCARD/Data/ports` directory is created. It is usually deleted when PortMaster closes, but sometimes it may remain. This does not cause problems, but you can safely delete the folder manually if PortMaster is not running and the `/mnt/SDCARD/Data/ports` folder is empty.
- There is currently no way to manually install ports without Wi-Fi. The PortMaster GUI must be used to all install ports.
- Some ports may not display cover art because the original port did not provide it. In a future update, screenshots will be used as a fallback for ports missing cover images.

## Troubleshooting

- Log files are stored in `/.userdata/tg5040/logs/PORTS.txt` for debugging.
- If you encounter issues, please open an issue on this GitHub repository with the details and a copy of the log file.

## Thanks

- The [PortMaster](https://portmaster.games/) team for all their hard work.
- [Shaun Inman](https://github.com/shauninman) for developing [MinUI](https://github.com/shauninman/MinUI).
- [ro8inmorgan](https://github.com/ro8inmorgan), [frysee](https://github.com/frysee) and the rest of the NextUI contributors for developing [NextUI](https://github.com/LoveRetro/NextUI).
- Also, thank you, [josegonzalez](https://github.com/josegonzalez), for your pak repositories, which this project is based on.

## License

PortMaster is open-source software licensed under the [MIT License](https://opensource.org/licenses/MIT). See the [LICENSE](https://raw.githubusercontent.com/PortsMaster/PortMaster-GUI/refs/heads/main/LICENSE) for details.

The project code which is not part of PortMaster is also licensed under the [MIT License](https://opensource.org/licenses/MIT). See the project [LICENSE](LICENSE) file for more details.
