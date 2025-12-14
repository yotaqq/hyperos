#!/bin/bash
# Run HyperOS in QEMU

ISO_FILE="build/hyperos.iso"

if [ ! -f "$ISO_FILE" ]; then
    echo "Error: ISO file not found: $ISO_FILE"
    echo "Run 'make' first to build the ISO"
    exit 1
fi

echo "Starting HyperOS in QEMU..."
echo "Press Ctrl+Alt+G to release mouse"
echo "Press Ctrl+C to quit"
echo ""

# Run QEMU
qemu-system-x86_64 \
    -cdrom "$ISO_FILE" \
    -m 512M \
    -serial stdio \
    -vga std \
    -cpu qemu64 \
    -boot d
