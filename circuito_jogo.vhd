LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY circuito_jogo IS
  PORT (
    clock             : IN STD_LOGIC;
    reset             : IN STD_LOGIC;
    botoes            : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gabarito          : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    resposta          : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
    acertou           : OUT STD_LOGIC;
    conta_espera      : OUT STD_LOGIC;
    reiniciar         : OUT STD_LOGIC;
    ganhou            : OUT STD_LOGIC;
    perdeu            : OUT STD_LOGIC;
    escolheu_menu     : OUT STD_LOGIC;
    db_respondeu      : OUT STD_LOGIC;
    db_timeout        : OUT STD_LOGIC;
    db_memoria        : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
    db_resposta_feita : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
    db_pergunta       : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
    db_premio         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
    db_estado         : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE arch OF circuito_jogo IS

  -- Clock division
  SIGNAL s_div_clock : STD_LOGIC;

  -- FD to UC
  SIGNAL s_resposta_pulso : STD_LOGIC;
  SIGNAL s_acertou        : STD_LOGIC;
  SIGNAL s_posmeioL       : STD_LOGIC;
  SIGNAL s_fimL           : STD_LOGIC;
  SIGNAL s_meioT          : STD_LOGIC;
  SIGNAL s_fimT           : STD_LOGIC;
  SIGNAL s_fimJ0          : STD_LOGIC;
  SIGNAL s_resposta       : STD_LOGIC_VECTOR(1 DOWNTO 0);

  -- UC to FD
  SIGNAL s_zeraCR     : STD_LOGIC;
  SIGNAL s_contaCR    : STD_LOGIC;
  SIGNAL s_limpaRC    : STD_LOGIC;
  SIGNAL s_registraRC : STD_LOGIC;
  SIGNAL s_zeraT      : STD_LOGIC;
  SIGNAL s_contaT     : STD_LOGIC;
  SIGNAL s_zeraJ0     : STD_LOGIC;
  SIGNAL s_contaJ0    : STD_LOGIC;
  SIGNAL s_zeraEP     : STD_LOGIC;
  SIGNAL s_limpaPR    : STD_LOGIC;
  SIGNAL s_registraPR : STD_LOGIC;
  SIGNAL s_compara    : STD_LOGIC;

  -- Sinais de depuracao aos displays
  SIGNAL s_contagem           : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_pergunta           : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_memoria            : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_memoria_ext        : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_resposta_feita     : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_resposta_feita_ext : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_estado             : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_conta_premio       : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_premio             : STD_LOGIC_VECTOR(10 DOWNTO 0);

  COMPONENT fluxo_dados
    PORT (
      clock           : IN STD_LOGIC;
      zeraCR          : IN STD_LOGIC;
      contaCR         : IN STD_LOGIC;
      limpaRC         : IN STD_LOGIC;
      registraRC      : IN STD_LOGIC;
      limpaPR         : IN STD_LOGIC;
      registraPR      : IN STD_LOGIC;
      contaT          : IN STD_LOGIC;
      zeraT           : IN STD_LOGIC;
      zeraJ0          : IN STD_LOGIC;
      contaJ0         : IN STD_LOGIC;
      zeraEP          : IN STD_LOGIC;
      compara         : IN STD_LOGIC;
      gabarito        : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      botoes          : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
      resposta_pulso  : OUT STD_LOGIC;
      acertou         : OUT STD_LOGIC;
      conta_espera    : OUT STD_LOGIC;
      posmeioL        : OUT STD_LOGIC;
      fimL            : OUT STD_LOGIC;
      meioT           : OUT STD_LOGIC;
      fimT            : OUT STD_LOGIC;
      fimJ0           : OUT STD_LOGIC;
      resposta        : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      db_memoria      : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      db_conta_premio : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      db_pergunta     : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT unidade_controle
    PORT (
      clock          : IN STD_LOGIC;
      reset          : IN STD_LOGIC;
      resposta_pulso : IN STD_LOGIC;
      acertou        : IN STD_LOGIC;
      resposta       : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      posmeioL       : IN STD_LOGIC;
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
      zeraEP         : OUT STD_LOGIC;
      compara        : OUT STD_LOGIC;
      escolheu_menu  : OUT STD_LOGIC;
      ganhou         : OUT STD_LOGIC;
      perdeu         : OUT STD_LOGIC;
      reiniciar      : OUT STD_LOGIC;
      db_estado      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT freq_divider IS
    GENERIC (
      CONSTANT R : INTEGER := 1000
    );
    PORT (
      reset     : IN STD_LOGIC;
      clock_in  : IN STD_LOGIC;
      clock_out : OUT STD_LOGIC
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

  div_clk : freq_divider
  GENERIC MAP(R => 25000)
  PORT MAP(
    reset     => '0',
    clock_in  => clock,
    clock_out => s_div_clock
  );

  UC : unidade_controle
  PORT MAP(
    clock          => s_div_clock,
    reset          => reset,
    resposta_pulso => s_resposta_pulso,
    acertou        => s_acertou,
    resposta       => s_resposta,
    posmeioL       => s_posmeioL,
    fimL           => s_fimL,
    meioT          => s_meioT,
    fimT           => s_fimT,
    fimJ0          => s_fimJ0,
    zeraCR         => s_zeraCR,
    contaCR        => s_contaCR,
    limpaRC        => s_limpaRC,
    registraRC     => s_registraRC,
    limpaPR        => s_limpaPR,
    registraPR     => s_registraPR,
    zeraT          => s_zeraT,
    contaT         => s_contaT,
    zeraJ0         => s_zeraJ0,
    contaJ0        => s_contaJ0,
    compara        => s_compara,
    zeraEP         => s_zeraEP,
    escolheu_menu  => escolheu_menu,
    ganhou         => ganhou,
    perdeu         => perdeu,
    reiniciar      => reiniciar,
    db_estado      => s_estado
  );

  FD : fluxo_dados
  PORT MAP(
    clock           => s_div_clock,
    zeraCR          => s_zeraCR,
    contaCR         => s_contaCR,
    limpaRC         => s_limpaRC,
    registraRC      => s_registraRC,
    limpaPR         => s_limpaPR,
    registraPR      => s_registraPR,
    zeraT           => s_zeraT,
    contaT          => s_contaT,
    zeraJ0          => s_zeraJ0,
    contaJ0         => s_contaJ0,
    zeraEP          => s_zeraEP,
    compara         => s_compara,
    gabarito        => gabarito,
    botoes          => botoes,
    resposta_pulso  => s_resposta_pulso,
    acertou         => s_acertou,
    resposta        => s_resposta,
    fimL            => s_fimL,
    posmeioL        => s_posmeioL,
    meioT           => s_meioT,
    fimT            => s_fimT,
    fimJ0           => s_fimJ0,
    conta_espera    => conta_espera,
    db_pergunta     => s_pergunta,
    db_memoria      => s_memoria,
    db_conta_premio => s_conta_premio
  );

  acertou  <= s_acertou;
  resposta <= s_resposta;

  HEX0 : hexa7seg
  PORT MAP(
    s_pergunta,
    db_pergunta
  );

  HEX1 : letter7seg
  PORT MAP(
    s_memoria,
    db_memoria
  );

  HEX2 : letter7seg
  PORT MAP(
    s_resposta,
    db_resposta_feita
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

  db_respondeu <= s_resposta_pulso;
  db_timeout   <= s_fimT;
END ARCHITECTURE;
