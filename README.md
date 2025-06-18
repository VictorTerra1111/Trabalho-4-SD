# Aritmética de Ponto Flutuante (FPU)
João Victor Terra Pereira - Sistemas Digitais 2025/1

## 🖋️ Objetivo
  O objetivo deste trabalho é implementar uma FPU única e simplificada, personalizada para cada estudante integrante da disciplina. Cada estudante terá um formato de fpu diferente, sendo X o valor do expoente, Y o valor da mantissa e o bit mais significativo o sinal do número.
  Para determinar o valor de X, utilize a fórmula X = [8 (+/-) ∑b mod 4], onde ∑b representa a soma de todos os dígitos de seu número de matrícula (base 10) e mod 4 representa o resto da divisão inteira por 4. O sinal + ou - é determinado por seu dígito verificador do número de matrícula: + se for ímpar, - se   for par. O valor de Y é dado por Y = 31 - X.
  
## 🟰 Cálculo de X e Y
  Sendo a matrícula 24103806-6, com o dígito verificador 6, o cálculo é:
  ∑b = 2 + 4 + 1 + 0 + 3 + 8 + 6 + 6 = 30
  30 % 4 = 2 
  sinal: 6 (par) -
  X = 8 - 2 
  X = 6 bits

  Y = 31 - 6 
  Y = 25 bits

## 🧮 Explicação Base FPU

  Uma FPU, assim como outras unidades que fazem parte de um processador, realiza cálculos baseada na formatação de palavras que recebe, operando A e operando B, devolvendo o resultado após o término da operação. Por possuir apenas a operação de adição, esta FPU não possui sinal de operação, baseando-se apenas so sinal de cada número inserido. Cada operando possui 32 bits, divididos da seguinte forma:

  Bit	Campo	Descrição

31: Sinal	
    0 = positivo, 1 = negativo;
    
30-25:	Expoente
    6 bits — valor com bias;
    
24-0: Mantissa
    25 bits — fração (com bit implícito "1").

A codificação segue o estilo IEEE-754, com sinal, expoente com bias e mantissa fracionária.

O bias do expoente é 31 


## 🤖 Esquemático

### Entradas 
  clk100Khz — Clock de 100 KHz

  reset — Reset assíncrono, ativo em nível baixo (LOW)

   op_A_in — Operando A (32 bits)

   op_B_in — Operando B (32 bits)
   
### Saídas
data_out: Representa o resultado da operação e possui a mesma codificação dos operandos.

status_out: Possui 4 bits e expõe informações sobre o resultado calculado pela FPU no estilo
one-hot (1 bit por estado, com sobreposição). Os possíveis estados são EXACT, OVERFLOW,
UNDERFLOW, INEXACT. EXACT: O resultado foi representado corretamente pela
configuração de ponto flutuante e não foi utilizado arredondamento. OVERFLOW e
UNDERFLOW: O aluno deverá identificar corretamente quando cada um dos casos ocorrerá.
INEXACT: O resultado sofreu erro de arredondamento.

## Faixa Representada 
expoente: -31 - +32

maior valor representável:
8.589934592 × 10^9

Menor valor normalizado:
4.656612873 × 10^-10


## Como executar 
Inicie o Questa e entre na pasta 'sim' 
comando:
do sim.do 

