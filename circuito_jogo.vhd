library ieee;
use ieee.std_logic_1164.all;

entity circuito_jogo is
  port (
    clock : in std_logic;
    reset : in std_logic;
    iniciar : in std_logic;
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
end entity;
 
architecture arch of circuito_jogo is

   -- FD to UC
   signal s_jogada_pulso : std_logic;
   signal s_jogada_correta : std_logic;
   signal s_fimL : std_logic;
   signal s_fimT : std_logic;
   signal s_fimJ0 : std_logic;
 
   -- UC to FD
   signal s_zeraCR     : std_logic;
   signal s_contaCR    : std_logic;
   signal s_limpaRC     : std_logic;
   signal s_registraRC : std_logic;
   signal s_zeraT     : std_logic;
   signal s_contaT    : std_logic;
   signal s_zeraJ0     : std_logic;
   signal s_contaJ0    : std_logic;
   signal s_limpaPR : std_logic;
   signal s_registraPR : std_logic;
   signal s_seleciona_premio : std_logic;
   
   -- Sinais de depuracao aos displays
   signal s_contagem : std_logic_vector (3 downto 0);
   signal s_rodada : std_logic_vector (3 downto 0);
   signal s_memoria : std_logic_vector (1 downto 0);
   signal s_memoria_ext : std_logic_vector (3 downto 0);
   signal s_jogada_feita : std_logic_vector (1 downto 0);
   signal s_jogada_feita_ext : std_logic_vector (3 downto 0);
   signal s_estado : std_logic_vector (3 downto 0);
   signal s_conta_premio : std_logic_vector(3 downto 0);
   signal s_premio : std_logic_vector(10 downto 0);
  
  component fluxo_dados
    port (
      clock : in std_logic;
      zeraCR : in std_logic;
      contaCR : in std_logic;
      limpaRC : in std_logic;
      registraRC : in std_logic;
      limpaPR : in std_logic;
      registraPR: in std_logic;
      contaT : in std_logic;
      zeraT : in std_logic;
      zeraJ0 : in std_logic;
      contaJ0 : in std_logic;
      seleciona_premio : in std_logic;
      botoes : in std_logic_vector (3 downto 0);
      jogada_pulso : out std_logic;
      jogada_correta : out std_logic;
      fimL : out std_logic;
      fimT : out std_logic;
      fimJ0 : out std_logic;
      leds : out std_logic_vector (1 downto 0);
      db_jogada_feita : out std_logic_vector (1 downto 0);
      db_memoria : out std_logic_vector (1 downto 0);
      db_conta_premio : out std_logic_vector(3 downto 0);
      db_rodada : out std_logic_vector (3 downto 0)
    );
  end component;

  component unidade_controle
    port (
      clock : in std_logic;
      reset : in std_logic;
      iniciar : in std_logic;
      jogada_pulso : in std_logic;
      jogada_correta : in std_logic;
      fimL : in std_logic;
      fimT : in std_logic;
      fimJ0 : in std_logic;
      zeraCR : out std_logic;
      contaCR : out std_logic;
      limpaRC : out std_logic;
      registraRC : out std_logic;
      limpaPR : out std_logic;
      registraPR: out std_logic;
      zeraT : out std_logic;
      contaT : out std_logic;
      zeraJ0 : out std_logic;
      contaJ0 : out std_logic;
      seleciona_premio : out std_logic;
      ganhou : out std_logic;
      perdeu : out std_logic;
      pronto : out std_logic;
      db_estado : out std_logic_vector(3 downto 0)
  );
  end component;

  component hexa7seg is
    port (
      hexa : in  std_logic_vector(3 downto 0);
      sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  begin

    UC: unidade_controle
      port map (
        clock     => clock,
        reset     => reset,
        iniciar   => iniciar,
        jogada_pulso    => s_jogada_pulso,
        jogada_correta     => s_jogada_correta,
        fimL => s_fimL,
        fimT => s_fimT,
        fimJ0 => s_fimJ0,
        zeraCR     => s_zeraCR,
        contaCR     => s_contaCR,
        limpaRC => s_limpaRC,
        registraRC => s_registraRC,
        limpaPR => s_limpaPR,
        registraPR => s_registraPR,
        zeraT     => s_zeraT,
        contaT    => s_contaT,
        zeraJ0 => s_zeraJ0,
        contaJ0 => s_contaJ0,
        seleciona_premio => s_seleciona_premio,
        ganhou => ganhou,
        perdeu => perdeu,
        pronto => pronto,
        db_estado => s_estado
      );

    FD: fluxo_dados
      port map (
        clock               => clock,
        zeraCR     => s_zeraCR,
        contaCR     => s_contaCR,
        limpaRC => s_limpaRC,
        registraRC => s_registraRC,
        limpaPR => s_limpaPR,
        registraPR => s_registraPR,
        zeraT     => s_zeraT,
        contaT    => s_contaT,
        zeraJ0 => s_zeraJ0,
        contaJ0 => s_contaJ0,
        seleciona_premio => s_seleciona_premio,
        botoes => botoes,
        jogada_pulso    => s_jogada_pulso,
        jogada_correta     => s_jogada_correta,
        fimL => s_fimL,
        fimT => s_fimT,
        fimJ0 => s_fimJ0,
        leds => leds,
        db_rodada       => s_rodada,
        db_memoria          => s_memoria,
        db_conta_premio => s_conta_premio,
        db_jogada_feita           => s_jogada_feita
      );

    HEX0: hexa7seg
      port map (
        s_rodada,
        db_rodada
      );

    s_memoria_ext <= (1=>s_memoria(1), 0=> s_memoria(0), others=>'0');

    HEX1: hexa7seg
      port map (
        s_memoria_ext,
        db_memoria
      );

    HEX2: hexa7seg
      port map (
        s_jogada_feita_ext,
        db_jogada_feita
      );

    HEX4 : hexa7seg
      port map (
        s_conta_premio,
        db_premio
      );

    HEX5: hexa7seg
      port map (
        s_estado,
        db_estado
      );

    db_clock <= clock;
    db_tem_jogada <= s_jogada_pulso;
    db_jogada_correta <= s_jogada_correta;
    db_timeout <= s_fimT;
    

end architecture;
