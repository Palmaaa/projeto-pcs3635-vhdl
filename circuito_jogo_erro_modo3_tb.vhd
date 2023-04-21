--------------------------------------------------------------------------
-- Arquivo de teste com clock 1000x menor do que o da FPGA a fim de tornar
-- os tempos de simulacoes no ModelSim apreciaveis. Para usar, reduzir em 
-- 1000x os tamanhos dos contadores de timeout.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

-- entidade do testbench
ENTITY circuito_jogo_erro_modo3_tb IS
END ENTITY;

ARCHITECTURE tb OF circuito_jogo_erro_modo3_tb IS

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
      db_tem_resposta     : OUT STD_LOGIC;
      db_acertou : OUT STD_LOGIC;
      db_timeout        : OUT STD_LOGIC;
      db_memoria        : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_resposta_feita   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
      db_pergunta         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
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
  SIGNAL tem_resposta_out     : STD_LOGIC                    := '0';
  SIGNAL acertou_out : STD_LOGIC                    := '0';
  SIGNAL timeout_out        : STD_LOGIC;
  SIGNAL contagem_out       : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL memoria_out        : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL resposta_feita_out   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
  SIGNAL pergunta_out         : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
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
    db_tem_resposta     => tem_resposta_out,
    db_acertou => acertou_out,
    db_timeout        => timeout_out,
    db_memoria        => memoria_out,
    db_resposta_feita   => resposta_feita_out,
    db_pergunta         => pergunta_out,
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
    botoes_in <= "1000";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- resposta da pergunta 0
    botoes_in <= "0001";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- resposta da pergunta 1
    botoes_in <= "0010";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;

    ---- resposta da pergunta 2
    botoes_in <= "0010";
    WAIT FOR 5 * clockPeriod;
    botoes_in <= "0000";
    WAIT FOR 5 * clockPeriod;
    WAIT FOR 15 * clockPeriod;

    ---- final do testbench
    ASSERT false REPORT "fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT; -- fim da simulação: processo aguarda indefinidamente
  END PROCESS;
END ARCHITECTURE;
