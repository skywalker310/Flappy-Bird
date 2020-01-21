			-- Moving Pipes Logic 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY pipes IS 
	PORT(clk								: IN std_logic;
		  pixel_row, pixel_column		: IN std_logic_vector(10 downto 0);
		  seed								: IN std_logic_vector(7 downto 0);
		  static_pipes						: IN std_logic;
		  stop_pipes						: IN std_logic;
		  restart_game						: IN std_logic;
		  Draw								: OUT std_logic;
		  score_counter					: OUT std_logic_vector(11 downto 0)
		  );
	END pipes; 

architecture behavior of pipes is

	COMPONENT LFSR 
	PORT 
		(lfsr_clk		:	IN std_logic;
		lfsr_seed		:	IN std_logic_vector(7 downto 0);
		enablen			:	IN std_logic;
		rst				:	IN std_logic;
		output			:	OUT std_logic_vector(7 downto 0));
	END COMPONENT;

CONSTANT Pipe_Vertical_Separation 	: NATURAL	:= 200;
CONSTANT Pipe_Horizontal_Width		: NATURAL	:= 28;
SIGNAL Bottom_Pipe0_X_Pos				: std_logic_vector(10 downto 0) := conv_std_logic_vector(642,11);
SIGNAL Bottom_Pipe0_Y_Pos				: std_logic_vector(10 downto 0) := conv_std_logic_vector(150,11);

SIGNAL Bottom_Pipe1_X_Pos				: std_logic_vector(10 downto 0) := conv_std_logic_vector(855,11);
SIGNAL Bottom_Pipe1_Y_Pos				: std_logic_vector(10 downto 0) := conv_std_logic_vector(480,11);

SIGNAL Bottom_Pipe2_X_Pos				: std_logic_vector(10 downto 0) := conv_std_logic_vector(1071,11);
SIGNAL Bottom_Pipe2_Y_Pos				: std_logic_vector(10 downto 0) := conv_std_logic_vector(480,11);

SIGNAL score								: std_logic_vector(11 downto 0);


SIGNAL rand_num							: std_logic_vector(7 downto 0);

BEGIN

	rand_generator: LFSR PORT MAP 
	(lfsr_clk		=>		clk,
	lfsr_seed		=>		seed,
	enablen			=>		stop_pipes,
	rst				=>		static_pipes,
	output			=>		rand_num);
	
	score_counter <= score;

Move_Pipes: Process(clk)
BEGIN

	IF rising_edge(clk) THEN
		IF not (stop_pipes = '1') THEN
		
				IF Bottom_Pipe0_X_Pos < 1 THEN
					Bottom_Pipe0_X_Pos <= conv_std_logic_vector(642,11);
				ELSIF Bottom_Pipe0_X_Pos = 639 THEN
					-- handle the randomization of pipe y values
						Bottom_Pipe0_X_Pos <= Bottom_Pipe0_X_Pos - 3;
						Bottom_Pipe0_Y_Pos <= conv_std_logic_vector(conv_integer(rand_num)+12+Pipe_Vertical_Separation,11);
				ELSIF Bottom_Pipe0_X_Pos = 81 THEN
						Bottom_Pipe0_X_Pos <= Bottom_Pipe0_X_Pos - 3;
						score <= score+1;
				ELSE
						Bottom_Pipe0_X_Pos <= Bottom_Pipe0_X_Pos - 3;
				END IF;
				
				IF Bottom_Pipe1_X_Pos < 1 THEN
					Bottom_Pipe1_X_Pos <= conv_std_logic_vector(642,11);
				ELSIF Bottom_Pipe1_X_Pos = 639 THEN
					-- handle the randomization of pipe y values
						Bottom_Pipe1_X_Pos <= Bottom_Pipe1_X_Pos - 3;
						Bottom_Pipe1_Y_Pos <= conv_std_logic_vector(conv_integer(rand_num)+12+Pipe_Vertical_Separation,11);
				ELSIF Bottom_Pipe1_X_Pos = 81 THEN
						score <= score+1;
						Bottom_Pipe1_X_Pos <= Bottom_Pipe1_X_Pos - 3;
				ELSE
						Bottom_Pipe1_X_Pos <= Bottom_Pipe1_X_Pos - 3;
				END IF;
				
				IF Bottom_Pipe2_X_Pos < 1 THEN
					Bottom_Pipe2_X_Pos <= conv_std_logic_vector(642,11);
				ELSIF Bottom_Pipe2_X_Pos = 639 THEN
					-- handle the randomization of pipe y values
						Bottom_Pipe2_X_Pos <= Bottom_Pipe2_X_Pos - 3;
						Bottom_Pipe2_Y_Pos <= conv_std_logic_vector(conv_integer(rand_num)+12+Pipe_Vertical_Separation,11);
				ELSIF Bottom_Pipe2_X_Pos = 81 THEN
						score <= score+1;
						Bottom_Pipe2_X_Pos <= Bottom_Pipe2_X_Pos - 3;
				ELSE
						Bottom_Pipe2_X_Pos <= Bottom_Pipe2_X_Pos - 3;
				END IF;
				if score(3 downto 0) = "1010" then
						score(3 downto 0) <= "0000";
						score(7 downto 4) <= score(7 downto 4) + 1;
					end if;
					if score(7 downto 4) = "1010" then
						score(7 downto 4) <= "0000";
						score(11 downto 8) <= score(11 downto 8) + 1;
					end if;
					if score(11 downto 8) = "1010" then
						score <= "000000000000";
					end if;
				
		ELSE
			-- reset here, pipes are stopped and game is not playing
			IF restart_game = '1' THEN
				Bottom_Pipe0_X_Pos <= conv_std_logic_vector(642,11);
				Bottom_Pipe0_Y_Pos <= conv_std_logic_vector(480,11);
				
				Bottom_Pipe1_X_Pos <= conv_std_logic_vector(855,11);
				Bottom_Pipe1_Y_Pos <= conv_std_logic_vector(480,11);
				
				Bottom_Pipe2_X_Pos <= conv_std_logic_vector(1071,11);
				Bottom_Pipe2_Y_Pos <= conv_std_logic_vector(480,11);
				score <= "000000000000";
			END IF;
		END IF;
	END IF;
END PROCESS Move_Pipes;

RGB_Display: Process (pixel_row, pixel_column)

BEGIN
			IF (((pixel_column > Bottom_Pipe0_X_Pos) AND (pixel_column < (Bottom_Pipe0_X_Pos + Pipe_Horizontal_Width))) AND
				((pixel_row > Bottom_Pipe0_Y_Pos) OR (pixel_row < (Bottom_Pipe0_Y_Pos - Pipe_Vertical_Separation))))
				OR
				(((pixel_column > Bottom_Pipe1_X_Pos) AND (pixel_column < (Bottom_Pipe1_X_Pos + Pipe_Horizontal_Width))) AND
				((pixel_row > Bottom_Pipe1_Y_Pos) OR (pixel_row < (Bottom_Pipe1_Y_Pos - Pipe_Vertical_Separation))))
				OR
				(((pixel_column > Bottom_Pipe2_X_Pos) AND (pixel_column < (Bottom_Pipe2_X_Pos + Pipe_Horizontal_Width))) AND
				((pixel_row > Bottom_Pipe2_Y_Pos) OR (pixel_row < (Bottom_Pipe2_Y_Pos - Pipe_Vertical_Separation))))
				THEN
					Draw <= '1';
				ELSE
					Draw <= '0';
			END IF;
			
END Process RGB_Display;



END behavior;