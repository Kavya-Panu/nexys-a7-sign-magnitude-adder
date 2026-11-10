`timescale 1ns / 1ps

module tb_sign_mag;
    localparam logic [7:0] DIGITS [0:7] = '{
        8'hC0, 8'hF9, 8'hA4, 8'hB0, 8'h99, 8'h92, 8'h82, 8'hF8
    };

    logic clk = 1'b0;
    logic [3:0] a = '0, b = '0;
    logic [3:0] sum;
    logic [9:0] sw = '0;
    logic [7:0] an, sseg;

    always #5 clk = ~clk;

    sign_mag_adder adder (.a(a), .b(b), .sum(sum));
    sign_mag_test board (.clk(clk), .sw(sw), .sseg(sseg), .an(an));

    function automatic int decode(input logic [3:0] value);
        int magnitude;
        magnitude = int'(value[2:0]);
        return value[3] ? -magnitude : magnitude;
    endfunction

    function automatic logic [3:0] encode_wrapped(input int value);
        int magnitude;
        magnitude = (value < 0 ? -value : value) % 8;
        return {((value < 0) && (magnitude != 0)), magnitude[2:0]};
    endfunction

    task automatic check_display_phase(input bit sign_digit);
        logic [3:0] selected;
        logic [7:0] expected_an, expected_sseg;

        expected_an = sign_digit ? 8'hFD : 8'hFE;
        wait (an === expected_an);
        for (int switches = 0; switches < 1024; switches++) begin
            sw = switches[9:0];
            case (sw[9:8])
                2'b00:   selected = sw[3:0];
                2'b01:   selected = sw[7:4];
                default: selected = encode_wrapped(decode(sw[3:0]) + decode(sw[7:4]));
            endcase

            expected_sseg = DIGITS[selected[2:0]];
            if (sign_digit)
                expected_sseg = (selected[3] && (|selected[2:0])) ? 8'hBF : 8'hFF;
            #1;
            if ({an, sseg} !== {expected_an, expected_sseg})
                $fatal(1, "sw=%b: an/sseg=%h/%h, expected %h/%h",
                       sw, an, sseg, expected_an, expected_sseg);
        end
    endtask

    initial begin
        logic [3:0] expected;
        for (int i = 0; i < 16; i++) begin
            for (int j = 0; j < 16; j++) begin
                a = i[3:0];
                b = j[3:0];
                expected = encode_wrapped(decode(a) + decode(b));
                #1;
                if (sum !== expected)
                    $fatal(1, "a=%b b=%b: sum=%b, expected %b", a, b, sum, expected);
            end
        end
        $display("PASS: all 256 encoded operand pairs");

        check_display_phase(1'b0);
        check_display_phase(1'b1);
        wait (an === 8'hFE);
        $display("PASS: all 1,024 switch states in both digit scan phases");
        $finish;
    end

    initial begin
        #2_000_000;
        $fatal(1, "Timed out waiting for the digit scan");
    end
endmodule
