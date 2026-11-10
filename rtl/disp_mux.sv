`timescale 1ns / 1ps

module disp_mux (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] in0, in1,
    output logic [1:0] an,
    output logic [7:0] sseg
);
    // Vivado maps this initial value to the FPGA flip-flop power-up state.
    logic [16:0] refresh_counter = '0;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            refresh_counter <= '0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    // Select a digit every 65,536 cycles. Both outputs are active low.
    always_comb begin
        case (refresh_counter[16])
            1'b0:    {an, sseg} = {2'b10, in0};
            1'b1:    {an, sseg} = {2'b01, in1};
            default: {an, sseg} = '1;
        endcase
    end
endmodule
