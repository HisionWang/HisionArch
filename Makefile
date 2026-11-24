# HisionArch: accelerator hardware, software, and reproducible system experiments.
.DEFAULT_GOAL := help
SHELL := /bin/bash

export BUILD_DIR ?= $(CURDIR)/build
export DEPS_DIR ?= $(CURDIR)/.deps
export JOBS ?= 8
export WITH_DIFFTEST ?= 1
export WITH_WAVE ?= 1
APP ?= hello
MODE ?= emu

.PHONY: deps rtl emu app run cpu-baseline clean clean-all clean-apps clean-compare help
deps:
	bash scripts/deps.sh

rtl:
	bash scripts/elaborate.sh $(MODE)

emu:
	bash scripts/build-emu.sh

app:
	bash scripts/application.sh build "$(APP)"

run:
	bash scripts/application.sh run "$(APP)"

cpu-baseline:
	$(MAKE) -C experiments/cpu-baseline run APP="$(APP)" BUILD_DIR="$(CURDIR)/experiments/cpu-baseline/build"

clean:
	bash scripts/clean.sh

clean-all:
	$(MAKE) clean
	$(MAKE) clean-apps
	$(MAKE) clean-compare

clean-apps:
	@set -e; for app in $(patsubst %/Makefile,%,$(wildcard software/apps/*/Makefile)); do \
	  $(MAKE) -C "$$app" clean; \
	done

clean-compare:
	$(MAKE) -C experiments/cpu-baseline clean BUILD_DIR="$(CURDIR)/experiments/cpu-baseline/build"

help:
	@echo "HisionArch: accelerator and memory-system research"
	@echo "make deps          Initialize and check the pinned CPU submodule"
	@echo "make rtl           Generate RTL (MODE=emu, compare, fpga, or soc)"
	@echo "make emu           Build the CPU baseline simulator: build/emu"
	@echo "  WITH_DIFFTEST=0/1 WITH_WAVE=0/1 JOBS=N"
	@echo "  Tools: SBT, VERILATOR; paths: BUILD_DIR, DEPS_DIR"
	@echo "make app APP=hello Build an application in software/apps/<name>/build/"
	@echo "make run APP=hello Run an already built application and simulator"
	@echo "make cpu-baseline APP=coremark  Run the optional CPU comparison experiment"
	@echo "make soc-rtl       Generate the DDR-boot CPU RTL for the new SoC"
	@echo "make soc-app       Build the UART echo / LED heartbeat application"
	@echo "make fpga-check    List missing board resources (TARGET=.../target.tcl)"
	@echo "make fpga-project  Generate the Vivado project and block design through Tcl"
	@echo "make fpga-synth    Create a fresh project and synthesize it"
	@echo "make fpga-bitstream Create a fresh project, implement and write the bitstream"
	@echo "make clean         Remove the root build/ and Scala caches"
	@echo "make clean-all     Also remove app and comparison builds; retain results and dependencies"
	@echo "make clean-apps    Remove all apps' build products"
	@echo "make clean-compare Remove comparison build products"
	@echo
	@echo "Start here: README.md and docs/README.md"

# CPU SoC uses the canonical build/ path for Tcl/RTL/software handoff.
TARGET ?= fpga/targets/template/target.tcl
VIVADO ?= vivado
.PHONY: soc-config soc-rtl soc-app fpga-check fpga-project fpga-synth fpga-bitstream
soc-config:
	python3 scripts/soc-config.py --out "$(CURDIR)/build/soc"

soc-rtl:
	BUILD_DIR="$(CURDIR)/build" bash scripts/elaborate.sh soc

soc-app:
	$(MAKE) -C software/apps/soc_demo image

fpga-check:
	tclsh fpga/scripts/check_target.tcl "$(TARGET)"

fpga-project: fpga-check soc-rtl
	$(VIVADO) -mode batch -nojournal -nolog -source fpga/scripts/create_project.tcl -tclargs "$(TARGET)" project "$(JOBS)"

fpga-synth: fpga-check soc-rtl
	$(VIVADO) -mode batch -nojournal -nolog -source fpga/scripts/create_project.tcl -tclargs "$(TARGET)" synth "$(JOBS)"

fpga-bitstream: fpga-check soc-rtl
	$(VIVADO) -mode batch -nojournal -nolog -source fpga/scripts/create_project.tcl -tclargs "$(TARGET)" bitstream "$(JOBS)"
