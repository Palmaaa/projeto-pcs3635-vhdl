LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY freq_divider IS
    GENERIC (
        CONSTANT R : INTEGER := 1000
    );
    PORT (
        reset     : IN STD_LOGIC;
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

            IF reset = '0' THEN

                count <= count + 1;

                IF (count = R) THEN

                    clock_state <= NOT clock_state;
                    count       <= 1;

                END IF;
            ELSIF reset = '1' THEN
                count       <= 1;
                clock_state <= '0';
            END IF;
        END IF;

        clock_out <= clock_state;

    END PROCESS;
END ARCHITECTURE;
