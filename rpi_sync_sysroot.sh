#!/bin/bash

# Script to sync Raspberry Pi system directories using hostname

# Go to home directory
cd ~
sudo rm -rf rpi-sysroot

# Define target directories
TARGET_BASE="rpi-sysroot"
DIRS=("/usr" "/lib" "/usr/lib" "/opt")

# Create base directory if it doesn't exist
mkdir -p "$TARGET_BASE"

# Create required subdirectories
for dir in "${DIRS[@]}"; do
    mkdir -p "$TARGET_BASE$dir"
done
# Sync directories from Raspberry Pi using raspberrypi.local
# Change raspberrypi by the name of your board
rsync -avz --rsync-path="sudo rsync" pi@raspberrypi.local:/usr/include "$TARGET_BASE/usr"
rsync -avz --rsync-path="sudo rsync" pi@raspberrypi.local:/lib "$TARGET_BASE"
rsync -avz --rsync-path="sudo rsync" pi@raspberrypi.local:/usr/lib "$TARGET_BASE/usr"


#Fix absolute symbolic links
# Check if the file already exists
if [ ! -f sysroot-relativelinks.py ]; then
    wget https://raw.githubusercontent.com/riscv/riscv-poky/master/scripts/sysroot-relativelinks.py
else
    echo "sysroot-relativelinks.py already exists, skipping download."
fi

# Make the script executable
chmod +x sysroot-relativelinks.py 

# Run the Python script
python3 sysroot-relativelinks.py rpi-sysroot
