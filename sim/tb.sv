`timescale 1us/1ns

module tb_fpu;
    logic [31:0]op_A_in; 
    logic [31:0]op_B_in; 

    logic clock100KHz;
    logic reset;

    logic [31:0] data_out;
    logic [3:0] status_out; 
    logic flags_out;

fpu dut (
    .op_A_in(op_A_in), 
    .op_B_in(op_B_in), 
    .clock100KHz(clock100KHz),
    .reset(reset),
    .data_out(data_out),
    .status_out(status_out), 
    .flags_out(flags_out)
);

initial clk_10KHz = 0;
always #50 clk_10KHz = ~clk_10KHz;

initial begin
    
    #100;
    $finish;
end
endmodule