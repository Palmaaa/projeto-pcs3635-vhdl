library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
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
end entity;


architecture estrutural of fluxo_dados is

  signal s_rodada : std_logic_vector (3 downto 0);
  signal s_endereco : std_logic_vector (3 downto 0);
  signal s_dado        : std_logic_vector (1 downto 0);
  signal s_codificado : std_logic_vector (1 downto 0);
  signal s_resposta      : std_logic_vector (1 downto 0);
  signal s_premio_ganho : std_logic_vector (3 downto 0);
  signal s_conta_premio : std_logic_vector (3 downto 0);

  signal reset_edge    : std_logic;
  signal s_sinal       : std_logic;

  signal s_not_zera_e    : std_logic;
  signal s_not_zera_cr    : std_logic;

  component edge_detector
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        sinal  : in  std_logic;
        pulso  : out std_logic
    );
  end component;

  component codificador_4x2
      port (
        botoes : in std_logic_vector(3 downto 0);
        valor : out std_logic_vector(1 downto 0)
    );
  end component;

  component registrador_n
    generic (
        constant N: integer := 2
    );
    port (
        clock  : in  std_logic;
        clear  : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector (N-1 downto 0);
        Q      : out std_logic_vector (N-1 downto 0) 
    );
  end component;

  component contador_163
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
    );
  end component;

  component comparador_85
    port (
        i_A1   : in  std_logic;
        i_B1   : in  std_logic;
        i_A0   : in  std_logic;
        i_B0   : in  std_logic;
        i_AGTB : in  std_logic;
        i_ALTB : in  std_logic;
        i_AEQB : in  std_logic;
        o_AGTB : out std_logic;
        o_ALTB : out std_logic;
        o_AEQB : out std_logic
    );
  end component;

  component ram_10x2 is
    port (    
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(3 downto 0);
       dado_entrada : in  std_logic_vector(1 downto 0);
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(1 downto 0)
    );
  end component;

  component contador_m is
    generic (
        constant M: integer := 100 -- modulo do contador
    );
    port (
        clock   : in  std_logic;
        zera_as : in  std_logic;
        zera_s  : in  std_logic;
        conta   : in  std_logic;
        Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
        fim     : out std_logic;
        meio    : out std_logic
    );
  end component;
  
  -- component decodificador_premio is
  --   port (
  --       rodada : in std_logic_vector(3 downto 0);
  --       premio : out std_logic_vector(10 downto 0)
  --   );
  -- end component;

begin

  s_sinal <= botoes(0) or botoes(1) or botoes(2) or botoes(3);

  reset_edge <= not s_sinal;

  leds <= s_dado;

  registrador_premio: registrador_n
  generic map ( N => 4 )
    port map (
        clock  => clock, 
        clear  => limpaPR, 
        enable => registraPR, 
        D      => s_rodada, 
        Q      => s_premio_ganho
    );
                

  encoder: codificador_4x2
    port map(
      botoes => botoes,
      valor => s_codificado
    );

  db_conta_premio <= s_conta_premio;

  with seleciona_premio select
      s_conta_premio <= s_premio_ganho when '0',
              s_premio_ganho when '1',
              "1111" when others;

  -- calcula_premio: decodificador_premio
  --   port map (
  --     rodada => s_conta_premio,
  --     premio => premio
  --   );

  edge: edge_detector
    port map(
      clock => clock,
      reset => reset_edge,
      sinal => s_sinal,
      pulso => jogada_pulso
    );

  registrador: registrador_n
  generic map ( N => 2 )
    port map (
        clock  => clock, 
        clear  => limpaRC, 
        enable => registraRC, 
        D      => s_codificado, 
        Q      => s_resposta
    );

  s_not_zera_cr    <= not zeraCR;
  
  contador_rod: contador_m
  generic map ( M=> 11 )
    port map (
        clock => clock,
        zera_as => '0',
        zera_s   => zeraCR,  -- clr ativo em alto
        conta => contaCR,
        Q    => s_rodada,
        meio => open,
        fim  => fimL
    );


  comparador: comparador_85
    port map (
        i_A1   => s_dado(1),
        i_B1   => s_resposta(1),
        i_A0   => s_dado(0),
        i_B0   => s_resposta(0),
        i_AGTB => '0',
        i_ALTB => '0',
        i_AEQB => '1',
        o_AGTB => open, -- saidas nao usadas
        o_ALTB => open,
        o_AEQB => jogada_correta
    );

    -- timeout entre perguntas
    conta20000: contador_m
      generic map ( M=> 20000 )
      port map (
        clock => clock,
        zera_as => '0',
        zera_s => zeraT,
        conta => contaT,
        Q => open,
        meio => open,
        fim => fimT
      );

    -- timeout para voltar ao menu
    conta60000: contador_m
      generic map ( M=> 60000 )
      port map (
        clock => clock,
        zera_as => '0',
        zera_s => zeraJ0,
        conta => contaJ0,
        Q => open,
        meio => open,
        fim => fimJ0
      );

      
   s_endereco <= s_rodada;
   memoria: entity work.ram_10x2 (ram_mif)  -- usar esta linha para Intel Quartus
   ---- memoria: entity work.ram_10x2 (ram_modelsim) -- usar arquitetura para ModelSim
   port map (
      clk          => clock,
      endereco     => s_endereco,
      dado_entrada => s_resposta,
      we           => '1', -- we ativo em baixo
      ce           => '0',
      dado_saida   => s_dado
   );

 db_rodada   <= s_rodada;
 db_memoria  <= s_dado;
 db_jogada_feita <= s_resposta;

end architecture estrutural;