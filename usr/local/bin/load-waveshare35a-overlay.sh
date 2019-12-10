#!/bin/sh

# Disable and re-enable SPI (this assumes that /boot/config.txt enables SPI)
dtparam spi=off
dtparam -r

# Test if fbcp or fbcp-ili9341 is running
pgrep fbcp > /dev/null
if [ $? -eq 0 ]; then
        echo "fbcp or fbcp-ili9341 already running, stop them first"
        exit 1
fi

# Test if overlay is already dynamically loaded
if dtoverlay -l | grep -q 'waveshare35a'; then
        echo "Overlay already dynamically loaded"
        exit 1
fi

# Test if the module(s) are already loaded
if lsmod | grep -q 'fbtft\|fb_ili9486\|ads7846'; then
        echo "Modules already loaded (fbtft, fb_ili9486 or ads7846)"
        exit 1
fi

# Try to load the overlay
dtoverlay /boot/overlays/waveshare35a.dtbo rotate=90 swapxy=1
if [ $? -ne 0 ]; then
        echo "Could not load the overlay dynamically"
        exit 1
fi

# Wait until the /dev/fb1 is created, indicating that modules
# are properly loaded and functioning
while [ ! -e /dev/fb1 ] ; do
    sleep 0.1s
done
