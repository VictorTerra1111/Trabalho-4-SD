module fpu( 
    input logic [31:0] op_A_in, 
    input logic [31:0] op_B_in,
    input logic clock100KHz, 
    input logic reset, 
    output logic [31:0] data_out, 
    output logic [3:0] status_out
);

typedef enum logic [1:0] {
    EXACT,
    INEXACT,
    OVERFLOW,
    UNDERFLOW
} status_t;

typedef enum logic [2:0] {
    IDLE,
    ALIGN,
    OPERATE,
    NORMALIZE,
    ROUND,
    PACK
} state_t;

state_t current_state;
status_t status_reg;

logic [5:0] expA, expB, exp_result;
logic [25:0] mantA, mantB;
logic [26:0] mant_result_temp;
logic [24:0] mant_result;
logic sinalA, sinalB, sinal_result;
logic [5:0] exp_diff;
logic mantA_gt_mantB;
logic [25:0] mantA_shifted, mantB_shifted;

assign sinalA = op_A_in[31];
assign expA   = op_A_in[30:25];
assign mantA  = {1'b1, op_A_in[24:0]};

assign sinalB = op_B_in[31];
assign expB   = op_B_in[30:25];
assign mantB  = {1'b1, op_B_in[24:0]};

always @(posedge clock100KHz or negedge reset) begin
    if (!reset) begin
        current_state <= IDLE;
        data_out <= 32'b0;
        status_out <= EXACT;
    end else begin
        current_state <= next_state;
    end else begin
        case (current_state)
            ALIGN: begin
                if (expA > expB) begin
                    exp_diff = expA - expB;
                    mantB_shifted = mantB >> exp_diff;
                    mantA_shifted = mantA;
                    exp_result = expA;
                end else if (expB > expA) begin
                    exp_diff = expB - expA;
                    mantA_shifted = mantA >> exp_diff;
                    mantB_shifted = mantB;
                    exp_result = expB;
                end else begin
                    mantA_shifted = mantA;
                    mantB_shifted = mantB;
                    exp_result = expA;
                end
                current_state <= OPERATE;
            end
    
            OPERATE: begin
                if (sinalA == sinalB) begin
                    mant_result_temp = mantA_shifted + mantB_shifted;
                    sinal_result = sinalA;
                end else begin
                    if (mantA_shifted >= mantB_shifted) begin
                        mant_result_temp = mantA_shifted - mantB_shifted;
                        sinal_result = sinalA;
                    end else begin
                        mant_result_temp = mantB_shifted - mantA_shifted;
                        sinal_result = sinalB;
                    end
                end
            end
    
            NORMALIZE: begin
                if (mant_result_temp[26]) begin
                    mant_result_temp = mant_result_temp >> 1;
                    exp_result = exp_result + 1;
                end else begin
                    while (mant_result_temp[25] == 0 && exp_result > 0) begin
                        mant_result_temp = mant_result_temp << 1;
                        exp_result = exp_result - 1;
                    end
                end
                mant_result = mant_result_temp[24:0];
            end
    
            ROUND: begin
                // arredondar
                status_reg = EXACT;
            end
    
            PACK: begin
                if (exp_result > 6'b111111) begin
                    status_reg = OVERFLOW;
                end else if (exp_result == 0 && mant_result != 0) begin
                    status_reg = UNDERFLOW;
                end
                data_out = {sinal_result, exp_result, mant_result};
                status_out = status_reg;
            end
            default: ;
        endcase
    end
end
endmodule
