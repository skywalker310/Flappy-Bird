			-- randomizing integer process
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

entity LFSR is 
PORT 
	(lfsr_clk		:	IN std_logic;
	 lfsr_seed		:	IN std_logic_vector(7 downto 0);
	 enablen			:	IN std_logic;
	 rst				:	IN std_logic;
	 output			:	OUT std_logic_vector(7 downto 0));
END LFSR;

Architecture behavior of LFSR IS

SIGNAL rand : std_logic_vector(8 downto 1) := "11001011";
SIGNAL poly	: std_logic_vector(8 downto 1) := "10111000";
SIGNAL mask	: std_logic_vector(8 downto 1);

BEGIN
output <= rand(8 downto 1);

generate_mask : for i in 8 downto 1 generate
	mask(i)  <=poly(i) and rand(1);
end generate generate_mask;

PROCESS (lfsr_clk)
BEGIN
	IF (rising_edge(lfsr_clk)) THEN
		IF rst = '1' THEN
			rand <= lfsr_seed;
		ELSIF enablen = '0' THEN
			rand <= '0' & rand(8 downto 2) xor mask;
		END IF;
	END IF;
END PROCESS;

END behavior;