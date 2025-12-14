# WSL Setup Guide for HyperOS Development

This guide will help you set up Windows Subsystem for Linux (WSL) for HyperOS development.

## Step 1: Install WSL

### If you don't have WSL installed:

1. Open PowerShell as Administrator
2. Run:
   ```powershell
   wsl --install
   ```
3. Restart your computer when prompted
4. After restart, Ubuntu will open automatically and ask you to create a username and password

### If you already have WSL:

```powershell
wsl --update
```

## Step 2: Access Your Project in WSL

Your Windows drives are mounted in `/mnt/` in WSL:

```bash
# Start WSL
wsl

# Navigate to the project
cd /mnt/d/Projects/HyperOS

# Verify you're in the right place
ls -la
```

## Step 3: Install Build Tools

Run these commands in WSL:

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install -y \
    build-essential \
    nasm \
    xorriso \
    grub-pc-bin \
    grub-common \
    qemu-system-x86 \
    git \
    mtools

# Verify installations
echo "Checking installations..."
nasm --version       # Should show NASM version
gcc --version        # Should show GCC version
ld --version         # Should show ld version
qemu-system-x86_64 --version  # Should show QEMU version
grub-mkrescue --version       # Should show GRUB version
```

## Step 4: Build HyperOS

```bash
# Make sure you're in the project directory
cd /mnt/d/Projects/HyperOS

# Build the project
make

# Expected output:
# AS   boot/multiboot2.asm
# AS   boot/boot.asm
# AS   boot/gdt.asm
# CC   kernel/main.c
# CC   kernel/lib/string.c
# CC   kernel/drivers/vga.c
# CC   kernel/drivers/serial.c
# LD   build/kernel.bin
# Creating ISO image...
# ISO created: build/hyperos.iso
```

## Step 5: Run in QEMU

```bash
# Run the OS
make run

# You should see a QEMU window with HyperOS running!
```

## Alternative: Run Commands Directly

If you prefer not to use the Makefile:

```bash
# Clean previous builds
rm -rf build isodir

# Create build directories
mkdir -p build/lib build/drivers

# Compile assembly files
nasm -f elf64 boot/multiboot2.asm -o build/multiboot2.o
nasm -f elf64 boot/boot.asm -o build/boot.o
nasm -f elf64 boot/gdt.asm -o build/gdt.o

# Compile C files
gcc -std=c11 -ffreestanding -fno-stack-protector -fno-pic \
    -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mcmodel=kernel \
    -nostdlib -Iinclude -Wall -Wextra -O2 \
    -c kernel/main.c -o build/main.o

gcc -std=c11 -ffreestanding -fno-stack-protector -fno-pic \
    -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mcmodel=kernel \
    -nostdlib -Iinclude -Wall -Wextra -O2 \
    -c kernel/lib/string.c -o build/lib/string.o

gcc -std=c11 -ffreestanding -fno-stack-protector -fno-pic \
    -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mcmodel=kernel \
    -nostdlib -Iinclude -Wall -Wextra -O2 \
    -c kernel/drivers/vga.c -o build/drivers/vga.o

gcc -std=c11 -ffreestanding -fno-stack-protector -fno-pic \
    -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -mcmodel=kernel \
    -nostdlib -Iinclude -Wall -Wextra -O2 \
    -c kernel/drivers/serial.c -o build/drivers/serial.o

# Link kernel
ld -nostdlib -z max-page-size=0x1000 -T boot/linker.ld -o build/kernel.bin \
    build/multiboot2.o build/boot.o build/gdt.o build/main.o \
    build/lib/string.o build/drivers/vga.o build/drivers/serial.o

# Create ISO
mkdir -p isodir/boot/grub
cp build/kernel.bin isodir/boot/kernel.bin
cp grub.cfg isodir/boot/grub/grub.cfg
grub-mkrescue -o build/hyperos.iso isodir

# Run in QEMU
qemu-system-x86_64 -cdrom build/hyperos.iso -m 512M -serial stdio
```

## Troubleshooting

### "Permission denied" errors

Make sure scripts are executable:
```bash
chmod +x tools/build_iso.sh tools/run_qemu.sh
```

### "grub-mkrescue: command not found"

Install GRUB tools:
```bash
sudo apt install -y grub-pc-bin grub-common xorriso mtools
```

### "nasm: command not found"

Install NASM:
```bash
sudo apt install -y nasm
```

### QEMU doesn't show a window

Make sure you have X server running (VcXsrv or similar) or use:
```bash
qemu-system-x86_64 -cdrom build/hyperos.iso -m 512M -serial stdio -nographic
```

### WSL can't find /mnt/d

Your drive might not be mounted. Check:
```bash
ls /mnt/
```

If missing, check your WSL configuration in `/etc/wsl.conf`

## Quick Reference

```bash
# Build
make

# Run
make run

# Clean
make clean

# Rebuild from scratch
make rebuild
```

## Next Steps

After successfully building and running HyperOS Iteration 1, you can:

1. Read the [README.md](README.md) for project overview
2. Check the plan file for upcoming iterations
3. Start implementing Iteration 2 (Memory Management)

## Resources

- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [OSDev Wiki](https://wiki.osdev.org/)
- [NASM Documentation](https://www.nasm.us/docs.php)
- [QEMU Documentation](https://www.qemu.org/docs/master/)

---

**Need Help?** Check the troubleshooting section or open an issue on GitHub.
