<div align="center">
<img src=".github/resources/banner.png" width="auto" alt="MinUI Portmaster wordmark">

![GitHub License](https://img.shields.io/github/license/ben16w/minui-portmaster?style=for-the-badge)
![GitHub Release](https://img.shields.io/github/v/release/ben16w/minui-portmaster?sort=semver&style=for-the-badge)
![GitHub Repo stars](https://img.shields.io/github/stars/ben16w/minui-portmaster?style=for-the-badge)
![GitHub Downloads (specific asset, all releases)](https://img.shields.io/github/downloads/ben16w/minui-portmaster/PORTS.pak.zip?style=for-the-badge&label=Downloads)

</div>

A MinUI and NextUI Emu Pak for PortMaster which includes everything needed and requires no additional software.

## Description

MinUI PortMaster is an Emu Pak for [MinUI](https://github.com/shauninman/MinUI) and [NextUI](https://github.com/LoveRetro/NextUI), wrapping up [PortMaster](https://portmaster.games/), which organizes and simplifies the installation process for hundreds of PC ports. MinUI PortMaster is a standalone Emu Pak and does not require any additional software to run, for example, [TRIMUI_EX](https://github.com/kloptops/TRIMUI_EX). Everything is included in the download and only a few steps are needed to install.

> [!IMPORTANT]
> MinUI PortMaster has been designed to run on TrimUI devices only.

## Features

- Browse and install a wide selection of community ports and homebrew.
- Distributed as a single Pak folder, no additional setup required.
- Follows MinUI/NextUI SD card folder structure.
- View cover artwork in NextUI for installed ports.
- Supports deep sleep and shutdown on compatible devices.

## Supported Platforms

PortMaster is designed and tested for the following platforms:

- `tg5040`: Trimui Brick (formerly `tg3040`), Trimui Smart Pro

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

1. Mount your NextUI SD card to your computer.
2. Download the latest `.pakz` file from the [releases page](https://github.com/ben16w/minui-portmaster/releases). It will be named `PORTS.pakz`.
3. Copy the `.pakz` file to the root of your SD card.
4. Eject your SD card and insert it back into your NextUI device.
5. Restart your device. NextUI will automatically detect and install the new Pak.

## Usage

- From MinUI/NextUI, go to **Ports** and select the **Portmaster** entry to launch the Portmaster GUI.
- Browse available ports and install new ones.
- Installed ports will appear under the Ports entry in MinUI/NextUI.

> [!IMPORTANT]
> Not all ports are ready to run immediately after installation, and some may require additional steps. This usually involves copying files from a purchased copy of a game. The files will need to be copied to the corresponding port folder in `/Roms/Ports (PORTS)/.ports` on the SD card. Please refer to the port's documentation at the [PortMaster](https://portmaster.games/games.html) website for specific instructions on how to install each port.

## Updating

### Safe Update

This is the recommended method for updating PortMaster to a new version. It keeps your PortMaster data and settings intact while updating everything else. It is the method used when updating the pak via the [NextUI Pak Store](https://github.com/UncleJunVIP/nextui-pak-store).

1. Mount your MinUI SD card to your computer.
2. Download the latest [release](https://github.com/ben16w/minui-portmaster/releases) from GitHub. It will be named `PORTS.pak.zip`.
3. Extract the zip file on your computer. This will create a new `PORTS.pak` folder.
4. In the new `PORTS.pak` folder, delete the folder named `PortMaster`.
5. On your SD card, open the existing `/Emus/<PLATFORM>/PORTS.pak` folder.
6. Copy the entire contents of the new `PORTS.pak` folder (the `PortMaster` folder will be missing) to the existing `PORTS.pak` folder on your SD card. **Overwrite any files when prompted.**
7. Eject your SD card and insert it back into your MinUI device.

### Full Update (Not Recommended)

This method replaces the entire `PORTS.pak` folder on your SD card with a new one. It is quicker, but it's not recommended as PortMaster settings and data will be lost. This method is only recommended if you are having issues after trying the Safe Update method.

1. Mount your MinUI SD card to your computer.
2. Download the latest [release](https://github.com/ben16w/minui-portmaster/releases) from GitHub. It will be named `PORTS.pak.zip`.
3. Delete the entire old `PORTS.pak` folder from `/Emus/<PLATFORM>/` on your SD card.
4. Copy the new `PORTS.pak` folder (from the extracted zip) to `/Emus/<PLATFORM>/` on your SD card.
5. Eject your SD card and insert it back into your MinUI device.

> [!IMPORTANT]
> This method may remove some dependencies required by your installed ports. If a port does not work after updating, launch PortMaster, go to **Manage Ports**, select the port that is not working, and choose **Reinstall**. This will restore any missing files for that port.

## Deep Sleep & Shutdown

Deep sleep is supported on compatible devices. Click the power button to enter deep sleep. Click again to resume the game. To shut down, hold the power button for 2 seconds. **Note:** Shutdown does not save or resume the game, and any unsaved progress will be lost. For more information and issues, see [MinUI Power Control](https://github.com/ben16w/minui-power-control).

## Artwork

Artwork for ports will automatically be displayed in NextUI. This feature can be disabled by creating a file named `no-artwork` in the `/.userdata/<PLATFORM>/PORTS-portmaster` folder on your SD card. MinUI is currently not supported.

## Known Issues

- Some loading screens can take a long time to complete, sometimes up to 10 minutes. This is most noticeable the first time you run PortMaster or a port, as files need to be unpacked and patched. Please be patient and allow the process to complete.
- To check which ports are currently working or have known issues with this pak, please visit the [Ports Status wiki page](https://github.com/ben16w/minui-portmaster/wiki/Ports-Status).

## Troubleshooting

- Log files are stored in `/.userdata/tg5040/logs/PORTS.txt` for debugging.
- If you encounter issues, please open an issue on this GitHub repository with the details and a copy of the log file.

## Thanks

- The [PortMaster](https://portmaster.games/) team for all their hard work.
- [ro8inmorgan](https://github.com/ro8inmorgan), [frysee](https://github.com/frysee) and the rest of the NextUI contributors for developing [NextUI](https://github.com/LoveRetro/NextUI).
- [Shaun Inman](https://github.com/shauninman) for developing [MinUI](https://github.com/shauninman/MinUI).
- Also, thank you, [josegonzalez](https://github.com/josegonzalez), for your pak repositories, which this project is based on.

## License

PortMaster is open-source software licensed under the [MIT License](https://opensource.org/licenses/MIT). See the [LICENSE](https://raw.githubusercontent.com/PortsMaster/PortMaster-GUI/refs/heads/main/LICENSE) for details.

The libraries and binaries contained in the `lib` and `bin` directories are third-party components. They are licensed under their respective licenses and are not part of this project.

The MinUI PortMaster project code is licensed under the [MIT License](https://opensource.org/licenses/MIT). See the project [LICENSE](LICENSE) file for more details.
