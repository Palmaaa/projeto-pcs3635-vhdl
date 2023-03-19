library ieee;
use ieee.std_logic_1164.all;

entity letter7seg is
    port (
        letter : in  std_logic_vector(1 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end entity letter7seg;

architecture comportamental of letter7seg is
begin

  sseg <= "0001000" when letter="00" else
          "0000011" when letter="01" else
          "1000110" when letter="10" else
          "0000110" when letter="11" else
          "1111111";

end architecture comportamental;
