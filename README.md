# RISC-V Processor FPGA Implementation

This project implements a single-cycle RISC-V processor on a Basys 3 FPGA. The project is divided into three distinct tasks (A, B, and C) to demonstrate various stages of processor development, from a baseline implementation to extended custom instructions and stack-based program execution.

## Project Structure

- **Task A**: Baseline single-cycle RISC-V core. Includes foundational modules such as the ALU, Control Units, Program Counter, Register File, Data Memory, and Instruction Memory. It also features memory-mapped I/O to interface with the board's LEDs and Seven-Segment Displays.
- **Task B**: Extended processor with interactive RISC-V instructions. Adds support for new instructions including:
  - `BGE` (Branch if Greater Than or Equal)
  - `SLLI` (Shift Left Logical Immediate)
  - `SRLI` (Shift Right Logical Immediate)
  - `LUI` (Load Upper Immediate)
  This task features an interactive assembly program that reads hardware switch inputs to perform conditional bitwise shifts and arithmetic operations, with results displayed in hexadecimal on the four-digit seven-segment display.
- **Task C**: Advanced implementation demonstrating stack-based program execution. Includes support for function calls, stack pointer (`sp`) manipulation, and memory operations for saving/restoring registers across function boundaries.
- **Bitstreams**: Pre-compiled `.bit` files for programming the Basys 3 FPGA directly without needing to re-synthesize the project.

## Hardware Used
- **FPGA Board**: Digilent Basys 3 (Artix-7 FPGA)
- **Inputs**: 16 toggle switches, push buttons.
- **Outputs**: 4-digit 7-segment display, 16 LEDs.

## Core Architecture & Modules
The implementation is structured around several modular Verilog components:
- `TopLevelFPGA.v` / `TopLevelProcessor.v`: Top-level wrappers integrating the datapath, control, and memory components.
- `ALU.v` & `ALUControl.v`: The Arithmetic Logic Unit and its instruction-specific decoding control logic.
- `MainControl.v`: Generates main control signals based on the instruction opcode.
- `RegisterFile.v`: 32x32-bit register file for RISC-V.
- `DataMemory.v` & `instructionMemory.v`: Memory blocks for data storage and instruction storage respectively.
- `addressDecoderTop.v`: Maps hardware I/O devices (switches, LEDs, displays) to specific memory addresses.
- `SevenSegController.v`: Multiplexes and drives the 4-digit seven-segment display.
- `clk_divider.v`: Generates lower frequency clocks from the main 100MHz board clock for processor execution and display refresh.

## Simulation and Testing
Testbenches (e.g., `TopLevelProcessor_tb.v`) are provided for simulating the datapath and verifying the instruction fetch, decode, execute, and write-back cycles. You can visualize instruction fetches and datapath execution in Vivado's waveform viewer before hardware synthesis.

## Synthesis & Deployment
To run this project on hardware:
1. Open Xilinx Vivado.
2. Create a new project and add the `.v` source files for the specific task you want to run.
3. Add the corresponding constraint file (`.xdc`) for the Basys 3 board.
4. Run **Synthesis**, **Implementation**, and generate the **Bitstream**.
5. Connect the Basys 3 board and program it using the Vivado **Hardware Manager**.

Alternatively, you can program the board directly using the pre-compiled bitstreams provided in the `Bitstreams` directory.
