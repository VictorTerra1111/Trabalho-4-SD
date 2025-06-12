module fpu( 
    input logic [31:0] op_A_in, 
    input logic [31:0] op_B_in,
    input logic clock100KHz, 
    input logic reset, 
    output logic [31:0] data_out, 
    output logic [3:0] status_out
);

/*
exp_result <= 6'b111111 ? 
exp_result >= 63 

sinal caso resultado seja 0,0
estudar porque existe +0,0 e -0,0 

maior expoente: -31 colocar constantes 
menor expoente: 32

bias: 31 
*/
typedef enum logic [1:0] { EXACT, INEXACT, OVERFLOW, UNDERFLOW } status_t;
typedef enum logic [2:0] { MOD_EXPO, OPERACAO, AR_EXPO, ARREDONDA, PARA_STATUS } state_t;

state_t current_state;

logic [5:0] expA, expB, exp_result, exp_diff;
logic [25:0] mantA, mantB, mantA_shifted, mantB_shifted;
logic [26:0] mant_result_temp;
logic [24:0] mant_result;
logic sinalA, sinalB, sinal_result;
logic mantA_gt_mantB;
logic arredondou;

assign sinalA = op_A_in[31];
assign expA   = op_A_in[30:25];
assign mantA  = {1'b1, op_A_in[24:0]};

assign sinalB = op_B_in[31];
assign expB   = op_B_in[30:25];
assign mantB  = {1'b1, op_B_in[24:0]};

always @(posedge clock100KHz or negedge reset) begin
    if (!reset) begin
        current_state      <= MOD_EXPO;
        data_out           <= 32'b0;
        status_out         <= EXACT;
        exp_result         <= 6'b0;
        mantA_shifted      <= 26'b0;
        mantB_shifted      <= 26'b0;
        mant_result_temp   <= 27'b0;
        mant_result        <= 25'b0;
        sinal_result       <= 1'b0;
        exp_diff           <= 6'b0;
        arredondou         <= 1'b0;
    end else begin
        case (current_state)
            MOD_EXPO: begin
                arredondou <= 1'b0;  // reset sinal de arredondamento
                if (expA > expB) begin
                    exp_diff         <= expA - expB;
                    mantB_shifted    <= mantB >> exp_diff;
                    mantA_shifted    <= mantA;
                    exp_result       <= expA;
                end else if (expB > expA) begin
                    exp_diff         <= expB - expA;
                    mantA_shifted    <= mantA >> exp_diff;
                    mantB_shifted    <= mantB;
                    exp_result       <= expB;
                end else begin
                    mantA_shifted    <= mantA;
                    mantB_shifted    <= mantB;
                    exp_result       <= expA;
                end
                current_state <= OPERACAO;
            end

            OPERACAO: begin
                if (sinalA == sinalB) begin
                    mant_result_temp <= mantA_shifted + mantB_shifted;
                    sinal_result     <= sinalA;
                end else begin
                    if (mantA_shifted >= mantB_shifted) begin
                        mant_result_temp <= mantA_shifted - mantB_shifted;
                        sinal_result     <= sinalA;
                    end else begin
                        mant_result_temp <= mantB_shifted - mantA_shifted;
                        sinal_result     <= sinalB;
                    end
                end
                current_state <= AR_EXPO;
            end

            AR_EXPO: begin
                if (mant_result_temp[26]) begin
                    mant_result_temp <= mant_result_temp >> 1;
                    exp_result       <= exp_result + 1;
                end else begin
                    while (mant_result_temp[25] == 0 && exp_result > 0) begin
                        mant_result_temp <= mant_result_temp << 1;
                        exp_result       <= exp_result - 1;
                    end
                end
                mant_result    <= mant_result_temp[24:0];
                current_state  <= ARREDONDA;
            end

            ARREDONDA: begin
                if (mant_result_temp[0]) begin
                    mant_result <= mant_result + 1;
                    arredondou  <= 1'b1;

                    if ((mant_result + 1) == 25'b1000000000000000000000000) begin
                        mant_result <= (mant_result + 1) >> 1;
                        exp_result  <= exp_result + 1;
                    end
                end else begin
                    arredondou <= 1'b0;
                end
                current_state <= PARA_STATUS;
            end

            PARA_STATUS: begin
                data_out   <= {sinal_result, exp_result, mant_result};
                if (exp_result > 6'b111111) begin
                    status_out <= OVERFLOW;
                end else if (exp_result == 0 && mant_result != 0) begin
                    status_out <= UNDERFLOW;
                end else if (arredondou) begin
                    status_out <= INEXACT;
                end else begin
                    status_out <= EXACT;
                end
                current_state <= MOD_EXPO;
            end

            default: current_state <= MOD_EXPO;
        endcase
    end
end

endmodule
