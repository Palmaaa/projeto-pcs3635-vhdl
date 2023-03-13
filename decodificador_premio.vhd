library ieee;
use ieee.std_logic_1164.all;

entity decodificador_premio is
    port (
        rodada : in std_logic_vector(3 downto 0);
        premio : out std_logic_vector(10 downto 0)
    );
end entity;

architecture decoder_arch of decodificador_premio is
    begin

        with rodada select 
            premio <= "00000000001" when "0000", -- rodada 0 -> 1
                      "00000000010" when "0001", -- rodada 1 -> 2
                      "00000000100" when "0010", -- rodada 2 -> 4
                      "00000001000" when "0011", -- rodada 3 -> 8
                      "00000010000" when "0100", -- rodada 4 -> 16
                      "00000100000" when "0101", -- rodada 5 -> 32
                      "00001000000" when "0110", -- rodada 6 -> 64
                      "00010000000" when "0111", -- rodada 7 -> 128
                      "00100000000" when "1000", -- rodada 8 -> 256
                      "01000000000" when "1001", -- rodada 9 -> 512
                      "10000000000" when "1010", -- rodada 10 -> 1024
                      "00000000000" when others;

end architecture;
