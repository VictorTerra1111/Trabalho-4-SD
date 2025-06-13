# Aritmética de Ponto Flutuante
João Victor Terra Pereira - Sistemas Digitais 2025/1

## 🧮 Explicação Base FPU


## 🖋️ Objetivo
  O objetivo deste trabalho é implementar uma FPU única e simplificada, personalizada para cada estudante integrante da disciplina. 
  Para determinar o valor de X, utilize a fórmula X = [8 (+/-) ∑b mod 4], onde ∑b representa a soma de todos os dígitos de seu número de matrícula (base 10) e mod 4 representa o resto da divisão inteira por 4. O sinal + ou - é determinado por seu dígito verificador do número de matrícula: + se for ímpar, - se   for par. O valor de Y é dado por Y = 31 - X.

## 🤖 Esquemático


data_out: Representa o resultado da operação e possui a mesma codificação dos operandos.

status_out: Possui 4 bits e expõe informações sobre o resultado calculado pela FPU no estilo
one-hot (1 bit por estado, com sobreposição). Os possíveis estados são EXACT, OVERFLOW,
UNDERFLOW, INEXACT. EXACT: O resultado foi representado corretamente pela
configuração de ponto flutuante e não foi utilizado arredondamento. OVERFLOW e
UNDERFLOW: O aluno deverá identificar corretamente quando cada um dos casos ocorrerá.
INEXACT: O resultado sofreu erro de arredondamento.

op_A_out:

op_B_out:
