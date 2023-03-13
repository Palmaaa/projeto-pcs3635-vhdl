--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 3 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/01/2022  1.0     Edson Midorikawa  versao inicial
--     22/01/2023  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is
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
end entity;
   

architecture fsm of unidade_controle is
    type t_estado is (
        menu_inicial, 
        mostra_pergunta,
        espera_resposta, 
        registra_resposta, 
        compara_resposta, 
        proxima_pergunta, 
        fim_acerto,
        fim_erro,
        fim_timeout
        );
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= menu_inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        menu_inicial      when  Eatual=menu_inicial and jogada_pulso='0' else
        mostra_pergunta    when  Eatual=menu_inicial and jogada_pulso='1' else
        espera_resposta when Eatual=mostra_pergunta else
        espera_resposta when Eatual=espera_resposta and jogada_pulso='0' and fimT='0' else
        registra_resposta when Eatual=espera_resposta and jogada_pulso='1' and fimT='0' else
        fim_timeout when Eatual=espera_resposta and jogada_pulso='0' and fimT='1' else
        fim_timeout when Eatual=espera_resposta and jogada_pulso='1' and fimT='1' else
        compara_resposta     when  Eatual=registra_resposta else
        proxima_pergunta     when  Eatual=compara_resposta and jogada_correta='1' and fimL='0' else
        fim_acerto      when  Eatual=compara_resposta and jogada_correta='1' and fimL='1' else
        fim_erro        when  Eatual=compara_resposta and jogada_correta='0' else
        mostra_pergunta      when  Eatual=proxima_pergunta else
        fim_acerto      when  Eatual=fim_acerto and iniciar='0' and fimJ0='0' else
        menu_inicial  when  Eatual=fim_acerto and iniciar='1' and fimJ0='0' else
        fim_erro        when  Eatual=fim_erro and iniciar='0' and fimJ0='0' else
        menu_inicial  when  Eatual=fim_erro and iniciar='1' and fimJ0='0' else
        fim_timeout when Eatual=fim_timeout and iniciar='0' and fimJ0='0' else
        menu_inicial when Eatual=fim_timeout and iniciar='1' and fimJ0='0' else
        menu_inicial when Eatual=fim_acerto and iniciar='0' and fimJ0='1' else
        menu_inicial when Eatual=fim_erro and iniciar='0' and fimJ0='1' else
        menu_inicial when Eatual=fim_timeout and iniciar='0' and fimJ0='1' else
        menu_inicial;

    -- logica de saída (maquina de Moore)
    with Eatual select
        zeraCR <=      '1' when menu_inicial,
                      '0' when others;
    
    with Eatual select
        contaCR <=    '1' when proxima_pergunta,
                      '0' when others;

     with Eatual select
        limpaRC <= '1' when menu_inicial,
                    '0' when others;

    with Eatual select
        registraRC <= '1' when registra_resposta,
                        '0' when others;

    with Eatual select
        zeraT <= '1' when registra_resposta | menu_inicial,
                    '0' when others;

    with Eatual select
        contaT <= '1' when espera_resposta,
                    '0' when others;

    with Eatual select
        zeraJ0 <=     '1' when menu_inicial | mostra_pergunta,
                        '0' when others;

    with Eatual select
        contaJ0 <=     '1' when menu_inicial | fim_acerto | fim_erro | fim_timeout,
                        '0' when others;
    
    with Eatual select
        ganhou <= '1' when fim_acerto,
                    '0' when others;

    with Eatual select
        perdeu <= '1' when fim_erro | fim_timeout,
                    '0' when others;

    with Eatual select
        pronto <= '1' when fim_acerto | fim_erro | fim_timeout,
                    '0' when others;

    with Eatual select
        seleciona_premio <= '1' when fim_acerto | fim_erro | fim_timeout,
                    '0' when others;

    with Eatual select
        registraPR <= '1' when proxima_pergunta | fim_acerto,
                                '0' when others;

    with Eatual select
        limpaPR <= '1' when menu_inicial,
                                '0' when others;

    
    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0001" when menu_inicial,  -- 1
                     "0010" when espera_resposta,    -- 2
                     "0011" when registra_resposta,  -- 3
                     "0100" when compara_resposta,     -- 4
                     "0101" when proxima_pergunta, -- 5
                     "1010" when fim_acerto,         -- A
                     "1110" when fim_erro,         -- E
                     "1111" when others;      -- F

end architecture fsm;
