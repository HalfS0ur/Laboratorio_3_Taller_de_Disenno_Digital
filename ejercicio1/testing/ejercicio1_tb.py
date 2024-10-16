import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.clock import Clock

async def iniciar_reloj(dut, periodo = 100, unidad = 'ns'):
    clock = Clock(dut.clk_i, periodo, unidad)
    await cocotb.start(clock.start())

async def reiniciar_sistema(dut):
    dut.rst_i.value = 1
    dut.MISO.value = 0
    dut.reg_sel_i.value = 0
    dut.wr_i.value = 0
    dut.entrada_i.value = 0
    dut.addr_i.value = 0
    await Timer(400, units = 'ns')
    dut.rst_i.value = 0