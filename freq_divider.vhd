LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY freq_divider IS
    PORT (
        clock_in  : IN STD_LOGIC;
        clock_out : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE division OF freq_divider IS

    SIGNAL count       : INTEGER   := 1;
    SIGNAL clock_state : STD_LOGIC := '0';

BEGIN

    PROCESS (clock_in)

    BEGIN

        IF (rising_edge(clock_in)) THEN

            count <= count + 1;

            IF (count = 25000) THEN

                clock_state <= NOT clock_state;
                count       <= 1;

            END IF;
        END IF;

        clock_out <= clock_state;

    END PROCESS;
END ARCHITECTURE;
