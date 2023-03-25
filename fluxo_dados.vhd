LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY fluxo_dados IS
  PORT (
    clock           : IN STD_LOGIC;
    zeraCR          : IN STD_LOGIC;
    contaCR         : IN STD_LOGIC;
    reduzCR         : IN STD_LOGIC;
    limpaRC         : IN STD_LOGIC;
    registraRC      : IN STD_LOGIC;
    limpaPR         : IN STD_LOGIC;
    registraPR      : IN STD_LOGIC;
    contaT          : IN STD_LOGIC;
    zeraT           : IN STD_LOGIC;
    zeraJ0          : IN STD_LOGIC;
    contaJ0         : IN STD_LOGIC;
    botoes          : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
    jogada_pulso    : OUT STD_LOGIC;
    jogada_correta  : OUT STD_LOGIC;
    jogada          : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    inicioL         : OUT STD_LOGIC;
    fimL            : OUT STD_LOGIC;
    meioT           : OUT STD_LOGIC;
    fimT            : OUT STD_LOGIC;
    fimJ0           : OUT STD_LOGIC;
    leds            : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    db_memoria      : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    db_conta_premio : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    db_rodada       : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
  );
END ENTITY;
ARCHITECTURE estrutural OF fluxo_dados IS

  SIGNAL s_rodada       : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_endereco     : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_dado         : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_codificado   : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_resposta     : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_premio_ganho : STD_LOGIC_VECTOR (3 DOWNTO 0);

  SIGNAL reset_edge : STD_LOGIC;
  SIGNAL s_sinal    : STD_LOGIC;

  SIGNAL s_not_zera_e  : STD_LOGIC;
  SIGNAL s_not_zera_cr : STD_LOGIC;

  COMPONENT edge_detector
    PORT (
      clock : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      sinal : IN STD_LOGIC;
      pulso : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT codificador_4x2
    PORT (
      botoes : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      valor  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT registrador_n
    GENERIC (
      CONSTANT N : INTEGER := 2
    );
    PORT (
      clock  : IN STD_LOGIC;
      clear  : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      D      : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
      Q      : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT comparador_85
    PORT (
      i_A1   : IN STD_LOGIC;
      i_B1   : IN STD_LOGIC;
      i_A0   : IN STD_LOGIC;
      i_B0   : IN STD_LOGIC;
      i_AGTB : IN STD_LOGIC;
      i_ALTB : IN STD_LOGIC;
      i_AEQB : IN STD_LOGIC;
      o_AGTB : OUT STD_LOGIC;
      o_ALTB : OUT STD_LOGIC;
      o_AEQB : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT ram_10x2 IS
    PORT (
      clk          : IN STD_LOGIC;
      endereco     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      dado_entrada : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      we           : IN STD_LOGIC;
      ce           : IN STD_LOGIC;
      dado_saida   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT contador_m IS
    GENERIC (
      CONSTANT M : INTEGER := 100 -- modulo do contador
    );
    PORT (
      clock   : IN STD_LOGIC;
      zera_as : IN STD_LOGIC;
      zera_s  : IN STD_LOGIC;
      conta   : IN STD_LOGIC;
      reduz   : IN STD_LOGIC;
      Q       : OUT STD_LOGIC_VECTOR(NATURAL(ceil(log2(real(M)))) - 1 DOWNTO 0);
      fim     : OUT STD_LOGIC;
      inicio  : OUT STD_LOGIC;
      meio    : OUT STD_LOGIC
    );
  END COMPONENT;

BEGIN

  s_sinal <= botoes(0) OR botoes(1) OR botoes(2) OR botoes(3);

  reset_edge <= NOT s_sinal;

  leds <= s_dado;

  -- Registra o valor do premio (expoente)
  registrador_premio : registrador_n
  GENERIC MAP(N => 4)
  PORT MAP(
    clock  => clock,
    clear  => limpaPR,
    enable => registraPR,
    D      => s_rodada,
    Q      => s_premio_ganho
  );

  db_conta_premio <= s_premio_ganho;

  -- Codifica respostas para 2 bits
  encoder : codificador_4x2
  PORT MAP(
    botoes => botoes,
    valor  => s_codificado
  );

  edge : edge_detector
  PORT MAP(
    clock => clock,
    reset => reset_edge,
    sinal => s_sinal,
    pulso => jogada_pulso
  );

  registrador : registrador_n
  GENERIC MAP(N => 2)
  PORT MAP(
    clock  => clock,
    clear  => limpaRC,
    enable => registraRC,
    D      => s_codificado,
    Q      => s_resposta
  );

  s_not_zera_cr <= NOT zeraCR;

  contador_rod : contador_m
  GENERIC MAP(M => 11)
  PORT MAP(
    clock   => clock,
    zera_as => '0',
    zera_s  => zeraCR, -- clr ativo em alto
    conta   => contaCR,
    reduz   => reduzCR,
    Q       => s_rodada,
    meio    => OPEN,
    inicio  => inicioL,
    fim     => fimL
  );
  comparador : comparador_85
  PORT MAP(
    i_A1   => s_dado(1),
    i_B1   => s_resposta(1),
    i_A0   => s_dado(0),
    i_B0   => s_resposta(0),
    i_AGTB => '0',
    i_ALTB => '0',
    i_AEQB => '1',
    o_AGTB => OPEN, -- saidas nao usadas
    o_ALTB => OPEN,
    o_AEQB => jogada_correta
  );

  -- timeout entre perguntas
  conta20000 : contador_m
  GENERIC MAP(M => 20000)
  PORT MAP(
    clock   => clock,
    zera_as => '0',
    zera_s  => zeraT,
    conta   => contaT,
    reduz   => '0',
    Q       => OPEN,
    meio    => meioT,
    inicio  => OPEN,
    fim     => fimT
  );

  -- timeout para voltar ao menu
  conta60000 : contador_m
  GENERIC MAP(M => 60000)
  PORT MAP(
    clock   => clock,
    zera_as => '0',
    zera_s  => zeraJ0,
    conta   => contaJ0,
    reduz   => '0',
    Q       => OPEN,
    meio    => OPEN,
    inicio  => OPEN,
    fim     => fimJ0
  );
  s_endereco <= s_rodada;
  ---- memoria: entity work.ram_10x2 (ram_mif)  -- usar esta linha para Intel Quartus
  memoria : ENTITY work.ram_10x2 (ram_modelsim) -- usar arquitetura para ModelSim
    PORT MAP(
      clk          => clock,
      endereco     => s_endereco,
      dado_entrada => s_resposta,
      we           => '1', -- we ativo em baixo
      ce           => '0',
      dado_saida   => s_dado
    );

  db_rodada  <= s_rodada;
  db_memoria <= s_dado;
  jogada     <= s_resposta;

END ARCHITECTURE estrutural;
