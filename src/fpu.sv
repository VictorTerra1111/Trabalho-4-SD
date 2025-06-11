module fpu(
    input logic [31:0]op_a_in,  // expoente
    input logic [31:0]op_b_in, // mantica

    input logic clock100KHz,
    input logic reset,

    output logic [31:0] data_out,
    output logic [3:0] status_out, 
    output logic flags_out
);
/*
Para determinar o valor de X, utilize a fórmula X = [8 (+/-) ∑b mod 4], onde ∑b
representa a soma de todos os dígitos de seu número de matrícula (base 10) e mod 4
representa o resto da divisão inteira por 4. O sinal + ou - é determinado por seu dígito
verificador do número de matrícula: + se for ímpar, - se for par. O valor de Y é dado por
Y = 32 - X.
24103806-6 
somatório: 31 mod 4 = 3
X = 8 - 3 = 5 expoente
Y = 32 - 5 = 27 mantissa VERIFICAR TALVEZ 26

[1][00000][00000000...] 
1 - sinal (31)
5 - expoente (30-26)
27 - mantissa (0-25)

*/
    typedef enum logic {
        EXACT, //deu tudo certo
        INEXACT, //arredondamnento
        OVERFLOW, //passou do tamanho
        UNDERFLOW //menor que o limite inferior
    } states_t; 

    states_t c_state;

    logic [4:0] exp1, exp2, exp_out;
    logic [26:0] mant1, mant2, mant_out;
    
    always @(posedge clock100KHz, negedge reset) begin
        if(reset) begin
            flags_out <= 0;
        end else begin
            exp1 <= op_a_in[30:26];
            exp2 <= op_b_in[30:26]; 

            mant1 <= op_a_in[25:0];
            mant2 <= op_b_in[25:0]; 

            if(exp1 > exp2) begin 
                exp_out <= exp2;
            end 
            else if(exp1 =< exp2) begin
                exp_out <= exp1;
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
