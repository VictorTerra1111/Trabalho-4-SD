module fpu(
    input  logic [31:0] op_A_in, 
    input  logic [31:0] op_B_in,
    input  logic clock100KHz, 
    input  logic reset, 
    output logic [31:0] data_out, 
    output logic [3:0]  status_out
);

    typedef enum logic [3:0] { 
        EXACT     = 4'b0001,
        INEXACT   = 4'b0010, 
        OVERFLOW  = 4'b0100, 
        UNDERFLOW = 4'b1000
    } status_out_t;

    typedef enum logic [2:0] { 
        MOD_EXPO, OPERACAO, AR_EXPO, ARREDONDA, PARA_STATUS 
    } state_t;

    state_t       current_state;
    status_out_t  send_status;

    logic [5:0]   expA, expB, exp_result, exp_dif;
    logic [24:0]  mant_result, mant_temp;
    logic [25:0]  mantA, mantB, mantA_shifted, mantB_shifted;
    logic [26:0]  mant_result_temp;
    logic         sinalA, sinalB, sinal_result;
    logic         arredondou, bit_overflow, perdeu_bits;

    assign sinalA = op_A_in[31];
    assign expA   = op_A_in[30:25];
    assign mantA  = {1'b1, op_A_in[24:0]};

    assign sinalB = op_B_in[31];
    assign expB   = op_B_in[30:25];
    assign mantB  = {1'b1, op_B_in[24:0]};

    always @(posedge clock100KHz or negedge reset) begin
        if (!reset) begin
            current_state     <= MOD_EXPO;
            send_status       <= EXACT;
            bit_overflow      <= 1'b0;
            arredondou        <= 1'b0;
            perdeu_bits       <= 1'b0;
            sinal_result      <= 1'b0;
            exp_dif           <= 6'b0;
            exp_result        <= 6'b0;
            mant_result       <= 25'b0;
            mantA_shifted     <= 26'b0;
            mantB_shifted     <= 26'b0;
            mant_result_temp  <= 27'b0;
            mant_temp         <= 25'b0;
            data_out          <= 32'b0;
            status_out        <= 4'b0000;
        end else begin
            case (current_state)
                MOD_EXPO: begin
                    arredondou   <= 1'b0;
                    bit_overflow <= 1'b0;
                    perdeu_bits  <= 1'b0;

                    if (expA > expB) begin
                        exp_dif <= expA - expB;
                        if (exp_dif > 6'd26) begin
                            mantB_shifted <= 26'd0;
                            perdeu_bits   <= (mantB != 26'd0) ? 1'b1 : 1'b0;
                        end else begin
                            mantB_shifted <= mantB >> exp_dif;
                            perdeu_bits   <= (mantB[exp_dif-1:0]) ? 1'b1 : 1'b0;
                        end
                        mantA_shifted <= mantA;
                        exp_result    <= expA;
                    end 
                    else if (expB > expA) begin
                        exp_dif <= expB - expA;
                        if (exp_dif > 6'd26) begin
                            mantA_shifted <= 26'd0;
                            perdeu_bits   <= (mantA != 26'd0) ? 1'b1 : 1'b0;
                        end else begin
                            mantA_shifted <= mantA >> exp_dif;
                            perdeu_bits   <= (mantA[exp_dif-1:0]) ? 1'b1 : 1'b0;
                        end
                        mantB_shifted <= mantB;
                        exp_result    <= expB;
                    end 
                    else begin
                        mantA_shifted <= mantA;
                        mantB_shifted <= mantB;
                        exp_result    <= expA;
                        perdeu_bits   <= 1'b0;
                    end

                    current_state <= OPERACAO;
                end

                OPERACAO: begin
                    if (sinalA == sinalB) begin
                        mant_result_temp <= mantA_shifted + mantB_shifted;
                        sinal_result      <= sinalA;
                    end else begin
                        if (mantA_shifted >= mantB_shifted) begin
                            mant_result_temp <= mantA_shifted - mantB_shifted;
                            sinal_result      <= sinalA;
                        end else begin
                            mant_result_temp <= mantB_shifted - mantA_shifted;
                            sinal_result      <= sinalB;
                        end
                    end
                    current_state <= AR_EXPO;
                end

                AR_EXPO: begin
                    if (exp_result >= 6'd63) begin
                        bit_overflow     <= 1'b1;
                        mant_result_temp <= 27'd0;
                        current_state    <= PARA_STATUS;
                    end 
                    else if (mant_result_temp[26]) begin
                        mant_result_temp <= mant_result_temp >> 1;
                        exp_result       <= exp_result + 1;
                        current_state    <= AR_EXPO;
                    end 
                    else if (mant_result_temp[25] == 0) begin
                        if (exp_result == 6'd0) begin
                            mant_result_temp <= 27'd0;
                            current_state    <= PARA_STATUS;
                        end else begin
                            mant_result_temp <= mant_result_temp << 1;
                            exp_result       <= exp_result - 1;
                            current_state    <= AR_EXPO;
                        end
                    end 
                    else begin
                        mant_result    <= mant_result_temp[24:0];
                        current_state  <= ARREDONDA;
                    end
                end

                ARREDONDA: begin
                    mant_temp <= mant_result;

                    if (mant_result_temp[0]) begin
                        mant_temp  <= mant_result + 1;
                        arredondou <= 1'b1;

                        if (mant_temp == 25'b1000000000000000000000000) begin
                            mant_result <= mant_temp >> 1;
                            if (exp_result == 6'd63) begin
                                bit_overflow <= 1'b1;
                            end else begin
                                exp_result <= exp_result + 1;
                            end
                        end else begin
                            mant_result <= mant_temp;
                        end
                    end 
                    else begin
                        arredondou  <= 1'b0;
                        mant_result <= mant_result;
                    end

                    if (exp_result >= 6'd63) begin
                        bit_overflow <= 1'b1;
                    end

                    current_state <= PARA_STATUS;
                end

                PARA_STATUS: begin
                    data_out    <= {sinal_result, exp_result, mant_result};
                    send_status <= EXACT;

                    if (mant_result == 25'd0 && exp_result == 6'd0) begin
                        data_out    <= 32'd0;
                        send_status <= EXACT;
                    end 
                    else if (bit_overflow) begin
                        data_out    <= 32'd0;
                        send_status <= OVERFLOW;
                    end 
                    else if (exp_result == 6'd0) begin
                        data_out    <= 32'd0;
                        send_status <= UNDERFLOW;
                    end 
                    else if (arredondou || perdeu_bits) begin
                        send_status <= INEXACT;
                    end

                    status_out    <= send_status;
                    current_state <= MOD_EXPO;
                end

                default: current_state <= MOD_EXPO;
            endcase
        end
    end

endmodule
