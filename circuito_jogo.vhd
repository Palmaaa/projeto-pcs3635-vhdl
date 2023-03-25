LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY circuito_jogo IS
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
END ENTITY;

ARCHITECTURE arch OF circuito_jogo IS

  -- FD to UC
  SIGNAL s_jogada_pulso   : STD_LOGIC;
  SIGNAL s_jogada_correta : STD_LOGIC;
  SIGNAL s_inicioL        : STD_LOGIC;
  SIGNAL s_fimL           : STD_LOGIC;
  SIGNAL s_meioT          : STD_LOGIC;
  SIGNAL s_fimT           : STD_LOGIC;
  SIGNAL s_fimJ0          : STD_LOGIC;
  SIGNAL s_jogada         : STD_LOGIC_VECTOR(1 DOWNTO 0);

  -- UC to FD
  SIGNAL s_zeraCR     : STD_LOGIC;
  SIGNAL s_contaCR    : STD_LOGIC;
  SIGNAL s_reduzCR    : STD_LOGIC;
  SIGNAL s_limpaRC    : STD_LOGIC;
  SIGNAL s_registraRC : STD_LOGIC;
  SIGNAL s_zeraT      : STD_LOGIC;
  SIGNAL s_contaT     : STD_LOGIC;
  SIGNAL s_zeraJ0     : STD_LOGIC;
  SIGNAL s_contaJ0    : STD_LOGIC;
  SIGNAL s_limpaPR    : STD_LOGIC;
  SIGNAL s_registraPR : STD_LOGIC;

  -- Sinais de depuracao aos displays
  SIGNAL s_contagem         : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_rodada           : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_memoria          : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_memoria_ext      : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_jogada_feita     : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_jogada_feita_ext : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_estado           : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_conta_premio     : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_premio           : STD_LOGIC_VECTOR(10 DOWNTO 0);

  COMPONENT fluxo_dados
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
  END COMPONENT;

  COMPONENT unidade_controle
    PORT (
      clock          : IN STD_LOGIC;
      reset          : IN STD_LOGIC;
      jogada_pulso   : IN STD_LOGIC;
      jogada_correta : IN STD_LOGIC;
      jogada         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      inicioL        : IN STD_LOGIC;
      fimL           : IN STD_LOGIC;
      meioT          : IN STD_LOGIC;
      fimT           : IN STD_LOGIC;
      fimJ0          : IN STD_LOGIC;
      zeraCR         : OUT STD_LOGIC;
      contaCR        : OUT STD_LOGIC;
      reduzCR        : OUT STD_LOGIC;
      limpaRC        : OUT STD_LOGIC;
      registraRC     : OUT STD_LOGIC;
      limpaPR        : OUT STD_LOGIC;
      registraPR     : OUT STD_LOGIC;
      zeraT          : OUT STD_LOGIC;
      contaT         : OUT STD_LOGIC;
      zeraJ0         : OUT STD_LOGIC;
      contaJ0        : OUT STD_LOGIC;
      ganhou         : OUT STD_LOGIC;
      perdeu         : OUT STD_LOGIC;
      pronto         : OUT STD_LOGIC;
      db_estado      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT hexa7seg IS
    PORT (
      hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT letter7seg IS
    PORT (
      letter : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      sseg   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

BEGIN

  UC : unidade_controle
  PORT MAP(
    clock          => clock,
    reset          => reset,
    jogada_pulso   => s_jogada_pulso,
    jogada_correta => s_jogada_correta,
    jogada         => s_jogada,
    inicioL        => s_inicioL,
    fimL           => s_fimL,
    meioT          => s_meioT,
    fimT           => s_fimT,
    fimJ0          => s_fimJ0,
    zeraCR         => s_zeraCR,
    contaCR        => s_contaCR,
    reduzCR        => s_reduzCR,
    limpaRC        => s_limpaRC,
    registraRC     => s_registraRC,
    limpaPR        => s_limpaPR,
    registraPR     => s_registraPR,
    zeraT          => s_zeraT,
    contaT         => s_contaT,
    zeraJ0         => s_zeraJ0,
    contaJ0        => s_contaJ0,
    ganhou         => ganhou,
    perdeu         => perdeu,
    pronto         => pronto,
    db_estado      => s_estado
  );

  FD : fluxo_dados
  PORT MAP(
    clock           => clock,
    zeraCR          => s_zeraCR,
    contaCR         => s_contaCR,
    reduzCR         => s_reduzCR,
    limpaRC         => s_limpaRC,
    registraRC      => s_registraRC,
    limpaPR         => s_limpaPR,
    registraPR      => s_registraPR,
    zeraT           => s_zeraT,
    contaT          => s_contaT,
    zeraJ0          => s_zeraJ0,
    contaJ0         => s_contaJ0,
    botoes          => botoes,
    jogada_pulso    => s_jogada_pulso,
    jogada_correta  => s_jogada_correta,
    jogada          => s_jogada,
    fimL            => s_fimL,
    inicioL         => s_inicioL,
    meioT           => s_meioT,
    fimT            => s_fimT,
    fimJ0           => s_fimJ0,
    leds            => leds,
    db_rodada       => s_rodada,
    db_memoria      => s_memoria,
    db_conta_premio => s_conta_premio
  );

  HEX0 : hexa7seg
  PORT MAP(
    s_rodada,
    db_rodada
  );

  HEX1 : letter7seg
  PORT MAP(
    s_memoria,
    db_memoria
  );

  HEX2 : letter7seg
  PORT MAP(
    s_jogada,
    db_jogada_feita
  );

  HEX4 : hexa7seg
  PORT MAP(
    s_conta_premio,
    db_premio
  );

  HEX5 : hexa7seg
  PORT MAP(
    s_estado,
    db_estado
  );

  db_clock          <= clock;
  db_tem_jogada     <= s_jogada_pulso;
  db_jogada_correta <= s_jogada_correta;
  db_timeout        <= s_fimT;
END ARCHITECTURE;
