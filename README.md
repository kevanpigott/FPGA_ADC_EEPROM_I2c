# FPGA_ADC_EEPROM_I2c
reads data from adc into FPGA writes that data onto EEPROM I2c
FPGA explanation

<b>ADC_MCP3002_Controller:</b>
	Communicates with real chip
	Outputs 10 bits of data

<b>Ignore_2:</b>
	Drops the 2 lowest bits cause we dont need them

<b>displayEncoder/display:</b>
	Displays the current value read from the adc onto the HEX display
	0 = 0V
	255 = 5.5V (voltage out of FPGA is 5.5V)
<b>Virtual mem:</b>
	Saves 255 bytes read from adc

<b>EEPROM_TASK_MANAGER:</b>
	Reads from virtual memory
	Handles communication order
	Sends a com[mand]  (an op code) to task_controller

<b>Task_controller:</b>
	Turns a com[mand] into either a falling edge, rising edge, one or zero
	Translates this into SDA and SCL


<b>Full process step by step:</b>

1.ADC_MCP3002 controller sneds start signal to ADC chip
2.ADC chip sends data
3.ADC controller says data is valid
4.Virtual mem sees data is valid, saves it to address zero and prepares next address
5.Return to step 3 until 255 bytes are stored to virtual mem
6.Virtual mem lets everyone know it is full, every memory address has been written
7.Task manager sees virtual mem is full, asks for address zero
8.Virtual mem sends address zero
9.Task manager receives it
10.Sends start command to task controller
11.Task controller sends start command to physical chip
12.Task controller says task is complete
13.Task manager sees task is complete , restart from step 10 with next command until end
14.Task controller tells virtual mem it is done writing address zero to physical chip
15.Go back to step 8, where virtual mem sends next address until all memory is written
