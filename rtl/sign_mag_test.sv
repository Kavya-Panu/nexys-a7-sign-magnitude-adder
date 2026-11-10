`timescale 1ns / 1ps

module sign_mag_test (
    input  logic       clk,
    input  logic [9:0] sw,
    output logic [7:0] sseg,
    output logic [7:0] an
);
    logic [3:0] a, b, sum, selected;
    logic [7:0] pattern_mag, pattern_sign;
    logic [1:0] active_anodes;

    assign a = sw[3:0];
    assign b = sw[7:4];

    sign_mag_adder sum_unit (
        .a(a),
        .b(b),
        .sum(sum)
    );

    always_comb begin
        case (sw[9:8])
            2'b00:          selected = a;
            2'b01:          selected = b;
            2'b10, 2'b11:   selected = sum;
            default:        selected = '0;
        endcase
    end

    hex_seven_seg mag_sseg_unit (
        .hex({1'b0, selected[2:0]}),
        .dp(1'b1),
        .sseg(pattern_mag)
    );

    // Light only the middle segment for a nonzero negative value.
    assign pattern_sign = selected[3] && (|selected[2:0]) ? 8'hBF : 8'hFF;

    disp_mux display_unit (
        .clk(clk),
        .reset(1'b0),
        .in0(pattern_mag),
        .in1(pattern_sign),
        .an(active_anodes),
        .sseg(sseg)
    );

    assign an = {6'b111111, active_anodes};
endmodule
