LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY letter7seg IS
    PORT (
        letter : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        sseg   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY letter7seg;

ARCHITECTURE comportamental OF letter7seg IS
BEGIN

    sseg <= "0001000" WHEN letter = "00" ELSE
        "0000011" WHEN letter = "01" ELSE
        "1000110" WHEN letter = "10" ELSE
        "0100001" WHEN letter = "11" ELSE
        "1111111";

END ARCHITECTURE comportamental;
