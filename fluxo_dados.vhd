LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY fluxo_dados IS
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
END ENTITY;
ARCHITECTURE estrutural OF fluxo_dados IS

  SIGNAL s_pergunta     : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_codificado   : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_resposta     : STD_LOGIC_VECTOR (1 DOWNTO 0);
  SIGNAL s_premio_ganho : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_neg_botoes   : STD_LOGIC_VECTOR (3 DOWNTO 0);
  SIGNAL s_acertou      : STD_LOGIC;

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

  COMPONENT contador_m IS
    GENERIC (
      CONSTANT M : INTEGER := 100 -- modulo do contador
    );
    PORT (
      clock   : IN STD_LOGIC;
      zera_as : IN STD_LOGIC;
      zera_s  : IN STD_LOGIC;
      conta   : IN STD_LOGIC;
      Q       : OUT STD_LOGIC_VECTOR(NATURAL(ceil(log2(real(M)))) - 1 DOWNTO 0);
      fim     : OUT STD_LOGIC;
      meio    : OUT STD_LOGIC;
      posmeio : OUT STD_LOGIC
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

BEGIN

  s_sinal <= (NOT botoes(0)) OR (NOT botoes(1)) OR (NOT botoes(2)) OR (NOT botoes(3));

  s_neg_botoes <= NOT botoes;

  reset_edge <= NOT s_sinal;

  -- Registra o valor do premio (expoente)
  registrador_premio : registrador_n
  GENERIC MAP(N => 4)
  PORT MAP(
    clock  => clock,
    clear  => limpaPR,
    enable => registraPR,
    D      => s_pergunta,
    Q      => s_premio_ganho
  );

  db_conta_premio <= s_premio_ganho;

  -- Codifica respostas para 2 bits
  encoder : codificador_4x2
  PORT MAP(
    botoes => s_neg_botoes,
    valor  => s_codificado
  );

  edge : edge_detector
  PORT MAP(
    clock => clock,
    reset => reset_edge,
    sinal => s_sinal,
    pulso => resposta_pulso
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
    Q       => s_pergunta,
    meio    => OPEN,
    fim     => fimL,
    posmeio => posmeioL
  );
  comparador : comparador_85
  PORT MAP(
    i_A1   => gabarito(1),
    i_B1   => s_resposta(1),
    i_A0   => gabarito(0),
    i_B0   => s_resposta(0),
    i_AGTB => '0',
    i_ALTB => '0',
    i_AEQB => '1',
    o_AGTB => OPEN, -- saidas nao usadas
    o_ALTB => OPEN,
    o_AEQB => s_acertou
  );

  acertou <= compara AND s_acertou;
  -- conta segundos de espera
  espera : freq_divider
  GENERIC MAP(R => 1000)
  PORT MAP(
    reset     => zeraEP,
    clock_in  => clock,
    clock_out => conta_espera
  );

  -- timeout entre perguntas
  conta20000 : contador_m
  GENERIC MAP(M => 20000)
  PORT MAP(
    clock   => clock,
    zera_as => '0',
    zera_s  => zeraT,
    conta   => contaT,
    Q       => OPEN,
    meio    => meioT,
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
    Q       => OPEN,
    meio    => OPEN,
    fim     => fimJ0
  );

  db_pergunta <= s_pergunta;
  resposta    <= s_resposta;

END ARCHITECTURE estrutural;
