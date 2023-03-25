-------------------------------------------------------------------
-- Arquivo   : ram_10x2.vhd
-- Projeto   : Experiencia 2 - Um Fluxo de Dados Simples
-------------------------------------------------------------------
-- Descricao : módulo de memória RAM sincrona 16x4 
--             sinais we e ce ativos em baixo
--             codigo ADAPTADO do código encontrado no livro 
--             VHDL Descricao e Sintese de Circuitos Digitais
--             de Roberto D'Amore, LTC Editora.
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     08/01/2020  1.0     Edson Midorikawa  criacao
--     01/02/2020  2.0     Antonio V.S.Neto  Atualizacao para 
--                                           RAM sincrona para
--                                           minimizar problemas
--                                           com Quartus.
--     02/02/2020  2.1     Edson Midorikawa  revisao de codigo e
--                                           arquitetura para 
--                                           simulacao com ModelSim 
--     07/01/2023  2.1.1   Edson Midorikawa  revisao
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram_10x2 IS
  PORT (
    clk          : IN STD_LOGIC;
    endereco     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    dado_entrada : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    we           : IN STD_LOGIC;
    ce           : IN STD_LOGIC;
    dado_saida   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END ENTITY ram_10x2;

-- Dados iniciais em arquivo MIF (para sintese com Intel Quartus Prime) 
ARCHITECTURE ram_mif OF ram_10x2 IS
  TYPE arranjo_memoria IS ARRAY(0 TO 10) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL memoria : arranjo_memoria;

  -- Configuracao do Arquivo MIF
  ATTRIBUTE ram_init_file            : STRING;
  ATTRIBUTE ram_init_file OF memoria : SIGNAL IS "ram_conteudo_jogadas.mif";

BEGIN

  PROCESS (clk)
  BEGIN
    IF (clk = '1' AND clk'event) THEN
      IF ce = '0' THEN -- dado armazenado na subida de "we" com "ce=0"

        -- Detecta ativacao de we (ativo baixo)
        IF (we = '0')
          THEN
          memoria(to_integer(unsigned(endereco))) <= dado_entrada;
        END IF;

      END IF;
    END IF;
  END PROCESS;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));

END ARCHITECTURE ram_mif;

-- Dados iniciais (para simulacao com Modelsim) 
ARCHITECTURE ram_modelsim OF ram_10x2 IS
  TYPE arranjo_memoria IS ARRAY(0 TO 10) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL memoria : arranjo_memoria := (
    "00",
    "01",
    "10",
    "11",
    "00",
    "01",
    "10",
    "11",
    "00",
    "01",
    "10"
  );

BEGIN

  PROCESS (clk)
  BEGIN
    IF (clk = '1' AND clk'event) THEN
      IF ce = '0' THEN -- dado armazenado na subida de "we" com "ce=0"

        -- Detecta ativacao de we (ativo baixo)
        IF (we = '0')
          THEN
          memoria(to_integer(unsigned(endereco))) <= dado_entrada;
        END IF;

      END IF;
    END IF;
  END PROCESS;

  -- saida da memoria
  dado_saida <= memoria(to_integer(unsigned(endereco)));

END ARCHITECTURE ram_modelsim;
