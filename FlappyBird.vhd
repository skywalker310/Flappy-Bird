			-- Bird Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY bird IS

   PORT(pixel_row, pixel_column		: IN std_logic_vector(10 DOWNTO 0);
		  flap				: in std_logic;
		  enable				: in std_logic;
		  rom_in				: out std_logic_vector(11 downto 0);
		  rom_out			: in std_logic_vector(11 downto 0);
		  bg_in				: out std_logic_vector(17 downto 0);
		  bg_out				: in std_logic_vector(11 downto 0);
		  draw				: out std_logic;
        Vert_sync	: IN std_logic);
				
END bird;

architecture behavior of bird is

			-- Video Display Signals   
SIGNAL bird_on, Direction			: std_logic;
SIGNAL Size 						: std_logic_vector(10 DOWNTO 0);  
SIGNAL Bird_Y_motion,Bird_X_motion	: std_logic_vector(10 DOWNTO 0);
SIGNAL Bird_Y_pos, Bird_X_pos		: std_logic_vector(10 DOWNTO 0);
SIGNAL fly_counter: natural range 0 to 100;


BEGIN           

Size <= CONV_STD_LOGIC_VECTOR(25,11);
Bird_X_pos <= CONV_STD_LOGIC_VECTOR(80,11);

RGB_Display: Process (pixel_column, pixel_row)
	variable addr_1,addr_2: std_logic_vector(17 downto 0);
	variable x,y: std_logic_vector(10 downto 0);
	variable bg_addr_1, bg_addr_2: std_logic_vector(20 downto 0);
BEGIN
			-- Set Ball_on ='1' to display ball
	IF ('0' & Bird_X_pos <= pixel_column + Size) AND
 			-- compare positive numbers only
		(Bird_X_pos + Size >= '0' & pixel_column) AND
		('0' & Bird_Y_pos <= pixel_row + Size) AND
		(Bird_Y_pos + Size >= '0' & pixel_row ) THEN
			draw <= '1';
			y := pixel_row + size - bird_y_pos;
			x := pixel_column + size - bird_x_pos;
			addr_1 := ("00" & y & "00000") + ("000" & y & "0000") + ("000000" & y & '0');
			addr_2 := addr_1 + ("0000000" & x);
			rom_in <= addr_2(11 downto 0);
	ELSE
		draw <= '0';
	END IF;

	if pixel_row >= 240 then
		y := pixel_row - 240;
		bg_addr_1 := ('0' & y & "000000000") + ("000" & y & "0000000");
		bg_addr_2 := bg_addr_1 + ("0000000000" & pixel_column);
		bg_in <= bg_addr_2(17 downto 0);
	else
		bg_in <= conv_std_logic_vector(0, 18);
	end if;
	
	
END process RGB_Display;


Move_Bird: process
BEGIN
			-- Move bird once every vertical sync
	WAIT UNTIL vert_sync'event and vert_sync = '1';
		if enable = '1' then
			if flap = '0' then
				fly_counter <= 0;
			end if;
			
			if fly_counter < 15 then
				fly_counter <= fly_counter + 1;
				Bird_Y_motion <= CONV_STD_LOGIC_VECTOR(-6,11);
			else
				Bird_Y_motion <= CONV_STD_LOGIC_VECTOR(9,11);
			end if;
			
			-- Bounce off top or bottom of screen
			IF ('0' & Bird_Y_pos) >= 480 - Size THEN
				Bird_Y_motion <= CONV_STD_LOGIC_VECTOR(-2,11);
			ELSIF Bird_Y_pos <= Size THEN
				Bird_Y_motion <= CONV_STD_LOGIC_VECTOR(2,11);
			END IF;
		else
			bird_y_motion <= conv_std_logic_vector(0,11);
		end if;
			-- Compute next ball Y position
				Bird_Y_pos <= Bird_Y_pos + Bird_Y_motion;

END process Move_Bird;

END behavior;

