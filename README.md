# HyperOS - UNIX-like Operating System for x86_64

HyperOS is a UNIX-like operating system built from scratch for the x86_64 architecture, featuring GRUB bootloader, full POSIX syscall compatibility, and preemptive multitasking.

## Project Status

✅ **Iteration 1 Complete: Hello World Bootable Kernel**

- Multiboot2 compliant bootloader
- 32-bit to 64-bit Long Mode transition
- VGA text mode driver
- Serial port driver (COM1)
- Basic kernel with "Hello World" output

## Project Structure

```
HyperOS/
├── boot/                   # Bootloader code
│   ├── multiboot2.asm      # Multiboot2 header
│   ├── boot.asm            # Bootstrap & Long Mode transition
│   ├── gdt.asm             # 64-bit GDT
│   └── linker.ld           # Linker script
├── kernel/                 # Kernel source code
│   ├── main.c              # Kernel entry point
│   ├── lib/                # Kernel library functions
│   └── drivers/            # Device drivers
├── include/                # Header files
├── tools/                  # Build scripts
├── Makefile                # Build system
└── grub.cfg                # GRUB configuration
```

## Prerequisites (WSL/Linux)

### 1. Install WSL (if on Windows)

```bash
# In PowerShell (Administrator)
wsl --install
```

### 2. Install Build Tools in WSL/Linux

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install -y build-essential nasm xorriso grub-pc-bin \
    grub-common qemu-system-x86 git mtools

# Verify installations
nasm --version
gcc --version
qemu-system-x86_64 --version
grub-mkrescue --version
```

## Building HyperOS

### Quick Start

```bash
# Clone or navigate to the project directory
cd /mnt/d/Projects/HyperOS  # (in WSL)

# Build the ISO
make

# Run in QEMU
make run
```

### Build Steps

1. **Compile assembly and C sources:**
   ```bash
   make
   ```
   This will:
   - Compile all `.asm` files with NASM
   - Compile all `.c` files with GCC
   - Link everything into `build/kernel.bin`
   - Create bootable ISO at `build/hyperos.iso`

2. **Run in QEMU:**
   ```bash
   make run
   ```
   Or manually:
   ```bash
   qemu-system-x86_64 -cdrom build/hyperos.iso -m 512M -serial stdio
   ```

3. **Clean build files:**
   ```bash
   make clean
   ```

## Expected Output

When you run HyperOS in QEMU, you should see:

```
HyperOS v0.1 - Hello World!
========================

Bootloader: GRUB Multiboot2
Architecture: x86_64
Status: Running in 64-bit Long Mode

Multiboot2 magic: 0x36D76289
Multiboot2 info: 0x00100000

Kernel initialization complete.
System ready.
```

The same output will also appear on the serial console (stdio).

## Development Roadmap

### Completed
- ✅ Iteration 1: Minimal bootable kernel (Hello World)

### Planned
- ⏳ Iteration 2: Memory management (PMM, VMM, heap)
- ⏳ Iteration 3: Interrupts and timer
- ⏳ Iteration 4: Basic multitasking
- ⏳ Iteration 5: User mode transition
- ⏳ Iteration 6: First syscall (write)
- ⏳ Iteration 7: Process management (fork, exit)
- ⏳ Iteration 8: exec and wait
- ⏳ Iteration 9: RamFS
- ⏳ Iteration 10: TarFS (initrd)
- ⏳ Iteration 11: Keyboard driver
- ⏳ Iteration 12: Simple shell
- ⏳ Iteration 13: Basic utilities
- ⏳ Iteration 14: Memory management syscalls
- ⏳ Iteration 15: Signals

## Key Features (Planned)

- **Bootloader:** GRUB Multiboot2
- **Architecture:** x86_64 Long Mode
- **Memory Management:** 4-level paging, PMM, VMM, kernel heap
- **Multitasking:** Preemptive multitasking with round-robin scheduler
- **Syscalls:** Minimum 17 POSIX-compatible syscalls
- **Filesystems:** RamFS + TarFS (for initrd)
- **Drivers:** VGA, Serial, PS/2 Keyboard, PIT Timer, ATA
- **Userspace:** init, shell, basic utilities (ls, cat, echo, ps)

## Technical Details

### Memory Layout

```
0x0000000000000000 - 0x00007FFFFFFFFFFF : User space (128TB)
0xFFFF800000000000 - 0xFFFF8FFFFFFFFFFF : Direct physical mapping
0xFFFFFF0000000000 - 0xFFFFFF7FFFFFFFFF : Kernel heap
0xFFFFFFFF80000000 - 0xFFFFFFFFFFFFFFFF : Kernel code/data
```

### Compiler Flags

```makefile
CFLAGS = -ffreestanding -fno-stack-protector -fno-pic \
         -mno-red-zone -mno-mmx -mno-sse -mno-sse2 \
         -mcmodel=kernel -nostdlib -Wall -Wextra -O2
```

The `-mno-red-zone` flag is critical for x86_64 interrupt handling.

## Debugging

### QEMU with GDB

```bash
# Terminal 1: Start QEMU with GDB server
qemu-system-x86_64 -cdrom build/hyperos.iso -s -S

# Terminal 2: Connect GDB
gdb build/kernel.bin
(gdb) target remote localhost:1234
(gdb) break kernel_main
(gdb) continue
```

### Serial Output

All kernel messages are also sent to COM1 (serial port), which QEMU redirects to stdio with `-serial stdio` flag.

## Resources

- [OSDev Wiki](https://wiki.osdev.org/)
- [Multiboot2 Specification](https://www.gnu.org/software/grub/manual/multiboot2/)
- [Intel SDM Vol 3 - System Programming](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
- [Linux System Call Table x86_64](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)

## License

This is an educational project. Feel free to use and modify as needed.

## Contributing

This is a learning project following an iterative development approach. Each iteration builds upon the previous one, gradually creating a fully functional UNIX-like OS.

---

**Current Version:** 0.1
**Last Updated:** 2025-12-15
