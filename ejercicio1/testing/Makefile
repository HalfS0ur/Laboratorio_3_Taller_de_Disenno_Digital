# Cocotb makefile
export PYTHONPATH := $(PWD):$(PYTHONPATH)

TOPLEVEL_LANG = verilog
VERILOG_SOURCES += $(PWD)/../*.sv
TOPLEVEL = top_controlador_SPI
MODULE = ejercicio1_tb
WAVES = 1

include $(shell cocotb-config --makefiles)/Makefile.sim