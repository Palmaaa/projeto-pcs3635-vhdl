LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY unidade_controle IS
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
END ENTITY;
ARCHITECTURE fsm OF unidade_controle IS
    TYPE t_estado IS (
        menu_inicial,
        registra_modo,
        seleciona_modo,
        mostra_pergunta0, mostra_pergunta1, mostra_pergunta2, mostra_pergunta3,
        espera_resposta0, espera_resposta1, espera_resposta2, espera_resposta3,
        registra_resposta0, registra_resposta1, registra_resposta2, registra_resposta3,
        compara_resposta0, compara_resposta1, compara_resposta2, compara_resposta3,
        proxima_pergunta0, proxima_pergunta1, proxima_pergunta2, proxima_pergunta3,
        fim_acerto,
        fim_erro,
        fim_timeout
    );
    SIGNAL Eatual, Eprox : t_estado;

    SIGNAL neg_reset : STD_LOGIC;
BEGIN

    neg_reset <= NOT reset;

    -- memoria de estado
    PROCESS (clock, reset)
    BEGIN
        IF neg_reset = '1' THEN
            Eatual <= menu_inicial;
        ELSIF clock'event AND clock = '1' THEN
            Eatual <= Eprox;
        END IF;
    END PROCESS;

    -- logica de proximo estado
    Eprox <=
        menu_inicial WHEN Eatual = menu_inicial AND resposta_pulso = '0' ELSE
        registra_modo WHEN Eatual = menu_inicial AND resposta_pulso = '1' ELSE
        seleciona_modo WHEN Eatual = registra_modo ELSE

        -- Modo de jogo 0 (aprender), tentar quantas vezes quiser a resposta
        mostra_pergunta0 WHEN Eatual = seleciona_modo AND resposta = "00" ELSE
        espera_resposta0 WHEN Eatual = mostra_pergunta0 ELSE
        espera_resposta0 WHEN Eatual = espera_resposta0 AND resposta_pulso = '0' AND fimT = '0' ELSE
        registra_resposta0 WHEN Eatual = espera_resposta0 AND resposta_pulso = '1' AND fimT = '0' ELSE
        fim_timeout WHEN Eatual = espera_resposta0 AND resposta_pulso = '0' AND fimT = '1' ELSE
        fim_timeout WHEN Eatual = espera_resposta0 AND resposta_pulso = '1' AND fimT = '1' ELSE
        compara_resposta0 WHEN Eatual = registra_resposta0 ELSE
        proxima_pergunta0 WHEN Eatual = compara_resposta0 AND acertou = '1' AND fimL = '0' ELSE
        fim_acerto WHEN Eatual = compara_resposta0 AND acertou = '1' AND fimL = '1' ELSE
        mostra_pergunta0 WHEN Eatual = compara_resposta0 AND acertou = '0' ELSE
        mostra_pergunta0 WHEN Eatual = proxima_pergunta0 ELSE

        -- Modo de jogo 1 (facil), perde somente apos metade do jogo
        mostra_pergunta1 WHEN Eatual = seleciona_modo AND resposta = "01" ELSE
        espera_resposta1 WHEN Eatual = mostra_pergunta1 ELSE
        espera_resposta1 WHEN Eatual = espera_resposta1 AND resposta_pulso = '0' AND fimT = '0' ELSE
        registra_resposta1 WHEN Eatual = espera_resposta1 AND resposta_pulso = '1' AND fimT = '0' ELSE
        fim_timeout WHEN Eatual = espera_resposta1 AND resposta_pulso = '0' AND fimT = '1' ELSE
        fim_timeout WHEN Eatual = espera_resposta1 AND resposta_pulso = '1' AND fimT = '1' ELSE
        compara_resposta1 WHEN Eatual = registra_resposta1 ELSE
        proxima_pergunta1 WHEN Eatual = compara_resposta1 AND acertou = '1' AND fimL = '0' ELSE
        fim_acerto WHEN Eatual = compara_resposta1 AND acertou = '1' AND fimL = '1' ELSE
        mostra_pergunta1 WHEN Eatual = compara_resposta1 AND acertou = '0' AND posmeioL = '0' ELSE
        fim_erro WHEN Eatual = compara_resposta1 AND acertou = '0' AND posmeioL = '1' ELSE
        mostra_pergunta1 WHEN Eatual = proxima_pergunta1 ELSE

        -- Modo de jogo 2 (normal), perda ao errar
        mostra_pergunta2 WHEN Eatual = seleciona_modo AND resposta = "10" ELSE
        espera_resposta2 WHEN Eatual = mostra_pergunta2 ELSE
        espera_resposta2 WHEN Eatual = espera_resposta2 AND resposta_pulso = '0' AND fimT = '0' ELSE
        registra_resposta2 WHEN Eatual = espera_resposta2 AND resposta_pulso = '1' AND fimT = '0' ELSE
        fim_timeout WHEN Eatual = espera_resposta2 AND resposta_pulso = '0' AND fimT = '1' ELSE
        fim_timeout WHEN Eatual = espera_resposta2 AND resposta_pulso = '1' AND fimT = '1' ELSE
        compara_resposta2 WHEN Eatual = registra_resposta2 ELSE
        proxima_pergunta2 WHEN Eatual = compara_resposta2 AND acertou = '1' AND fimL = '0' ELSE
        fim_acerto WHEN Eatual = compara_resposta2 AND acertou = '1' AND fimL = '1' ELSE
        fim_erro WHEN Eatual = compara_resposta2 AND acertou = '0' ELSE
        mostra_pergunta2 WHEN Eatual = proxima_pergunta2 ELSE

        -- Modo de jogo 3 (dificil), maior velocidade 
        mostra_pergunta3 WHEN Eatual = seleciona_modo AND resposta = "11" ELSE
        espera_resposta3 WHEN Eatual = mostra_pergunta3 ELSE
        espera_resposta3 WHEN Eatual = espera_resposta3 AND resposta_pulso = '0' AND meioT = '0' ELSE
        registra_resposta3 WHEN Eatual = espera_resposta3 AND resposta_pulso = '1' AND meioT = '0' ELSE
        fim_timeout WHEN Eatual = espera_resposta3 AND resposta_pulso = '0' AND meioT = '1' ELSE
        fim_timeout WHEN Eatual = espera_resposta3 AND resposta_pulso = '1' AND meioT = '1' ELSE
        compara_resposta3 WHEN Eatual = registra_resposta3 ELSE
        proxima_pergunta3 WHEN Eatual = compara_resposta3 AND acertou = '1' AND fimL = '0' ELSE
        fim_acerto WHEN Eatual = compara_resposta3 AND acertou = '1' AND fimL = '1' ELSE
        fim_erro WHEN Eatual = compara_resposta3 AND acertou = '0' ELSE
        mostra_pergunta3 WHEN Eatual = proxima_pergunta3 ELSE

        -- Estados para voltar ao menu
        fim_acerto WHEN Eatual = fim_acerto AND neg_reset = '0' AND fimJ0 = '0' ELSE
        menu_inicial WHEN Eatual = fim_acerto AND neg_reset = '1' AND fimJ0 = '0' ELSE
        fim_erro WHEN Eatual = fim_erro AND neg_reset = '0' AND fimJ0 = '0' ELSE
        menu_inicial WHEN Eatual = fim_erro AND neg_reset = '1' AND fimJ0 = '0' ELSE
        fim_timeout WHEN Eatual = fim_timeout AND neg_reset = '0' AND fimJ0 = '0' ELSE
        menu_inicial WHEN Eatual = fim_timeout AND neg_reset = '1' AND fimJ0 = '0' ELSE
        menu_inicial WHEN Eatual = fim_acerto AND neg_reset = '0' AND fimJ0 = '1' ELSE
        menu_inicial WHEN Eatual = fim_erro AND neg_reset = '0' AND fimJ0 = '1' ELSE
        menu_inicial WHEN Eatual = fim_timeout AND neg_reset = '0' AND fimJ0 = '1' ELSE
        menu_inicial;

    -- logica de saída (maquina de Moore)
    WITH Eatual SELECT
        zeraCR <= '1' WHEN menu_inicial,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        escolheu_menu <= '0' WHEN menu_inicial | registra_modo,
        '1' WHEN OTHERS;

    WITH Eatual SELECT
        contaCR <= '1' WHEN proxima_pergunta0 | proxima_pergunta1 | proxima_pergunta2 | proxima_pergunta3,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        limpaRC <= '1' WHEN menu_inicial,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        registraRC <= '1' WHEN registra_resposta0 | registra_resposta1 | registra_resposta2 | registra_resposta3 | registra_modo,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        zeraT <= '1' WHEN registra_resposta0 | registra_resposta1 | registra_resposta2 | registra_resposta3 | menu_inicial,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        contaT <= '1' WHEN espera_resposta0 | espera_resposta1 | espera_resposta2 | espera_resposta3,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        compara <= '1' WHEN compara_resposta0 | compara_resposta1 | compara_resposta2 | compara_resposta3,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        zeraJ0 <= '1' WHEN menu_inicial | mostra_pergunta0 | mostra_pergunta1 | mostra_pergunta2 | mostra_pergunta3,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        contaJ0 <= '1' WHEN menu_inicial | fim_acerto | fim_erro | fim_timeout,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        zeraEP <= '0' WHEN espera_resposta0 | espera_resposta1 | espera_resposta2 | espera_resposta3,
        '1' WHEN OTHERS;

    WITH Eatual SELECT
        ganhou <= '1' WHEN fim_acerto,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        perdeu <= '1' WHEN fim_erro | fim_timeout,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        registraPR <= '1' WHEN proxima_pergunta0 | proxima_pergunta1 | proxima_pergunta2 | proxima_pergunta3 | fim_acerto,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        limpaPR <= '1' WHEN menu_inicial,
        '0' WHEN OTHERS;

    WITH Eatual SELECT
        reiniciar <= '1' WHEN menu_inicial,
        '0' WHEN OTHERS;
    -- saida de depuracao (db_estado)
    WITH Eatual SELECT
        db_estado <= "0001" WHEN menu_inicial, -- 1
        "0010" WHEN espera_resposta0,          -- 2
        "0011" WHEN espera_resposta1,          -- 3
        "0100" WHEN espera_resposta2,          -- 4
        "0101" WHEN espera_resposta3,          -- 5
        "1010" WHEN fim_acerto,                -- A
        "1110" WHEN fim_erro,                  -- E
        "1111" WHEN OTHERS;                    -- F

END ARCHITECTURE fsm;
