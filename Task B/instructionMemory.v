`timescale 1ns / 1ps

module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  [OPERAND_LENGTH:0] instAddress,
    output [31:0] instruction
);
    reg [31:0] rom [0:63];

    initial begin
        // =============================================================
        // TASK B DEMONSTRATION PROGRAM
        // Demonstrates BGE (B-type), SLLI (I-type), SRLI (I-type),
        // and LUI (U-type) with interactive switch-based operation.
        //
        // OPERATION:
        //   1. On startup, displays 0xB005 on 7-seg/LEDs using LUI+ADDI
        //      to prove LUI works with non-zero upper bits.
        //   2. Enters interactive loop: reads switch value from addr 0x300.
        //   3. If switch value >= 8 (BGE): shift left by 1 (SLLI, x2)
        //   4. If switch value <  8:       shift right by 1 (SRLI, /2)
        //   5. Displays result on 7-seg (hex) and LEDs (binary).
        //
        // Switch mapping (priority encoder returns highest sw index + 1):
        //   SW0=1, SW1=2, ... SW6=7 (< 8 -> SRLI)
        //   SW7=8, SW8=9, ... SW15=16 (>= 8 -> SLLI)
        //
        // Expected outputs:
        //   Startup: 7-seg = B005 (LUI demo)
        //   SW0 (val=1):  SRLI -> 0   (1>>1)
        //   SW3 (val=4):  SRLI -> 2   (4>>1)
        //   SW7 (val=8):  SLLI -> 10  (8<<1 = 16 = 0x10)
        //   SW15 (val=16): SLLI -> 20  (16<<1 = 32 = 0x20)
        //
        // Registers:  x8=threshold(8), x9=display addr, x18=switch addr
        //             x1=LUI demo, x10=switch value, x6-x7=delay
        // =============================================================

        // --- Setup ---
        rom[0]  = 32'h20000493; // addi x9, x0, 0x200     | x9 = display addr
        rom[1]  = 32'h30000913; // addi x18, x0, 0x300    | x18 = switch input addr
        rom[2]  = 32'h00800413; // addi x8, x0, 8         | x8 = 8 (threshold)

        // ============= STARTUP: LUI DEMONSTRATION ======================
        // lui x1, 0x0000B -> x1 = 0x0000B000
        // addi x1, x1, 5 -> x1 = 0x0000B005
        // Display 0xB005: proves LUI loaded upper bits, ADDI added lower.
        // 7-seg shows "B005", LEDs show binary pattern.
        // ===============================================================
        rom[3]  = 32'h0000B0B7; // lui  x1, 0x0000B       | x1 = 0xB000
        rom[4]  = 32'h00508093; // addi x1, x1, 5         | x1 = 0xB005
        rom[5]  = 32'h0014A023; // sw   x1, 0(x9)         | display <- 0xB005
        rom[6]  = 32'h058000EF; // jal  ra, +88           | call DELAY (rom[28])

        // ============= INTERACTIVE LOOP ================================
        // Reads switches, compares with BGE, shifts with SLLI/SRLI.
        // ===============================================================
        // LOOP:
        rom[7]  = 32'h0004A023; // sw   x0, 0(x9)         | clear display
        // POLL:
        rom[8]  = 32'h00092503; // lw   x10, 0(x18)       | x10 = switch value
        rom[9]  = 32'hFE050EE3; // beq  x10, x0, -4       | if zero -> POLL (rom[8])

        // --- BGE: if x10 >= 8, goto SHIFT_LEFT ---
        rom[10] = 32'h00855663; // bge  x10, x8, +12      | if x10>=8 -> rom[13]

        // SHIFT_RIGHT (value < 8):
        rom[11] = 32'h00155513; // srli x10, x10, 1       | x10 = x10 >> 1
        rom[12] = 32'h0080006F; // jal  x0, +8            | goto DISPLAY (rom[14])

        // SHIFT_LEFT (value >= 8):
        rom[13] = 32'h00151513; // slli x10, x10, 1       | x10 = x10 << 1

        // DISPLAY:
        rom[14] = 32'h00A4A023; // sw   x10, 0(x9)        | display <- result
        rom[15] = 32'h034000EF; // jal  ra, +52           | call DELAY (rom[28])

        // --- Wait for switch release before looping ---
        // WAIT_RELEASE:
        rom[16] = 32'h00092283; // lw   t0, 0(x18)        | read switches
        rom[17] = 32'hFE029EE3; // bne  t0, x0, -4        | if still on -> WAIT (rom[16])
        rom[18] = 32'hFD5FF06F; // jal  x0, -44            | goto LOOP (rom[7])

        // --- padding ---
        rom[19] = 32'h00000013; // nop
        rom[20] = 32'h00000013; // nop
        rom[21] = 32'h00000013; // nop
        rom[22] = 32'h00000013; // nop
        rom[23] = 32'h00000013; // nop
        rom[24] = 32'h00000013; // nop
        rom[25] = 32'h00000013; // nop
        rom[26] = 32'h00000013; // nop
        rom[27] = 32'h00000013; // nop

        // ============= DELAY SUBROUTINE (rom[28]) ======================
        // ~0.8s at 10 MHz: 2000 * (2000*2 + ~3) = ~8,006,000 cycles
        // Uses only x6 (t1) and x7 (t2). Returns via ra.
        // ===============================================================
        rom[28] = 32'h7D000313; // addi t1, x0, 2000      | outer loop count
        // DELAY_OUTER:
        rom[29] = 32'h7D000393; // addi t2, x0, 2000      | inner loop count
        // DELAY_INNER:
        rom[30] = 32'hFFF38393; // addi t2, t2, -1        | t2--
        rom[31] = 32'hFE039EE3; // bne  t2, x0, -4        | if t2!=0 -> DELAY_INNER
        rom[32] = 32'hFFF30313; // addi t1, t1, -1        | t1--
        rom[33] = 32'hFE0318E3; // bne  t1, x0, -16       | if t1!=0 -> DELAY_OUTER
        rom[34] = 32'h00008067; // jalr x0, ra, 0         | return
    end

    // Byte-addressed PC -> word index via address[7:2]
    assign instruction = rom[instAddress[7:2]];

endmodule
