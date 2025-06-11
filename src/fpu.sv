module fpu(
    input logic [31:0]op_A_in, 
    input logic [31:0]op_B_in, 

    input logic clock100KHz,
    input logic reset,

    output logic [31:0] data_out,
    output logic [3:0] status_out, 
    output logic flags_out
);
    
    typedef enum logic {
        EXACT,      // deu tudo certo
        INEXACT,    // arredondou
        OVERFLOW,   // passou do tamanho (62)
        UNDERFLOW   // menor que o 1
    } states_t; 

    states_t c_state;

    logic [5:0] expA, expB, exp_out;
    logic [24:0] mantA, mantB, mant_out;
    logic sinal_out, sinalA, sinalB;

    always @(posedge clock100KHz, negedge reset) begin
        if(reset) begin
            flags_out <= 0;
            sinal_out <= 0;
            sinalA <= 0;
            sinalB <= 0;

            status_out <= 4'b0;
            
            expA <= 6'b0;
            expB <= 6'b0;
            exp_out <= 6'b0;
            
            mantA <= 25'b0;
            mantB <= 25'b0;
            mant_out <= 25'b0;
           
           data_out <= 32'b0;
        end else begin
            expA <= op_A_in[30:25];
            expB <= op_B_in[30:25]; 

            mantA <= op_A_in[24:0];
            mantB <= op_B_in[24:0]; 

            sinalA <= op_A_in[31];
            sinalB <= op_B_in[31]; 

            if(expA == expB) begin
                exp_out <= expA;
                if(mantA == mantB && sinalA == sinalB) begin
                    mant_out <= mantA + mantB; 
                    sinal_out <= sinalA;
                end else if (mantA < mantB) begin
                    mant_out <= mantB - mantA;
                    sinal_out <= sinalB; 
                end else if (mantB < mantA) begin
                    mant_out <= mantA - mantB; 
                    sinal_out <= sinalA;
                end
            end else begin
                
            end 
            data_out <= {sinal_out, exp_out, mant_out};
        end
    end
endmodule
