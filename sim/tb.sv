`timescale 1ns/1ps

module tb;

    logic [31:0] op_A_in; 
    logic [31:0] op_B_in; 
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

    task automatic apply_inputs(
        input [31:0] A,
        input [31:0] B,
        input string label
    );
        begin
            op_A_in <= A;
            op_B_in <= B;
            $display(">>> TESTE: %s", label);
            #1000;  
            $display("A: %b", A);
            $display("B: %b", B);
            $display("Saída: %b", data_out);
            $display("Status: %b\n", status_out);
        end
    endtask

    initial begin
        reset = 1;
        op_A_in = 32'b0;
        op_B_in = 32'b0;
        #20;
        reset = 0;
        #100;
        reset = 1;
        #50;

        apply_inputs(32'b0, 32'b0, "+0 + +0");
        #100;
        apply_inputs({1'b0, 6'd31, 25'd0}, {1'b0, 6'd31, 25'd0}, "+1 + +1");
        #100;
        apply_inputs({1'b0, 6'd31, 25'd0}, {1'b1, 6'd31, 25'd0}, "+1 + -1");
        #100;
        apply_inputs({1'b0, 6'd50, 25'd100}, {1'b0, 6'd10, 25'd100}, "Expoentes muito diferentes");
        #100;
        apply_inputs({1'b0, 6'd31, 25'd5000000}, {1'b0, 6'd31, 25'd1000000}, "Normalização à esquerda");
        #100;
        apply_inputs({1'b0, 6'd31, 25'b0111111111111111111111111}, {1'b0, 6'd31, 25'b0000000000000000000000001}, "Arredondamento");
        #100;
        apply_inputs({1'b0, 6'd63, 25'b1111111111111111111111111}, {1'b0, 6'd63, 25'b1111111111111111111111111}, "Overflow");
        #100;
        apply_inputs({1'b0, 6'd1, 25'd1}, {1'b1, 6'd1, 25'd0}, "Underflow");
        #100;
        apply_inputs({1'b1, 6'd32, 25'd0}, {1'b1, 6'd32, 25'd0}, "-2 + -2");
        #100;
        apply_inputs({1'b0, 6'd33, 25'd0}, {1'b1, 6'd32, 25'd0}, "+4 - (+2)");
        #1000;
        $finish;
    end
endmodule
