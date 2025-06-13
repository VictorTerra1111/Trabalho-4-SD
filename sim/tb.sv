`timescale 1ns/1ps

module tb;

    logic [31:0]op_A_in; 
    logic [31:0]op_B_in; 
    logic clock100KHz;
    logic reset;
    logic [31:0] data_out;
    logic [3:0] status_out; 

    fpu dut (
        .op_A_in(op_A_in), 
        .op_B_in(op_B_in), 
        .clock100KHz(clock100KHz),
        .reset(reset),
        .data_out(data_out),
        .status_out(status_out) 
    );

    initial clock100KHz = 0;
    always #5 clock100KHz = ~clock100KHz;

    initial begin
        reset = 0;
        #10;
        reset = 1;
        #10;
        reset = 0;
        
        #100;
        $finish;
    end
endmodule