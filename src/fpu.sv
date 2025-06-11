module fpu(
    input logic [31:0]op_a_in,  // expoente
    input logic [31:0]op_b_in, // mantica
    input logic op,
    input logic clock100KHz,
    input logic reset,

    output logic [31:0] status_out, 
    output logic flags_out
);


    always @(posedge clock100KHz, negedge reset) begin
        if(reset) begin
            flags_out <= 0;
        end else begin
            // logica
        end
    end
endmodule
