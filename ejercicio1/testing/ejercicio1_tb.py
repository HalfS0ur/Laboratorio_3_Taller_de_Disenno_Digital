import cocotb
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.clock import Clock 

NUM_PRUEBAS = 255

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

async def miso_mosi_monitor(dut):
    while True:
        dut.MISO.value = dut.MOSI.value
        await Timer(1, units='ns')  # Update every 1 ns (adjust as needed)

async def revisar_trans_completa(dut):
    while True:
        if (dut.bits_salida.value == 0):
            return("BOMBOCLAT")

@cocotb.test()
async def aver(dut):
    await iniciar_reloj(dut)
    await reiniciar_sistema(dut)

    # Escribirle datos al registro de datos
    dut.wr_i.value = 1
    dut.reg_sel_i.value = 1
    for i in range (NUM_PRUEBAS):
        dut.entrada_i.value = i
        dut.addr_i.value = i
        await FallingEdge(dut.clk_i)

    # Escribirle la instruccion para que envie los datos
    dut.wr_i.value = 1
    dut.reg_sel_i.value = 0
    dut.entrada_i.value = 0xFD1 # This means something 0xFD1
    cocotb.start_soon(miso_mosi_monitor(dut))
    #await Timer(555000, units = 'ns')
    await FallingEdge(dut.clk_i)

    # Leer la instrucción para determinar cuando se terminaron de enviar los datos
    dut.wr_i.value = 0
    dut.reg_sel_i.value = 0
    #await Timer(5000, units = 'ns')
    #cocotb.start_soon(revisar_trans_completa(dut))
    #await(revisar_trans_completa(dut))
    #await (dut.bits_salida.value == 0)
    bandera_control = 1
    while bandera_control != 0:
        bandera_control = (dut.bits_salida.value & 1)
        await FallingEdge(dut.clk_i)
        print("todavia no", bandera_control)
    await Timer(55000, units = 'ns')