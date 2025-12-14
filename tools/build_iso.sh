#!/bin/bash
# Build ISO image for HyperOS

set -e

echo "Building HyperOS ISO..."

# Create directories
mkdir -p isodir/boot/grub
mkdir -p build

# Copy kernel
cp build/kernel.bin isodir/boot/kernel.bin

# Copy GRUB configuration
cp grub.cfg isodir/boot/grub/grub.cfg

# Create ISO
grub-mkrescue -o build/hyperos.iso isodir

echo "ISO created: build/hyperos.iso"
