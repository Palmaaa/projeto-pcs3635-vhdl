--------------------------------------------------------------------------
-- Arquivo   : circuito_exp4_tb_modelo.vhd
-- Projeto   : Experiencia 04 - Desenvolvimento de Projeto de
--                              Circuitos Digitais com FPGA
--------------------------------------------------------------------------
-- Descricao : modelo de testbench para simulação com ModelSim
--
--             implementa um Cenário de Teste do circuito
--             com 4 respostas certas e erro na quinta resposta
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
ENTITY circuito_jogo_acerto_modo0_tb IS
END ENTITY;

ARCHITECTURE tb OF circuito_jogo_acerto_modo0_tb IS

  -- Componente a ser testado (Device Under Test -- DUT)
  COMPONENT circuito_jogo
    PORT (
      clock           : IN STD_LOGIC;
      reset           : IN STD_LOGIC;
      botoes          : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      resposta        : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      acertou         : OUT STD_LOGIC;
      conta_espera    : OUT STD_LOGIC;
      reiniciar       : OUT STD_LOGIC;
      ganhou          : OUT STD_LOGIC;
      perdeu          : OUT STD_LOGIC;
      escolheu_menu   : OUT STD_LOGIC;
      db_respondeu    : OUT STD_LOGIC;
      db_timeout      : OUT STD_LOGIC;
      db_memoria      : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_resposta_feita : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_pergunta       : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_premio       : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_estado       : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
  END COMPONENT;

  ---- Declaracao de sinais de entrada para conectar o componente
  SIGNAL clk_in    : STD_LOGIC                    := '0';
  SIGNAL rst_in    : STD_LOGIC                    := '1';
  SIGNAL botoes_in : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

  ---- Declaracao dos sinais de saida
  SIGNAL ganhou_out        : STD_LOGIC                    := '0';
  SIGNAL perdeu_out        : STD_LOGIC                    := '0';
  SIGNAL resposta_out      : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  SIGNAL acertou_out       : STD_LOGIC                    := '0';
  SIGNAL escolheu_menu_out : STD_LOGIC                    := '0';
  SIGNAL timeout_out       : STD_LOGIC;
  SIGNAL contagem_out      : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL memoria_out       : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL resposta_feita_out  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL pergunta_out        : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL estado_out        : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";

  -- Configurações do clock
  SIGNAL keep_simulating : STD_LOGIC := '0';      -- delimita o tempo de geração do clock
  CONSTANT clockPeriod   : TIME      := 20000 ns; -- frequencia 1kHz

BEGIN
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (NOT clk_in) AND keep_simulating AFTER clockPeriod/2;

  ---- DUT para Simulacao
  dut : circuito_jogo
  PORT MAP
  (
    clock           => clk_in,
    reset           => rst_in,
    botoes          => botoes_in,
    resposta        => resposta_out,
    acertou         => acertou_out,
    ganhou          => ganhou_out,
    perdeu          => perdeu_out,
    escolheu_menu   => escolheu_menu_out,
    db_timeout      => timeout_out,
    db_memoria      => memoria_out,
    db_resposta_feita => resposta_feita_out,
    db_pergunta       => pergunta_out,
    db_estado       => estado_out
  );
  stimulus : PROCESS IS

  BEGIN

    -- inicio da simulacao
    ASSERT false REPORT "inicio da simulacao" SEVERITY note;
    keep_simulating <= '1'; -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '0';
    WAIT FOR clockPeriod * 50;
    rst_in <= '1';

    -- espera para inicio dos testes
    WAIT FOR 3 * clockPeriod * 50;
    WAIT UNTIL falling_edge(clk_in);
    WAIT FOR 15 * clockPeriod * 50;
    botoes_in <= "1101";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 0
    botoes_in <= "1110";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 1
    botoes_in <= "1101";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 2
    botoes_in <= "1011";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 3, errada
    botoes_in <= "1011";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 3, errada
    botoes_in <= "1101";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 3, correta
    botoes_in <= "0111";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 4
    botoes_in <= "1110";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 5
    botoes_in <= "1011";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 6
    botoes_in <= "1011";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 7
    botoes_in <= "0111";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 8
    botoes_in <= "1110";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 9
    botoes_in <= "1101";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- resposta da pergunta 10
    botoes_in <= "1011";
    WAIT FOR 5 * clockPeriod * 50;
    botoes_in <= "1111";
    WAIT FOR 5 * clockPeriod * 50;

    ---- final do testbench
    ASSERT false REPORT "fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT; -- fim da simulação: processo aguarda indefinidamente
  END PROCESS;
END ARCHITECTURE;
