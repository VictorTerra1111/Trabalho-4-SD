module fpu(
    input logic [7:0]x_in,  // expoente
    input logic [22:0]y_in, // mantica
    input logic op,
    input logic clock,
    input logic reset,

    output logic [31:0] w_out
);


    always @(posedge clock, negedge reset) begin
        if(reset) begin
            w_out <= 0;
        end else begin
            // logica
        end
    end
endmodule