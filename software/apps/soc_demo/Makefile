.DEFAULT_GOAL := image
.DELETE_ON_ERROR:
SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c
HISION_ROOT := $(abspath ../../..)
APP_BUILD := $(CURDIR)/build
MAP_DIR := $(HISION_ROOT)/build/soc
RUNTIME := $(HISION_ROOT)/software/runtime/soc
DRIVERS := $(HISION_ROOT)/software/drivers/soc
CROSS_COMPILE ?= riscv64-unknown-elf-
RISCV_CC ?= $(CROSS_COMPILE)gcc
RISCV_OBJCOPY ?= $(CROSS_COMPILE)objcopy
RISCV_OBJDUMP ?= $(CROSS_COMPILE)objdump
RISCV_NM ?= $(CROSS_COMPILE)nm
FLAGS := -O2 -Wall -Wextra -march=rv64im_zicsr_zifencei -mabi=lp64 -mcmodel=medany \
  -msmall-data-limit=0 -mno-relax -ffreestanding -fno-builtin -nostdlib -static
SRCS := main.c $(DRIVERS)/soc.c $(RUNTIME)/start.S
INPUTS := $(SRCS) $(DRIVERS)/soc.h $(RUNTIME)/link.ld Makefile \
  $(HISION_ROOT)/hardware/soc/config/base.json $(HISION_ROOT)/scripts/soc-config.py
.PHONY: image clean FORCE
$(APP_BUILD):
	mkdir -p "$@"
$(APP_BUILD)/.config: FORCE | $(APP_BUILD)
	python3 "$(HISION_ROOT)/scripts/soc-config.py" --out "$(MAP_DIR)"
	@key=$$(python3 "$(HISION_ROOT)/scripts/fingerprint.py" \
	  --value="$(RISCV_CC),$(FLAGS),$$($(RISCV_CC) --version | head -1)" $(INPUTS)); \
	if [[ ! -f "$@" || "$$(cat "$@")" != "$$key" ]]; then printf '%s\n' "$$key" > "$@"; fi
$(APP_BUILD)/soc_demo.elf: $(APP_BUILD)/.config
	$(RISCV_CC) $(FLAGS) -I"$(DRIVERS)" -I"$(MAP_DIR)" \
	  -Wl,--build-id=none -Wl,--defsym=__ddr_base=$$(python3 "$(HISION_ROOT)/scripts/soc-config.py" --get ddr_base) \
	  -Wl,-Map,$(APP_BUILD)/soc_demo.map -T "$(RUNTIME)/link.ld" $(SRCS) -o "$@"
$(APP_BUILD)/soc_demo.bin: $(APP_BUILD)/soc_demo.elf
	$(RISCV_OBJCOPY) -O binary "$<" "$@"
$(APP_BUILD)/soc_demo.txt: $(APP_BUILD)/soc_demo.elf
	$(RISCV_OBJDUMP) -d "$<" > "$@"
$(APP_BUILD)/soc_demo.memory.txt: $(APP_BUILD)/soc_demo.elf
	$(RISCV_NM) -n "$<" > "$@"
image: $(APP_BUILD)/soc_demo.bin $(APP_BUILD)/soc_demo.txt $(APP_BUILD)/soc_demo.memory.txt
	@echo "JTAG image: $(APP_BUILD)/soc_demo.bin"
	@echo "Ensure __app_ram_end (soc_demo.memory.txt) is within the board's DDR aperture."
clean:
	rm -rf -- "$(APP_BUILD)"
