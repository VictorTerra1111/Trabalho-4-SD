module fpu(
    input logic [31:0]op_A_in,  // expoente
    input logic [31:0]op_B_in, // mantica

    input logic clock100KHz,
    input logic reset,

    output logic [31:0] data_out,
    output logic [3:0] status_out, 
    output logic flags_out
);
    
    typedef enum logic {
        EXACT, //deu tudo certo
        INEXACT, //arredondou
        OVERFLOW, //passou do tamanho (62)
        UNDERFLOW //menor que o 1
    } states_t; 

    states_t c_state;

    logic [4:0] expA, expB, exp_out;
    logic [26:0] mantA, mantB, mant_out;
    logic sinal_out, sinalA, sinalB;
    
    always @(posedge clock100KHz, negedge reset) begin
        if(reset) begin
            flags_out <= 0;
        end else begin
            expA <= op_A_in[30:25];
            expB <= op_B_in[30:25]; 

            mantA <= op_A_in[24:0];
            mantB <= op_B_in[24:0]; 
            sinalA <= op_A_in[31];
            sinalB <= op_B_in[31]; 

            if(expA == expB && sinalA == sinalB) begin
                mant_out <= mantA + mantB; 
            end else if (mantA < mantB) begin
                mant_out <= mantB - mantA;
                sinal_out <= sinalB; 
            end else if (mantB < mantA) begin
                mant_out <= mantA - mantB; 
                sinal_out <= sinalA;
            end
            case c_state
                EXACT: 
                INEXACT: 
                OVERFLOW:
                UNDERFLOW:
                default:
            endcase
        end
    end
endmodule
