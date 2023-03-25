LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY codificador_4x2 IS
    PORT (
        botoes : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        valor  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY codificador_4x2;

ARCHITECTURE cod4x2_arch OF codificador_4x2 IS

BEGIN
    valor <= "00" WHEN botoes = "0001" ELSE
        "01" WHEN botoes = "0010" ELSE
        "10" WHEN botoes = "0100" ELSE
        "11" WHEN botoes = "1000" ELSE
        "00";

END ARCHITECTURE cod4x2_arch;
