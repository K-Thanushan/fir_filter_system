TOPLEVEL_LANG ?= vhdl
SIM ?= questa
PWD = $(shell pwd)
export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)
SOURCES_FOR_QUESTASIM := C:/Work/fir_filter_system

ifeq ($(TOPLEVEL_LANG), verilog)
	VERILOG_SOURCES = $(SOURCES_FOR_QUESTASIM)/rtl/fir_filter_fixed.v
else ifeq ($(TOPLEVEL_LANG), vhdl)
	VHDL_SOURCES = $(SOURCES_FOR_QUESTASIM)/packages/fir_fixed_generics_package.vhdl $(SOURCES_FOR_QUESTASIM)/packages/fixed_to_signed_package.vhdl $(SOURCES_FOR_QUESTASIM)/rtl/fir_filter_fixed.vhdl
	ifneq ($(filter $(SIM), ius xcelium),)
		COMPILE_ARGS += -2008
	endif
else
	$(error A valid value (vhdl or verilog) was not provided for TOPLEVEL_LANG=$(TOPLEVEL_LANG))
endif

TOPLEVEL := fir_filter_fixed
MODULE   := fir_matlab_test
include $(shell cocotb-config --makefiles)/Makefile.sim


graphs:
	python graphs.py

DIR := C:/Work/fir_filter_system/tb/python/fir_fixed_test
TARGETS := transcript results.xml modelsim.ini __pycache__ sim_build

clean::
	@for target in $(TARGETS); do \
		if [ -e $(DIR)/$$target ]; then \
			echo "Removing $(DIR)/$$target"; \
			rm -rf $(DIR)/$$target; \
		else \
			echo "$(DIR)/$$target does not exist"; \
		fi \
	done