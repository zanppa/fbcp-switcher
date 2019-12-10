# fbcp-switcher
Scripts to switch between [fbtft](https://github.com/notro/fbtft)/[fbcp](https://github.com/tasanakorn/rpi-fbcp) and [fbcp-ili9341](https://github.com/juj/fbcp-ili9341) on-the-fly

## Target
This repository contains scripts for Raspberry PI and SPI TFT displays.

## Introduction
The scripts are intended to switch between the "standard" [fbtft](https://github.com/notro/fbtft) and [fbcp](https://github.com/tasanakorn/rpi-fbcp) display driver and the ultra-fast [fbcp-ili9341](https://github.com/juj/fbcp-ili9341) display driver on the fly. The fast driver does not currently support the touch screen available in many displays, but is otherwise much faster driver. That's why these scripts were made, to allow using the touch screen when update speed is not critical (desktop) and change to the fast driver when it is (games, videos etc.).

## Background
The scripts were made for [Waveshare 4" touch screen TFT](https://www.waveshare.com/wiki/4inch_RPi_LCD_(A)) running on Raspberry PI zero W. I don't see why the scripts would not work on other hardware, but they need to be modified accordingly.

## Installation
It is necessary to have a working overlay for the display, one which also loads the correct kernel modules for the display and the touch screen. I used the waveshare35a overlay from [this repository](https://github.com/swkim01/waveshare-dtoverlays) which works fine for the 4 inch version also. I placed the overlay to */boot/overlays/waveshare35a.dtbo*.

The overlay must **NOT** be enabled in */boot/config.txt*. The dynamic loading wont work if it is loaded at boot time! However the scripts assume that SPI is enabled in boot time, so add following line to */boot/config.txt*:
```
dtparam=spi=on
```

Install [fbcp](https://github.com/tasanakorn/rpi-fbcp) and [fbcp-ili9341](https://github.com/juj/fbcp-ili9341) to */usr/local/bin/*.

The two shell scripts that should be placed in */usr/local/bin/* are where the magic happens. One loads the overlay & drivers and the other removes them. 

In the **load-waveshare35a-overlay.sh** it is necessary to:
1. Change the name/path of the overlay in few places; where the script checks whether the overlay is already loaded and where the ovelay file is loaded. Also any overlay paramater need to be chabged. In the script the ovelay name is **waveshare35a** and the loading command line is **dtoverlay /boot/overlays/waveshare35a.dtbo rotate=90 swapxy=1**.
2. Change the names of the kernel modules that will be loaded when the overlay is loaded. One way to check them is to run **lsmod** without the overlay and then use the **dtoverlay** command line to load the overlay by hand and check the module list again. In my case the relevant modules were **fbtft** and **fb_ili9486** for the display and **ads7846** for the touch screen.
3. Check what framebuffer device is created in */dev/* when the overlay is loaded. In my case it was */dev/fb1*. The other framebuffer, */dev/fb0*, is probably for the HDMI output.

In the **remove-waveshare35a-overlay.sh** the same things need to be changed:
1. Module names that must(?) be removed before the overlay is removed (I'm not sure if it is necessary or does removing the overlay also remove the modules? I didn't bother to check).
2. Overlay name to be removed.

The systemd scripts can be copied directly to the */etc/systemd/system/* directory. They should not need modifications.

## Usage
The usage is quite straightforward. To start one or other of the drivers, run
```
sudo systemctl start fbcp
```
or
```
sudo systemctl start fbcp-ili9341
```

To stop one of them, run
```
sudo systemctl stop fbcp
```
or
```
sudo systemctl stop fbcp-ili9341
```

To enable one of them to run at boot time, run
```
sudo systemctl enable fbcp
```
or
```
sudo systemctl enable fbcp-ili9341
```

Disabling the boot time launch similarly by replacing the command with **disable**.

The systemd scripts are made to be conflicting, so starting one stops the other (and one is stopped before the other is started). So it is possible to run:
```
sudo systemctl start fbcp
sudo systemctl start fbcp-ili9341
sudo systemctl start fbcp
sudo systemctl start fbcp-ili9341
```
and the driver should change cleanly and everything just works.

## Notes
It seems that fbcp-ili9341 leaves the SPI in a weird configuration, so it is necessary to disable it and then re-enable it to make the fbtft driver work afterwards. This is handled in the overlay loading scripts.

## License
Copyright (C) 2019 Lauri Peltonen

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

## Disclaimer
This program is for INFORMATION PURPOSES ONLY. You use this at your own risk, author takes no responsibility for any loss or damage caused by using this program or any information presented.
