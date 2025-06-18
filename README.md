# 🧠 Aritmética de Ponto Flutuante (FPU)

    João Victor Terra Pereira — Sistemas Digitais 2025/1

---
## ✍️ Objetivo

O objetivo deste trabalho é implementar uma FPU única e simplificada, personalizada para cada estudante integrante da disciplina. Cada estudante terá um formato de FPU diferente, sendo X o valor do expoente, Y o valor da mantissa e o bit mais significativo o sinal do número.

Para determinar o valor de X, utiliza-se a fórmula:
X = [8 (+/-) (∑b mod 4)], onde ∑b representa a soma de todos os dígitos da matrícula (base 10) e mod 4 representa o resto da divisão inteira por 4.

O sinal + ou - é determinado pelo dígito verificador da matrícula:

+ se for ímpar

- se for par

O valor de Y é dado por:
Y = 31 – X

---
## 🟰 Cálculo de X e Y

Sendo a matrícula 24103806-6, com dígito verificador 6, temos:

Somatório dos dígitos: 2 + 4 + 1 + 0 + 3 + 8 + 6 + 6 = 30
  30 % 4 = 2 
  
  Sinal: 6 (par) -
  X = 8 - 2 
  
  X = 6 bits expoente
  
  Y = 31 – 6 = 25 bits (mantissa)

---
## 🧮 Explicação base da FPU

Uma FPU, assim como outras unidades que fazem parte de um processador, realiza cálculos baseada na formatação das palavras que recebe, operando A e operando B, devolvendo o resultado após o término da operação.
Por possuir apenas a operação de adição, esta FPU não possui sinal de operação, baseando-se apenas no sinal de cada número inserido.

## 📦 Estrutura dos operandos (32 bits):

Bits	Campo	Descrição

31:	Sinal	
   0 = positivo
   1 = negativo
   
30 – 25: Expoente	
   6 bits — valor com bias (bias = 31)
   
24 – 0: Mantissa
   25 bits — fração (com bit implícito "1")

A codificação segue o estilo IEEE-754, com sinal, expoente com bias e mantissa fracionária.

---
## 🤖 Esquemático

### 🔌 Entradas

* clock100KHz — Clock de 100 KHz

* reset — Reset assíncrono, ativo em nível baixo (LOW)

* op_A_in — Operando A (32 bits)

* op_B_in — Operando B (32 bits)


### 🔋 Saídas

* data_out — Representa o resultado da operação, no mesmo formato dos operandos.

* status_out — Vetor de 4 bits no estilo one-hot, indicando o status do resultado:
   EXACT: O resultado foi representado corretamente, sem arredondamento.

   OVERFLOW: Resultado maior que o máximo representável.

   UNDERFLOW: Resultado menor que o menor valor representável.

   INEXACT: O resultado foi arredondado.

---

## 📏 Faixa representada

Expoente: De -31 até +32

Maior valor representável:
≈ 8.589934592 × 10⁹

Menor valor normalizado:
≈ 4.656612873 × 10⁻¹⁰
---

## ▶️ Como executar
1. Inicie o Questa e entre na pasta 'sim'.

2. Execute o comando no terminal do simulador:
do sim.do
