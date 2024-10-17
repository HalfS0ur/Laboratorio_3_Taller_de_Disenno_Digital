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
        valor_MOSI = dut.MOSI.value
        dut.MISO.value = not(valor_MOSI) # Se invierte el valor del MOSI para meterlo por el MISO
        await Timer(1, units='ns')  # Actualizar cada 1 ns

@cocotb.test()
async def prueba_transmisiones_secuenciales(dut):
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
    dut.entrada_i.value = 0xFD1 # Instrucción para transmitir 256 datos
    cocotb.start_soon(miso_mosi_monitor(dut))
    await FallingEdge(dut.clk_i)

    # Leer la instrucción para determinar cuando se terminaron de enviar los datos
    dut.wr_i.value = 0
    dut.reg_sel_i.value = 0
    bandera_control = 1
    while bandera_control != 0:
        bandera_control = (dut.salida_o.value & 1)
        await FallingEdge(dut.clk_i)

    # Verificar que los datos guardados en el registro de datos sean correctos
    valor_esperado = 0xFF
    dut.reg_sel_i.value = 1
    await FallingEdge(dut.clk_i)
    for j in range (NUM_PRUEBAS):
        dut.addr_i.value = j
        await FallingEdge(dut.clk_i)
        assert (dut.salida_o.value & 0xFF) == valor_esperado, f"ERROR: El valor esperado en la dirección de memoria {dut.addr_i.value} es {valor_esperado}, se recibió {dut.salida_o.value}"
        valor_esperado -= 1