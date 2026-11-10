`timescale 1ns / 1ps

module sign_mag_adder #(
    parameter int N = 4  // One sign bit and N-1 magnitude bits, N >= 2.
) (
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    output logic [N-1:0] sum
);
    logic [N-2:0] mag_a, mag_b;
    logic [N-2:0] mag_sum;
    logic sign_a, sign_b, sign_sum;

    assign {sign_a, mag_a} = a;
    assign {sign_b, mag_b} = b;

    always_comb begin
        if (sign_a == sign_b) begin
            // The magnitude wraps if the addition exceeds N-1 bits.
            mag_sum  = mag_a + mag_b;
            sign_sum = sign_a;
        end else if (mag_a >= mag_b) begin
            mag_sum  = mag_a - mag_b;
            sign_sum = sign_a;
        end else begin
            mag_sum  = mag_b - mag_a;
            sign_sum = sign_b;
        end
    end

    assign sum = {sign_sum & (|mag_sum), mag_sum};
endmodule
