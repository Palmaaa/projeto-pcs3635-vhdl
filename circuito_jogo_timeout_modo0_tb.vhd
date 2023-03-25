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

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

-- entidade do testbench
entity circuito_jogo_timeout_modo0_tb is
end entity;

architecture tb of circuito_jogo_timeout_modo0_tb is

  -- Componente a ser testado (Device Under Test -- DUT)
  component circuito_jogo
  port (
    clock : in std_logic;
    reset : in std_logic;
    botoes : in std_logic_vector(3 downto 0);
    leds : out std_logic_vector (1 downto 0);
    pronto : out std_logic;
    ganhou : out std_logic;
    perdeu : out std_logic;
    db_clock : out std_logic;
    db_tem_jogada : out std_logic;
    db_jogada_correta : out std_logic;
    db_timeout : out std_logic;
    db_memoria : out std_logic_vector (6 downto 0);
    db_jogada_feita : out std_logic_vector (6 downto 0);
    db_rodada : out std_logic_vector (6 downto 0);
    db_premio: out std_logic_vector (6 downto 0);
    db_estado : out std_logic_vector (6 downto 0)
  );
  end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clk_in     : std_logic := '0';
  signal rst_in     : std_logic := '0';
  signal botoes_in  : std_logic_vector(3 downto 0) := "0000";

  ---- Declaracao dos sinais de saida
  signal ganhou_out    : std_logic := '0';
  signal perdeu_out      : std_logic := '0';
  signal pronto_out     : std_logic := '0';
  signal leds_out       : std_logic_vector(1 downto 0) := "00";
  signal clock_out      : std_logic := '0';
  signal tem_jogada_out : std_logic := '0';
  signal jogada_correta_out : std_logic := '0';
  signal timeout_out : std_logic;
  signal contagem_out   : std_logic_vector(6 downto 0) := "0000000";
  signal memoria_out    : std_logic_vector(6 downto 0) := "0000000";
  signal jogada_feita_out     : std_logic_vector(6 downto 0) := "0000000";
  signal rodada_out : std_logic_vector(6 downto 0) := "0000000";
  signal estado_out     : std_logic_vector(6 downto 0) := "0000000";

  -- Configurações do clock
  signal keep_simulating: std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod : time := 1 ms;     -- frequencia 1kHz
  
begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Simulacao
  dut: circuito_jogo
       port map
       (
          clock           => clk_in,
          reset           => rst_in,
          botoes          => botoes_in,
          leds            => leds_out,
          pronto          => pronto_out,
          ganhou         => ganhou_out,
          perdeu           => perdeu_out,
          db_clock        => clock_out,
          db_tem_jogada   => tem_jogada_out,
          db_jogada_correta => jogada_correta_out,
          db_timeout => timeout_out,
          db_memoria      => memoria_out,
          db_jogada_feita  => jogada_feita_out,  
          db_rodada => rodada_out,
          db_estado       => estado_out
       );
 

  stimulus: process is

    begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    -- gera pulso de reset (1 periodo de clock)
    rst_in <= '1';
    wait for clockPeriod;
    rst_in <= '0';

    -- espera para inicio dos testes
    wait for 3*clockPeriod;
    wait until falling_edge(clk_in);
    wait for 15*clockPeriod;


    botoes_in <= "0001";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 0
    botoes_in <= "0001";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 1
    botoes_in <= "0010";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 2, errada
    botoes_in <= "0001";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 2, errada
    botoes_in <= "0010";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 2, errada
    botoes_in <= "1000";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 2, correta
    botoes_in <= "0100";
    wait for 5*clockPeriod;
    botoes_in <= "0000";
    wait for 5*clockPeriod;

    ---- Jogada da rodada 3, perder com timeout
    wait for 20000*clockPeriod;


    wait for 500*clockPeriod;

    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';

    wait; -- fim da simulação: processo aguarda indefinidamente
    end process;


end architecture;
