module fpu(
    input logic [31:0]op_A_in, 
    input logic [31:0]op_B_in, 

    input logic clock100KHz,
    input logic reset,

    output logic [31:0] data_out,
    output logic [3:0] status_out
);
    
    typedef enum logic {
        EXACT,      // deu tudo certo
        INEXACT,    // arredondou
        OVERFLOW,   // passou do tamanho (62)
        UNDERFLOW   // menor que o 1
    } states_t; 

    states_t status_out_cases;


    typedef enum logic{
        ATRIBUI,
        EXP_E,
        EXP_D
    } internal_states

    internal_states states;

    logic [5:0] expA, expB, exp_out;
    logic [24:0] mantA, mantB, mant_out;
    logic sinal_out, sinalA, sinalB;
    logic dif_casas;


    assign data_out = {sinal_out, exp_out, mant_out};
    assign expA = op_A_in[30:25];
    assign expB = op_B_in[30:25]; 
    assign mantA = op_A_in[24:0];
    assign mantB = op_B_in[24:0]; 
    assign sinalA = op_A_in[31];
    assign sinalB = op_B_in[31]; 
           
    always @(posedge clock100KHz, negedge reset) begin
        if(reset) begin
            sinal_out <= 0;
            sinalA <= 0;
            sinalB <= 0;

            expA <= 6'b0;
            expB <= 6'b0;
            exp_out <= 6'b0;
            
            mantA <= 25'b0;
            mantB <= 25'b0;
            mant_out <= 25'b0;
            
            status_out_cases <= EXACT;
            data_out <= 32'b0;
        end else begin
            case(internal_states)
                ATRIBUI: begin
                    if(expA == expB) begin
                        internal_states <= EXP_E;
                    end else internal_states <= EXP_D;
                end 
                EXP_E: begin
                        exp_out <= expA;
                        if(sinalA == sinalB) begin
                            sinal_out <= sinalA;
                        end else begin
                            if(sinalB < sinalA) begin
                                mantB <= ~mantB + 1;
                            end else if (sinalA < sinalB) begin
                                mantA <= ~mantA + 1;
                            end
                        end
                        mant_out <= mantA + mantB; 
                end
                EXP_D: begin
                    // maior expoente possivel = exp
                    if(expA < expB) begin 
                        exp_ou <= expB - expA;
                    end else begin
                         exp_out <= expA - expB;
                    end
                    // logica
                end
                default: begin
                end
            endcase
        end
    end
endmodule
