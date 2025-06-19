module fpu(
    input  logic [31:0] op_A_in, 
    input  logic [31:0] op_B_in,
    input  logic clock100KHz, 
    input  logic reset, 
    output logic [31:0] data_out, 
    output logic [3:0]  status_out
);

    typedef enum logic [2:0] { 
        MOD_EXPO, 
        OPERACAO, 
        AR_EXPO, 
        ARREDONDA, 
        PARA_STATUS 
    } state_t;

    state_t current_state;

    logic [5:0]   expA, expB, exp_result, exp_dif;
    
    logic [24:0]  mant_result;
    
    logic [25:0]  mantA, mantB, mantA_shifted, mantB_shifted;
    
    logic [26:0]  mant_result_temp;
    
    logic         sinalA, sinalB, sinal_result;
    logic         bit_overflow, bit_inexact, bit_underflow;

    assign sinalA = op_A_in[31];
    assign expA   = op_A_in[30:25];
    assign mantA = (expA == 6'd0) ? {1'b0, op_A_in[24:0]} : {1'b1, op_A_in[24:0]};

    assign sinalB = op_B_in[31];
    assign expB   = op_B_in[30:25];
    assign mantB = (expB == 6'd0) ? {1'b0, op_B_in[24:0]} : {1'b1, op_B_in[24:0]};
    
    always @(posedge clock100KHz or negedge reset) begin
        if (!reset) begin
            current_state     <= MOD_EXPO;
            bit_inexact       <= 1'b0;
            bit_overflow      <= 1'b0;
            bit_underflow     <= 1'b0;
            sinal_result      <= 1'b0;
            status_out        <= 4'b0;
            exp_dif           <= 6'b0;
            exp_result        <= 6'b0;
            mant_result       <= 25'b0;
            mantA_shifted     <= 26'b0;
            mantB_shifted     <= 26'b0;
            mant_result_temp  <= 27'b0;
            data_out          <= 32'b0;
        end else begin
            case (current_state)
                MOD_EXPO: begin
                    if (op_A_in == 32'd0 && op_B_in == 32'd0) begin
                        data_out     <= 32'd0;
                        status_out   <= 4'b0001;
                        current_state <= MOD_EXPO;
                    end else begin
                        bit_overflow <= 1'b0;
                        bit_inexact <= 1'b0;
                        bit_underflow <= 1'b0;
                        
                        if (expA > expB) begin // se expoente A for maior que B
                            exp_dif <= expA - expB; // diferenca de expoentes
    
                            if (exp_dif > 6'd26) begin
                                mantB_shifted <= 26'd0;
                                if (mantB != 0) bit_inexact <= 1'b1; 
                            end else begin
                                mantB_shifted <= mantB >> exp_dif; // shifta B
                                mantA_shifted <= mantA;
                                exp_result    <= expA;
                                 
                               for (int i = 0; i < exp_dif; i++) begin
                                   if (mantB[i]) bit_inexact <= 1'b1; // verifica se algum bit vai ser perdido
                               end
                            end
    
                            mantA_shifted <= mantA;
                            exp_result    <= expA;
                        end else if (expB > expA) begin // se expoente B for maior que A
                            exp_dif <= expB - expA; // diferenca de expoentes
    
                            if (exp_dif > 6'd26) begin
                                mantA_shifted <= 26'd0;
                                if (mantA != 0) bit_inexact <= 1'b1; 
                            end else begin
                                mantA_shifted <= mantA >> exp_dif; // shifta A
                                mantB_shifted <= mantB;
                                exp_result    <= expB;
                                
                               for (int i = 0; i < exp_dif; i++) begin
                                   if (mantA[i]) bit_inexact <= 1'b1; // verifica se algum bit vai ser perdido
                               end
                            end
                        end else begin // se expoentes forem iguais
                            mantA_shifted <= mantA;
                            mantB_shifted <= mantB;
                            exp_result    <= expA;
                        end
                        current_state <= OPERACAO;
                    end
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
                    if (mant_result_temp == 27'd0) begin
                        mant_result <= 25'd0;
                        exp_result  <= 6'd0;
                        current_state <= PARA_STATUS;
                    end else if (exp_result >= 6'd63) begin
                        bit_overflow     <= 1'b1;
                        mant_result_temp <= 27'd0;
                        current_state    <= PARA_STATUS;
                    end else if (mant_result_temp[26]) begin
                        mant_result_temp <= mant_result_temp >> 1;
                        exp_result       <= exp_result + 1;
                        current_state    <= AR_EXPO;
                    end else if (mant_result_temp[25] == 0) begin
                        if (exp_result == 6'd0) begin
                            mant_result_temp <= 27'd0;
                            bit_underflow    <= 1'b1;
                            current_state    <= PARA_STATUS;
                        end else begin
                            mant_result_temp <= mant_result_temp << 1;
                            exp_result       <= exp_result - 1;
                            current_state    <= AR_EXPO;
                        end
                    end else begin
                        mant_result   <= mant_result_temp[24:0];
                        current_state <= ARREDONDA;
                    end
                end

                ARREDONDA: begin
                    if (mant_result_temp[0]) begin
                        bit_inexact <= 1'b1;
                        mant_result <= mant_result + 1;
                
                        if (mant_result + 1 == 25'b1000000000000000000000000) begin
                            mant_result <= (mant_result + 1) >> 1;
                
                            if (exp_result == 6'd63) begin
                                bit_overflow <= 1'b1;
                            end else begin
                                exp_result <= exp_result + 1;
                            end
                        end else begin
                            mant_result <= mant_result + 1;
                        end
                    end
                
                    current_state <= PARA_STATUS;
                end

              PARA_STATUS: begin                   
                    if (bit_overflow) begin
                        data_out   <= 32'd0;
                        status_out <= 4'b0100;
                    end 
                    else if (bit_underflow) begin
                        data_out   <= 32'd0;
                        status_out <= 4'b1000;
                    end 
                    else begin
                        data_out   <= {sinal_result, exp_result, mant_result};
                        if (bit_inexact)
                            status_out <= 4'b0010;
                        else
                            status_out <= 4'b0001;
                    end
                    current_state  <= MOD_EXPO;
                end

                default: current_state <= MOD_EXPO;
            endcase
        end
    end
endmodule
