# HyperOS Makefile

# Build tools (use cross-compiler if available)
AS := nasm
CC := gcc
LD := ld

# Directories
BUILD_DIR := build
ISO_DIR := isodir
BOOT_DIR := boot
KERNEL_DIR := kernel
INCLUDE_DIR := include

# Output files
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
ISO_FILE := $(BUILD_DIR)/hyperos.iso

# Assembly flags
ASFLAGS := -f elf64

# C compiler flags
CFLAGS := -std=c11 \
          -ffreestanding \
          -fno-stack-protector \
          -fno-pic \
          -mno-red-zone \
          -mno-mmx \
          -mno-sse \
          -mno-sse2 \
          -mcmodel=kernel \
          -nostdlib \
          -nostdinc \
          -I$(INCLUDE_DIR) \
          -Wall \
          -Wextra \
          -O2

# Linker flags
LDFLAGS := -nostdlib \
           -z max-page-size=0x1000 \
           -T $(BOOT_DIR)/linker.ld

# Find source files
ASM_SOURCES := $(wildcard $(BOOT_DIR)/*.asm)
C_SOURCES := $(KERNEL_DIR)/main.c \
             $(KERNEL_DIR)/lib/string.c \
             $(KERNEL_DIR)/drivers/vga.c \
             $(KERNEL_DIR)/drivers/serial.c

# Object files
ASM_OBJECTS := $(patsubst $(BOOT_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
C_OBJECTS := $(patsubst $(KERNEL_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))

# All objects
OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

# Default target
all: $(ISO_FILE)

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)/lib
	@mkdir -p $(BUILD_DIR)/drivers

# Compile assembly files
$(BUILD_DIR)/%.o: $(BOOT_DIR)/%.asm | $(BUILD_DIR)
	@echo "AS   $<"
	@$(AS) $(ASFLAGS) $< -o $@

# Compile C files
$(BUILD_DIR)/%.o: $(KERNEL_DIR)/%.c | $(BUILD_DIR)
	@echo "CC   $<"
	@$(CC) $(CFLAGS) -c $< -o $@

# Link kernel
$(KERNEL_BIN): $(OBJECTS) | $(BUILD_DIR)
	@echo "LD   $@"
	@$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

# Create ISO image
$(ISO_FILE): $(KERNEL_BIN)
	@echo "Creating ISO image..."
	@mkdir -p $(ISO_DIR)/boot/grub
	@cp $(KERNEL_BIN) $(ISO_DIR)/boot/kernel.bin
	@cp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	@grub-mkrescue -o $(ISO_FILE) $(ISO_DIR) 2>/dev/null || \
		echo "ERROR: grub-mkrescue not found. Please install GRUB."
	@echo "ISO created: $(ISO_FILE)"

# Run in QEMU
run: $(ISO_FILE)
	@./tools/run_qemu.sh

# Clean build files
clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR) $(ISO_DIR)

# Rebuild everything
rebuild: clean all

.PHONY: all run clean rebuild
