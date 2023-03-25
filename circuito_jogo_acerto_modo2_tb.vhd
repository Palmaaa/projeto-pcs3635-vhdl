--------------------------------------------------------------------------
-- Arquivo   : circuito_exp4_tb_modelo.vhd
-- Projeto   : Experiencia 04 - Desenvolvimento de Projeto de
--                              Circuitos Digitais com FPGA
--------------------------------------------------------------------------
-- Descricao : modelo de testbench para simulação com ModelSim
--
--             implementa um Cenário de Teste do circuito
--             com 4 jogadas certas e erro na quinta jogada
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     01/02/2020  1.0     Edson Midorikawa  criacao
--     27/01/2021  1.1     Edson Midorikawa  revisao
--     27/01/2022  1.2     Edson Midorikawa  revisao e adaptacao
--------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

-- entidade do testbench
ENTITY circuito_jogo_acerto_modo2_tb IS
END ENTITY;

ARCHITECTURE tb OF circuito_jogo_acerto_modo2_tb IS

  -- Componente a ser testado (Device Under Test -- DUT)
  COMPONENT circuito_jogo
    PORT (
      clock             : IN STD_LOGIC;
      reset             : IN STD_LOGIC;
      botoes            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      leds              : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      pronto            : OUT STD_LOGIC;
      ganhou            : OUT STD_LOGIC;
      perdeu            : OUT STD_LOGIC;
      db_clock          : OUT STD_LOGIC;
      db_tem_jogada     : OUT STD_LOGIC;
      db_jogada_correta : OUT STD_LOGIC;
      db_timeout        : OUT STD_LOGIC;
      db_memoria        : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_jogada_feita   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_rodada         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_premio         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_estado         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
  END COMPONENT;

  ---- Declaracao de sinais de entrada para conectar o componente
  SIGNAL clk_in    : STD_LOGIC                    := '0';
  SIGNAL rst_in    : STD_LOGIC                    := '0';
  SIGNAL botoes_in : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";

  ---- Declaracao dos sinais de saida
  SIGNAL ganhou_out         : STD_LOGIC                    := '0';
  SIGNAL perdeu_out         : STD_LOGIC                    := '0';
  SIGNAL pronto_out         : STD_LOGIC                    := '0';
  SIGNAL leds_out           : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  SIGNAL clock_out          : STD_LOGIC                    := '0';
  SIGNAL tem_jogada_out     : STD_LOGIC                    := '0';
  SIGNAL jogada_correta_out : STD_LOGIC                    := '0';
  SIGNAL timeout_out        : STD_LOGIC;
  SIGNAL contagem_out       : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL memoria_out        : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL jogada_feita_out   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL rodada_out         : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL estado_out         : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";

  -- Configurações do clock
  SIGNAL keep_simulating : STD_LOGIC := '0';  -- delimita o tempo de geração do clock
  CONSTANT clockPeriod   : TIME      := 1 ms; -- frequencia 1kHz

BEGIN
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (NOT clk_in) AND keep_simulating AFTER clockPeriod/2;

  ---- DUT para Simulacao
  dut : circuito_jogo
  PORT MAP
  (
    clock             => clk_in,
    reset             => rst_in,
    botoes            => botoes_in,
    leds              => leds_out,
    pronto            => pronto_out,
    ganhou            => ganhou_out,
    perdeu            => perdeu_out,
    db_clock          => clock_out,
    db_tem_jogada     => tem_jogada_out,
    db_jogada_correta => jogada_correta_out,
    db_timeout        => timeout_out,
    db_memoria        => memoria_out,
    db_jogada_feita   => jogada_feita_out,
    db_rodada         => rodada_out,
    db_estado         => estado_out
  );
  stimulus : PROCESS IS

  BEGIN

    -- inicio da simulacao
    ASSERT false REPORT "inicio da simulacao" SEVERITY note;
    keep_simulating <= '1'; -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '1';
    WAIT FOR clockPeriod;
    rst_in <= '0';
    -- espera para inicio dos testes
    WAIT FOR 3 * clockPeriod;
    WAIT UNTIL falling_edge(clk_in);
    WAIT FOR 15 * clockPeriod;
    botoes_in <= "0100";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 0
    botoes_in <= "0001";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 1
    botoes_in <= "0010";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 2
    botoes_in <= "0100";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 3
    botoes_in <= "1000";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 4
    botoes_in <= "0001";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 5
    botoes_in <= "0010";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 6
    botoes_in <= "0100";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 7
    botoes_in <= "1000";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 8
    botoes_in <= "0001";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 9
    botoes_in <= "0010";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- Jogada da rodada 10
    botoes_in <= "0100";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- final do testbench
    ASSERT false REPORT "fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT; -- fim da simulação: processo aguarda indefinidamente
  END PROCESS;
END ARCHITECTURE;
