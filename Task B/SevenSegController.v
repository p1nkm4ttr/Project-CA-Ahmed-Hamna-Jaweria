`timescale 1ns / 1ps

module SevenSegController(
    input  wire        clk_100mhz,
    input  wire        rst,
    input  wire [15:0] value,       // 0-65535 displayed as 4 hex digits
    output reg  [6:0]  seg,         // active-low cathodes {g,f,e,d,c,b,a}
    output reg  [3:0]  an           // active-low anodes
);

    // --- Hex Nibble Extraction ---
    // Split 16-bit value into four 4-bit nibbles (no division needed)
    wire [3:0] d3 = value[15:12]; // leftmost  hex digit (e.g. '8' in 8000)
    wire [3:0] d2 = value[11:8];
    wire [3:0] d1 = value[7:4];
    wire [3:0] d0 = value[3:0];   // rightmost hex digit

    // --- Leading-zero blanking ---
    wire blank3 = (d3 == 4'd0);
    wire blank2 = blank3 & (d2 == 4'd0);
    wire blank1 = blank2 & (d1 == 4'd0);
    // AN0 (rightmost) is never blanked — always show at least "0"

    // --- Refresh Counter for Display Multiplexing ---
    // 100 MHz / 2^17 ~= 763 Hz refresh per digit
    reg [18:0] refresh_counter;
    wire [1:0] digit_sel = refresh_counter[18:17];

    always @(posedge clk_100mhz or posedge rst) begin
        if (rst)
            refresh_counter <= 19'd0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    // --- Digit Selection ---
    reg [3:0] current_digit;
    reg       blank_digit;

    always @(*) begin
        blank_digit = 1'b0;
        case (digit_sel)
            2'b00: begin        // AN0 (rightmost)
                an            = 4'b1110;
                current_digit = d0;
                blank_digit   = 1'b0;
            end
            2'b01: begin        // AN1
                an            = 4'b1101;
                current_digit = d1;
                blank_digit   = blank1;
            end
            2'b10: begin        // AN2
                an            = 4'b1011;
                current_digit = d2;
                blank_digit   = blank2;
            end
            2'b11: begin        // AN3 (leftmost)
                an            = 4'b0111;
                current_digit = d3;
                blank_digit   = blank3;
            end
            default: begin
                an            = 4'b1111;
                current_digit = 4'd0;
                blank_digit   = 1'b1;
            end
        endcase
    end

    // --- Seven-Segment Hex Decoder (active-low) ---
    // seg[6:0] = {g, f, e, d, c, b, a}
    always @(*) begin
        if (blank_digit) begin
            seg = 7'b1111111; // all segments off
        end else begin
            case (current_digit)
                4'h0: seg = 7'b1000000; // 0
                4'h1: seg = 7'b1111001; // 1
                4'h2: seg = 7'b0100100; // 2
                4'h3: seg = 7'b0110000; // 3
                4'h4: seg = 7'b0011001; // 4
                4'h5: seg = 7'b0010010; // 5
                4'h6: seg = 7'b0000010; // 6
                4'h7: seg = 7'b1111000; // 7
                4'h8: seg = 7'b0000000; // 8
                4'h9: seg = 7'b0010000; // 9
                4'hA: seg = 7'b0001000; // A
                4'hB: seg = 7'b0000011; // b
                4'hC: seg = 7'b1000110; // C
                4'hD: seg = 7'b0100001; // d
                4'hE: seg = 7'b0000110; // E
                4'hF: seg = 7'b0001110; // F
                default: seg = 7'b1111111;
            endcase
        end
    end

endmodule
