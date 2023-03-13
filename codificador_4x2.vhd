library ieee;
use ieee.std_logic_1164.all;

entity codificador_4x2 is
    port (
        botoes : in std_logic_vector(3 downto 0);
        valor : out std_logic_vector(1 downto 0)
    );
end entity codificador_4x2;

architecture cod4x2_arch of codificador_4x2 is

    begin
        valor <= "00" when botoes="0001" else
                 "01" when botoes="0010" else
                 "10" when botoes="0100" else
                 "11" when botoes="1000" else
                 "00";

end architecture cod4x2_arch;
