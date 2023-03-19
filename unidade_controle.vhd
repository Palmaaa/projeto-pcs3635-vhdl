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
        jogada : in std_logic_vector(1 downto 0);
        inicioL : in std_logic;
        fimL : in std_logic;
        meioT : in std_logic;
        fimT : in std_logic;
        fimJ0 : in std_logic;
        zeraCR : out std_logic;
        contaCR : out std_logic;
        reduzCR : out std_logic;
        limpaRC : out std_logic;
        registraRC : out std_logic;
        limpaPR : out std_logic;
        registraPR: out std_logic;
        zeraT : out std_logic;
        contaT : out std_logic;
        zeraJ0 : out std_logic;
        contaJ0 : out std_logic;
        ganhou : out std_logic;
        perdeu : out std_logic;
        pronto : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;
   

architecture fsm of unidade_controle is
    type t_estado is (
        menu_inicial, 
        registra_modo,
        seleciona_modo,
        mostra_pergunta0, mostra_pergunta1, mostra_pergunta2, mostra_pergunta3,
        espera_resposta0, espera_resposta1, espera_resposta2, espera_resposta3, 
        registra_resposta0, registra_resposta1, registra_resposta2, registra_resposta3, 
        compara_resposta0, compara_resposta1, compara_resposta2, compara_resposta3, 
        proxima_pergunta0, proxima_pergunta1, proxima_pergunta2, proxima_pergunta3, 
        reduz_rodada1,
        compara_rodada1,
        nova_pergunta1,
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
        menu_inicial            when Eatual=menu_inicial       and jogada_pulso='0'                 else
        registra_modo           when Eatual=menu_inicial       and jogada_pulso='1'                 else
        seleciona_modo          when Eatual=registra_modo                                           else 

        -- Modo de jogo 0 (aprender), tentar quantas vezes quiser a resposta
        mostra_pergunta0        when Eatual=seleciona_modo     and jogada="00"                      else
        espera_resposta0        when Eatual=mostra_pergunta0                                        else
        espera_resposta0        when Eatual=espera_resposta0   and jogada_pulso='0'   and fimT='0'  else
        registra_resposta0      when Eatual=espera_resposta0   and jogada_pulso='1'   and fimT='0'  else
        fim_timeout             when Eatual=espera_resposta0   and jogada_pulso='0'   and fimT='1'  else
        fim_timeout             when Eatual=espera_resposta0   and jogada_pulso='1'   and fimT='1'  else
        compara_resposta0       when Eatual=registra_resposta0                                      else
        proxima_pergunta0       when Eatual=compara_resposta0  and jogada_correta='1' and fimL='0'  else
        fim_acerto              when Eatual=compara_resposta0  and jogada_correta='1' and fimL='1'  else
        mostra_pergunta0        when Eatual=compara_resposta0  and jogada_correta='0'               else
        mostra_pergunta0        when Eatual=proxima_pergunta0                                       else

        -- Modo de jogo 1 (facil), volta uma rodada ao errar
        mostra_pergunta1        when Eatual=seleciona_modo     and jogada="01"                      else
        espera_resposta1        when Eatual=mostra_pergunta1                                        else
        espera_resposta1        when Eatual=espera_resposta1   and jogada_pulso='0'   and fimT='0'  else
        registra_resposta1      when Eatual=espera_resposta1   and jogada_pulso='1'   and fimT='0'  else
        fim_timeout             when Eatual=espera_resposta1   and jogada_pulso='0'   and fimT='1'  else
        fim_timeout             when Eatual=espera_resposta1   and jogada_pulso='1'   and fimT='1'  else
        compara_resposta1       when Eatual=registra_resposta1                                      else
        proxima_pergunta1       when Eatual=compara_resposta1  and jogada_correta='1' and fimL='0'  else
        fim_acerto              when Eatual=compara_resposta1  and jogada_correta='1' and fimL='1'  else
        reduz_rodada1           when Eatual=compara_resposta1  and jogada_correta='0'               else
        compara_rodada1         when Eatual=reduz_rodada1                                           else
        fim_erro                when Eatual=compara_rodada1    and inicioL='1'                      else
        nova_pergunta1          when Eatual=compara_rodada1    and inicioL='0'                      else
        mostra_pergunta1        when Eatual=nova_pergunta1                                          else
        mostra_pergunta1        when Eatual=proxima_pergunta1                                       else

        -- Modo de jogo 2 (normal), perda ao errar
        mostra_pergunta2        when Eatual=seleciona_modo     and jogada="10"                      else
        espera_resposta2        when Eatual=mostra_pergunta2                                        else
        espera_resposta2        when Eatual=espera_resposta2   and jogada_pulso='0'   and fimT='0'  else
        registra_resposta2      when Eatual=espera_resposta2   and jogada_pulso='1'   and fimT='0'  else
        fim_timeout             when Eatual=espera_resposta2   and jogada_pulso='0'   and fimT='1'  else
        fim_timeout             when Eatual=espera_resposta2   and jogada_pulso='1'   and fimT='1'  else
        compara_resposta2       when Eatual=registra_resposta2                                      else
        proxima_pergunta2       when Eatual=compara_resposta2  and jogada_correta='1' and fimL='0'  else
        fim_acerto              when Eatual=compara_resposta2  and jogada_correta='1' and fimL='1'  else
        fim_erro                when Eatual=compara_resposta2  and jogada_correta='0'               else
        mostra_pergunta2        when Eatual=proxima_pergunta2                                       else

        -- Modo de jogo 3 (dificil), maior velocidade 
        mostra_pergunta3        when Eatual=seleciona_modo     and jogada="11"                      else
        espera_resposta3        when Eatual=mostra_pergunta3                                        else
        espera_resposta3        when Eatual=espera_resposta3   and jogada_pulso='0'   and meioT='0' else
        registra_resposta3      when Eatual=espera_resposta3   and jogada_pulso='1'   and meioT='0' else
        fim_timeout             when Eatual=espera_resposta3   and jogada_pulso='0'   and meioT='1' else
        fim_timeout             when Eatual=espera_resposta3   and jogada_pulso='1'   and meioT='1' else
        compara_resposta3       when Eatual=registra_resposta3                                      else
        proxima_pergunta3       when Eatual=compara_resposta3  and jogada_correta='1' and fimL='0'  else
        fim_acerto              when Eatual=compara_resposta3  and jogada_correta='1' and fimL='1'  else
        fim_erro                when Eatual=compara_resposta3  and jogada_correta='0'               else
        mostra_pergunta3        when Eatual=proxima_pergunta3                                       else

        -- Estados para voltar ao menu
        fim_acerto              when Eatual=fim_acerto         and iniciar='0'        and fimJ0='0' else
        menu_inicial            when Eatual=fim_acerto         and iniciar='1'        and fimJ0='0' else
        fim_erro                when Eatual=fim_erro           and iniciar='0'        and fimJ0='0' else
        menu_inicial            when Eatual=fim_erro           and iniciar='1'        and fimJ0='0' else
        fim_timeout             when Eatual=fim_timeout        and iniciar='0'        and fimJ0='0' else
        menu_inicial            when Eatual=fim_timeout        and iniciar='1'        and fimJ0='0' else
        menu_inicial            when Eatual=fim_acerto         and iniciar='0'        and fimJ0='1' else
        menu_inicial            when Eatual=fim_erro           and iniciar='0'        and fimJ0='1' else
        menu_inicial            when Eatual=fim_timeout        and iniciar='0'        and fimJ0='1' else
        menu_inicial;

    -- logica de saída (maquina de Moore)
    with Eatual select
        zeraCR <=     '1' when menu_inicial,
                      '0' when others;
    
    with Eatual select
        contaCR <=    '1' when proxima_pergunta0 | proxima_pergunta1 | proxima_pergunta2 | proxima_pergunta3,
                      '0' when others;

    with Eatual select
        reduzCR <= '1' when reduz_rodada1,
                    '0' when others;

     with Eatual select
        limpaRC <= '1' when menu_inicial |  mostra_pergunta0 | mostra_pergunta1 | mostra_pergunta2 | mostra_pergunta3  | proxima_pergunta0 | proxima_pergunta1 | proxima_pergunta2 | proxima_pergunta3,
                    '0' when others;

    with Eatual select
        registraRC <= '1' when registra_resposta0 | registra_resposta1 | registra_resposta2 | registra_resposta3 | registra_modo,
                        '0' when others;

    with Eatual select
        zeraT <= '1' when registra_resposta0 | registra_resposta1 | registra_resposta2 | registra_resposta3 | menu_inicial,
                    '0' when others;

    with Eatual select
        contaT <= '1' when espera_resposta0 | espera_resposta1 | espera_resposta2 | espera_resposta3,
                    '0' when others;

    with Eatual select
        zeraJ0 <=     '1' when menu_inicial | mostra_pergunta0 | mostra_pergunta1 | mostra_pergunta2 | mostra_pergunta3,
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
        registraPR <= '1' when proxima_pergunta0 | proxima_pergunta1 | proxima_pergunta2 | proxima_pergunta3 | fim_acerto,
                                '0' when others;

    with Eatual select
        limpaPR <= '1' when menu_inicial,
                                '0' when others;

    
    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0001" when menu_inicial,  -- 1
                     "0010" when espera_resposta0,    -- 2
                     "0011" when espera_resposta1,  -- 3
                     "0100" when espera_resposta2,     -- 4
                     "0101" when espera_resposta3, -- 5
                     "1010" when fim_acerto,         -- A
                     "1110" when fim_erro,         -- E
                     "1111" when others;      -- F

end architecture fsm;
