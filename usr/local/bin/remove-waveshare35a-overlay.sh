#!/bin/sh

# Test if fbcp or fbcp-ili9341 is running
pgrep fbcp > /dev/null
if [ $? -eq 0 ]; then
        echo "fbcp or fbcp-ili9341 already running, stop them first"
        exit 1
fi

# Try to remove the modules
modprobe -r ads7846 fb_ili9486 fbtft
if [ $? -ne 0 ]; then
        echo "Could not remove the modules, are they still in use?"
        exit 1
fi

# Try to load the overlay
dtoverlay -r waveshare35a
if [ $? -ne 0 ]; then
        echo "Could not remove the overlay dynamically, is it loaded at boot?"
        exit 1
fi
