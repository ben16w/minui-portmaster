<div align="center">
<img src=".github/resources/banner.png" width="auto" alt="MinUI Portmaster wordmark">

![GitHub License](https://img.shields.io/github/license/ben16w/minui-portmaster?style=for-the-badge)
![GitHub Release](https://img.shields.io/github/v/release/ben16w/minui-portmaster?sort=semver&style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/ben16w/minui-portmaster?style=for-the-badge)
![GitHub Downloads (specific asset, all releases)](https://img.shields.io/github/downloads/ben16w/minui-portmaster/PORTS.pak.zip?style=for-the-badge&label=Downloads)

</div>

A PortMaster Emu Pack for MinUI and NextUI that includes everything needed out of the box, no additional software required.

## Description

MinUI PortMaster is an Emu Pak for [MinUI](https://github.com/shauninman/MinUI) and [NextUI](https://github.com/LoveRetro/NextUI), wrapping up [PortMaster](https://portmaster.games/), which organizes and simplifies the installation process of PC ports. MinUI PortMaster is a standalone Emu Pak and doesn't require anything additional to run, for example, [TRIMUI_EX](https://github.com/kloptops/TRIMUI_EX). Everything is included in the download and only a few steps are needed to install.

## Features

- Browse and install a wide selection of community ports and homebrew.
- Distributed as a single Pak folder, no additional setup required.
- Follows MinUI/NextUI SD card folder structure.
- View cover artwork in NextUI for installed ports.
- Supports deep sleep and shutdown on compatible devices.

## Supported Platforms

MinUI PortMaster is designed and tested for the following platforms:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro

> [!IMPORTANT]
> MinUI PortMaster has been designed to run on TrimUI devices only.

## Disclaimer

This project is not officially supported by PortMaster. Please do **not** report issues related to MinUI PortMaster to the official PortMaster project or its maintainers. If you encounter any issues, refer to the [Troubleshooting](#troubleshooting) section instead.

## Installation

### MinUI Installation

1. Mount your MinUI SD card to your computer.
2. Download the latest [release](https://github.com/ben16w/minui-portmaster/releases) from GitHub. Make sure to download the file named `PORTS.pak.zip` and not the `.pakz` file.
3. Copy the zip file to the correct platform folder in the "/Emus" folder on the SD card. Please ensure the new zip file name is `PORTS.pak.zip`.
4. Extract the zip in place, then delete the zip file.
5. Confirm that there is a `/Emus/<PLATFORM>/PORTS.pak/launch.sh` file on your SD card.
6. Create a folder at `/Roms/Ports (PORTS)`. This is where all the ports data will be stored.
7. Create an empty file named `Portmaster.sh` in `/Roms/Ports (PORTS)`. Alternatively, you can copy the `Portmaster.sh` file from this repository.
8. Eject your SD card and insert it back into your MinUI device.

Note: The `<PLATFORM>` folder name is based on the name of your device. For example, if you are using a TrimUI Brick, the folder is `tg5040`.

### NextUI Installation

The recommended method to install PortMaster on NextUI devices is to use the [Pak Store](https://github.com/UncleJunVIP/nextui-pak-store). Alternatively, you can install it manually by following these steps:

1. Mount your NextUI SD card to your computer.
2. Download the latest `.pakz` file from the [releases page](https://github.com/ben16w/minui-portmaster/releases). It will be named `PORTS.pakz`.
3. Copy the `.pakz` file to the root of your SD card.
4. Eject your SD card and insert it back into your NextUI device.
5. Restart your device. NextUI will automatically detect and install the new Pak.

## Usage

- From MinUI/NextUI, go to **Ports** and select the **Portmaster** entry to launch the Portmaster GUI.
- Browse available ports and install new ones.
- Installed ports will appear under the Ports entry in MinUI/NextUI.

> [!TIP]
> Not all ports are ready to run immediately after installation, and some may require additional steps. This usually involves copying files from a purchased copy of a game. The files will need to be copied to the corresponding port folder in `/Roms/Ports (PORTS)/.ports` on the SD card. Please refer to the port's documentation at the [PortMaster](https://portmaster.games/games.html) website for specific instructions on how to install each port.

## Updating

The steps below will update PortMaster to a new version while preserving your data and settings. It is also used when updating the pak through the [NextUI Pak Store](https://github.com/UncleJunVIP/nextui-pak-store).

1. Mount your MinUI SD card to your computer.
2. Download the latest [release](https://github.com/ben16w/minui-portmaster/releases) from GitHub. It will be named `PORTS.pak.zip`.
3. Extract the zip file on your computer. This will create a new `PORTS.pak` folder.
4. In the new `PORTS.pak` folder, delete the folder named `PortMaster`.
5. On your SD card, open the existing `/Emus/<PLATFORM>/PORTS.pak` folder.
6. Copy the entire contents of the new `PORTS.pak` folder (the `PortMaster` folder will be missing) to the existing `PORTS.pak` folder on your SD card. **Overwrite any files when prompted.**
7. Eject your SD card and insert it back into your MinUI device.

### Alternative Method

Follow the steps below to replace the entire `PORTS.pak` folder on your SD card with a new one. It is only recommended if you are having issues after trying the steps above.

1. Mount your MinUI SD card to your computer.
2. Delete the entire old `PORTS.pak` folder from `/Emus/<PLATFORM>/` on your SD card.
3. Follow the steps in the [MinUI Installation](#minui-installation) section above to copy an updated `PORTS.pak` to your SD card.

> [!TIP]
> This method may remove some dependencies required by your installed ports. If a port does not work after updating, launch PortMaster, go to **Manage Ports**, select the port that is not working, and choose **Reinstall**. This will restore any missing files for that port.

## Deep Sleep & Shutdown

Deep sleep is supported on compatible devices. Click the power button to enter deep sleep. Click again to resume the game. To shut down, hold the power button for 2 seconds. **Note:** Shutdown does not save or resume the game, and any unsaved progress will be lost. For more information and issues, see [MinUI Power Control](https://github.com/ben16w/minui-power-control).

## Artwork

Artwork for ports will automatically be displayed in NextUI. This feature can be disabled by creating a file named `no-artwork` in the `/.userdata/<PLATFORM>/PORTS-portmaster` folder on your SD card. Artwork is currently not supported in MinUI.

## Controller Layout

MinUI PortMaster supports two controller button layouts: **Xbox** (default) and **Nintendo**.

- **Xbox layout**: A/B/X/Y buttons follow the Xbox controller standard (A is bottom, B is right).
- **Nintendo layout**: A/B/X/Y buttons follow the Nintendo controller standard (A is right, B is bottom).

By default, the Xbox layout is used. To switch to the Nintendo layout:

1. Create an empty file named `nintendo` in the `/.userdata/<PLATFORM>/PORTS-portmaster` folder on your SD card.
2. The Nintendo layout will be applied automatically when launching any port.

To switch back to the Xbox layout, simply delete the `nintendo` file. The layout is applied each time a port is launched.

## Known Issues

- Some loading screens can take a long time to complete, sometimes up to 10 minutes. This is most noticeable the first time you run PortMaster or a port, as files need to be unpacked and patched. Please be patient and allow the process to complete.
- To check which ports are currently working or have known issues with this pak, please visit the [Ports Status wiki page](https://github.com/ben16w/minui-portmaster/wiki/Ports-Status).

## Troubleshooting

- Log files are stored in `/.userdata/tg5040/logs/PORTS.txt` for debugging.
- If you encounter problems or bugs, please [open an issue](https://github.com/ben16w/minui-portmaster/issues/new) in this GitHub repository with details and a copy of the log file.
- For general support or questions, join the [NextUI Discord](https://discord.gg/HKd7wqZk3h) and post in the [Standalone PortMaster](https://discord.com/channels/1347893601337737338/1365382235544485959) channel for assistance.

## Thanks

- The [PortMaster](https://portmaster.games/) team for all their hard work.
- [ro8inmorgan](https://github.com/ro8inmorgan), [frysee](https://github.com/frysee) and the rest of the NextUI contributors for developing [NextUI](https://github.com/LoveRetro/NextUI).
- [Shaun Inman](https://github.com/shauninman) for developing [MinUI](https://github.com/shauninman/MinUI).
- Also, thank you, [josegonzalez](https://github.com/josegonzalez), for your pak repositories, which this project is based on.

## License

PortMaster is open-source software licensed under the [MIT License](https://opensource.org/licenses/MIT). See the [LICENSE](https://raw.githubusercontent.com/PortsMaster/PortMaster-GUI/refs/heads/main/LICENSE) for details.

The libraries and binaries contained in the `lib` and `bin` directories are third-party components. They are licensed under their respective licenses and are not part of this project.

The MinUI PortMaster project code is licensed under the [MIT License](https://opensource.org/licenses/MIT). See the project [LICENSE](LICENSE) file for more details.
