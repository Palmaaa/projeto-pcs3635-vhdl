-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : contador_m.vhd
-- Projeto   : Experiencia 4 - Desenvolvimento de Projeto de 
--                             Circuitos Digitais em FPGA
-------------------------------------------------------------------------
-- Descricao : contador binario, modulo m, com parametro M generic,
--             sinais para clear assincrono (zera_as) e sincrono (zera_s)
--             e saidas de fim e meio de contagem
-- 
--             calculo do numero de bits do contador em funcao do modulo:
--             N = natural(ceil(log2(real(M))))
--
-- Exemplo de instanciacao: contador módulo 50
--             CONT50: contador_m 
--                     generic map ( M=> 50 )
--                     port map ( ...
--             
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao
--     08/06/2020  1.1     Edson Midorikawa  revisao e melhoria de codigo 
--     09/09/2020  1.2     Edson Midorikawa  revisao 
--     30/01/2022  2.0     Edson Midorikawa  revisao do componente
--     29/01/2023  2.1     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY contador_m IS
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
END ENTITY contador_m;

ARCHITECTURE comportamental OF contador_m IS
    SIGNAL IQ : INTEGER RANGE 0 TO M - 1;
BEGIN

    PROCESS (clock, zera_as, zera_s, conta, IQ)
    BEGIN
        IF zera_as = '1' THEN
            IQ <= 0;
        ELSIF rising_edge(clock) THEN
            IF zera_s = '1' THEN
                IQ <= 0;
            ELSIF conta = '1' AND reduz = '0' THEN
                IF IQ = M - 1 THEN
                    IQ <= 0;
                ELSE
                    IQ <= IQ + 1;
                END IF;
            ELSIF reduz = '1' AND conta = '0' THEN
                IF IQ > 2 THEN
                    IQ <= IQ - 2;
                ELSE
                    IQ <= 0;
                END IF;
            ELSE
                IQ <= IQ;
            END IF;
        END IF;
    END PROCESS;

    -- saida fim
    fim <= '1' WHEN IQ = M - 1 ELSE
        '0';

    -- saida inicio
    inicio <= '1' WHEN IQ = 0 ELSE
        '0';

    -- saida meio
    meio <= '1' WHEN IQ = M/2 - 1 ELSE
        '0';

    -- saida Q
    Q <= STD_LOGIC_VECTOR(to_unsigned(IQ, Q'length));

END ARCHITECTURE comportamental;
